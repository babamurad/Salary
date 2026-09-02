-- ============================================================================
-- Этап 1: пользователи и роли (для многопользовательской работы по сети)
-- + журнал аудита — фундамент, детальные права по ролям будут
-- на Этапе 7 дорожной карты (TZ_BUHUCHET.md).
--
-- Пароль хранится не в открытом виде: SHA-256(соль + пароль), соль на
-- каждого пользователя своя (System.Hash.THashSHA2 в Delphi).
-- ============================================================================

CREATE TABLE IF NOT EXISTS app_users (
    id             SERIAL PRIMARY KEY,
    username       TEXT NOT NULL UNIQUE,
    password_hash  TEXT NOT NULL,   -- SHA-256(password_salt + пароль), hex-строка
    password_salt  TEXT NOT NULL,   -- случайная строка, своя для каждого пользователя
    full_name      TEXT,
    role           TEXT NOT NULL DEFAULT 'accountant',
        -- 'admin'      — полный доступ, настройки, пользователи
        -- 'accountant' — расчёт зарплаты, отчёты, справочники (текущий режим работы)
        -- 'cashier'    — касса/банк (появится на Этапе 4)
    is_active      INTEGER NOT NULL DEFAULT 1,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Журнал аудита: кто/когда/что сделал. Пишется из кода приложения
-- (не триггерами БД) — единая точка ответственности в Delphi-коде,
-- проще расширять по мере появления новых модулей.
CREATE TABLE IF NOT EXISTS audit_log (
    id           SERIAL PRIMARY KEY,
    user_id      INTEGER REFERENCES app_users(id),
    username     TEXT,             -- дублируем имя на случай удаления пользователя
    action       TEXT NOT NULL,    -- 'insert' / 'update' / 'delete' / 'login' и т.п.
    table_name   TEXT,
    record_id    TEXT,
    details      TEXT,             -- краткое описание/дельта изменений
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_log_table_record ON audit_log (table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_user ON audit_log (user_id);

-- Пользователь по умолчанию: admin / admin — обязательно смените пароль
-- после первого входа. password_hash = SHA256(password_salt + пароль),
-- ровно так же, как это будет проверяться в UnitLogin.pas.
INSERT INTO app_users (username, password_hash, password_salt, full_name, role, is_active)
VALUES (
    'admin',
    '8388b8fbb09dd1e9aede41855600572f34cda1ad4d92d5049cae9db37cb3dddc',
    'a1b2c3d4e5f6a7b8',
    'Администратор',
    'admin',
    1
)
ON CONFLICT (username) DO NOTHING;
