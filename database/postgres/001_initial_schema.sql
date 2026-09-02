-- ============================================================================
-- Перевод действующей схемы SQLite (database/schema/salarydb_schema_only.sql,
-- реальный экспорт из рабочей salarydb.db) на PostgreSQL.
--
-- Правила перевода типов:
--   INTEGER PRIMARY KEY AUTOINCREMENT  -> SERIAL PRIMARY KEY
--   CURRENCY (денежные суммы)          -> MONEY  — специально НЕ то же
--                                          самое, что DECIMAL(18,2) ниже:
--                                          в SQLite FireDAC узнаёт имя типа
--                                          CURRENCY и даёт полю Currency
--                                          напрямую, а DECIMAL — обычный
--                                          FMTBcd. Если оба слить в один
--                                          NUMERIC(18,2), это различие
--                                          пропадает, и часть persistent-
--                                          полей (которые ждут именно
--                                          Currency) даёт EDatabaseError
--                                          "Type mismatch ... expecting:
--                                          Currency actual: FMTBcd" — а
--                                          если "починить" общим правилом
--                                          на всё подключение, ломаются
--                                          уже поля, которые ждут FMTBcd.
--                                          Родной тип MONEY в Postgres
--                                          FireDAC сам мапит в Currency —
--                                          без всяких MapRules.
--   DECIMAL(x,y) (проценты сумм и т.п.
--   не CURRENCY-поля)                  -> NUMERIC(x,y) — маппится в
--                                          FMTBcd, как и раньше в SQLite
--   REAL (проценты, ставки, часы)      -> DOUBLE PRECISION  (не REAL/float4
--                                          PostgreSQL — SQLite REAL физически
--                                          8-байтный double, сохраняем точность)
--   BOOLEAN (в SQLite это 0/1 INTEGER) -> INTEGER — оставляем как есть,
--                                          чтобы не менять поведение поля
--                                          в Delphi (TIntegerField, не
--                                          TBooleanField)
--   TEXT(N) с длиной                   -> VARCHAR(N) (щедрый запас длины) —
--                                          НЕ голый TEXT: у голого TEXT в
--                                          Postgres нет объявленной длины,
--                                          и FireDAC поэтому маппит такую
--                                          колонку в WideMemo вместо
--                                          WideString, а старый код ждёт
--                                          обычную строку (WideString) —
--                                          получаем EDatabaseError "Type
--                                          mismatch ... expecting:
--                                          WideString actual: WideMemo".
--
-- Порядок создания таблиц — с учётом внешних ключей (employees раньше того,
-- что на неё ссылается).
-- ============================================================================

CREATE TABLE IF NOT EXISTS closed_periods (
    period_str  VARCHAR(20) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS company_info (
    id            SERIAL PRIMARY KEY,
    key_name      VARCHAR(100) NOT NULL UNIQUE,
    display_name  VARCHAR(255) NOT NULL,
    key_value     VARCHAR(1000)
);

CREATE TABLE IF NOT EXISTS const_settings (
    key_name   VARCHAR(100) PRIMARY KEY,
    key_value  DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS departments (
    id         SERIAL PRIMARY KEY,
    dept_name  VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS positions (
    id        SERIAL PRIMARY KEY,
    name      VARCHAR(255) NOT NULL UNIQUE,
    category  VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS employees (
    id                    SERIAL PRIMARY KEY,
    tabno                 INTEGER NOT NULL UNIQUE,
    fio                   VARCHAR(255) NOT NULL,
    hire_date             DATE,
    base_salary           MONEY DEFAULT 0,
    dept_id               INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    pos_id                INTEGER REFERENCES positions(id) ON DELETE SET NULL,
    status                INTEGER DEFAULT 1,
    prior_exp_years       INTEGER DEFAULT 0,
    prior_exp_months      INTEGER DEFAULT 0,
    dependents_count      INTEGER DEFAULT 0,
    pension_rate          DOUBLE PRECISION DEFAULT 2.0,
    pay_type              INTEGER DEFAULT 0,
    schedule_type         INTEGER DEFAULT 0,
    hourly_rate           DOUBLE PRECISION DEFAULT 0,
    wage_type             INTEGER NOT NULL DEFAULT 0,
    is_rotation           INTEGER NOT NULL DEFAULT 0,
    work_fraction         DOUBLE PRECISION DEFAULT 1.0,
    is_tax_exempt         INTEGER DEFAULT 0,
    class_rank            INTEGER DEFAULT 0,
    trade_union           INTEGER DEFAULT 0,
    alimony_percent       DOUBLE PRECISION DEFAULT 0.0,
    bank_account          VARCHAR(100),
    sick_leave_percent    INTEGER DEFAULT 60,
    birth_date            DATE
);

CREATE TABLE IF NOT EXISTS emp_adjustments (
    emp_id      INTEGER REFERENCES employees(id),
    adj_name    VARCHAR(255),  -- 'Премия', 'Доплата за выслугу'
    adj_value   DOUBLE PRECISION,
    is_percent  INTEGER        -- 1 если %, 0 если фикс. сумма
);

CREATE TABLE IF NOT EXISTS payroll_journal (
    id               SERIAL PRIMARY KEY,
    emp_id           INTEGER REFERENCES employees(id),
    period_date      DATE,               -- Первое число месяца
    gross_amount     MONEY,               -- Начислено
    tax_amount       MONEY,               -- Подоходный
    pension_amount   MONEY,               -- Пенсионный
    net_amount       MONEY,               -- К выдаче
    union_amount     MONEY DEFAULT 0,     -- Профсоюз
    alimony_amount   MONEY DEFAULT 0      -- Алименты
);

CREATE TABLE IF NOT EXISTS production_calendar (
    year           INTEGER,
    month          INTEGER,
    working_days   INTEGER,
    working_hours  INTEGER,
    PRIMARY KEY (year, month)
);

CREATE TABLE IF NOT EXISTS salary_history (
    id           SERIAL PRIMARY KEY,
    emp_id       INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    period_date  DATE NOT NULL,
    amount       NUMERIC(18,2) DEFAULT 0
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_salary_history_emp_period
    ON salary_history (emp_id, period_date);

CREATE TABLE IF NOT EXISTS settings (
    id            SERIAL PRIMARY KEY,
    sys_name      VARCHAR(100) UNIQUE,
    display_name  VARCHAR(255),
    calc_type     INTEGER,
    key_value     DOUBLE PRECISION,
    is_active     INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS sick_leave_journal (
    id                 SERIAL PRIMARY KEY,
    emp_id             INTEGER NOT NULL REFERENCES employees(id),
    calc_date          DATE NOT NULL,
    start_date         DATE NOT NULL,
    end_date           DATE NOT NULL,
    days_count         INTEGER NOT NULL,
    avg_daily_salary   NUMERIC(18,2),
    experience_years   INTEGER,
    payment_percent    NUMERIC(5,2),
    total_amount       NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS sick_leave_rates (
    id         INTEGER PRIMARY KEY,
    min_years  INTEGER,
    -- BIGINT, не INTEGER: у верхней ступени стажа обычно стоит
    -- условная "бесконечность" (например 999999999) как значение
    -- max_years — SQLite хранит INTEGER произвольной величины и
    -- FireDAC для такой колонки определял поле как LargeInt; обычный
    -- 4-байтовый INTEGER в Postgres даёт EDatabaseError "Type mismatch
    -- ... expecting: LargeInt actual: Integer". min_years при этом
    -- остаётся обычным Integer — там всегда небольшие значения, и
    -- перевод в BIGINT ломает его в обратную сторону: "expecting:
    -- Integer actual: LargeInt".
    max_years  BIGINT,
    percent    DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS timesheet (
    id            SERIAL PRIMARY KEY,
    emp_id        INTEGER NOT NULL REFERENCES employees(id),
    work_date     DATE NOT NULL,
    hours_worked  DOUBLE PRECISION DEFAULT 0,
    status_code   VARCHAR(10) DEFAULT 'Я',
    notes         VARCHAR(500)
);

CREATE INDEX IF NOT EXISTS idx_timesheet_date ON timesheet (work_date);
CREATE INDEX IF NOT EXISTS idx_timesheet_emp_date ON timesheet (emp_id, work_date);

CREATE TABLE IF NOT EXISTS vacation_journal (
    id                   SERIAL PRIMARY KEY,
    emp_id               INTEGER NOT NULL REFERENCES employees(id),
    calc_date            DATE NOT NULL,
    start_date           DATE NOT NULL,
    end_date             DATE NOT NULL,
    days_count           INTEGER NOT NULL,
    avg_monthly_salary   NUMERIC(18,2),
    avg_daily_salary     NUMERIC(18,2),
    total_amount         NUMERIC(18,2)
);
