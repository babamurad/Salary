-- ============================================================================
-- Исправление: NUMERIC(18,2) -> MONEY для полей, которые в исходной
-- SQLite-схеме были объявлены типом CURRENCY (а не DECIMAL).
--
-- Зачем: в SQLite FireDAC узнаёт имя типа CURRENCY и напрямую даёт полю
-- Currency. Остальные денежные поля (DECIMAL(18,2)) получают обычный
-- FMTBcd. При переводе в PostgreSQL оба типа слили в один NUMERIC(18,2)
-- (001_initial_schema.sql, старая версия) — это различие пропало, и
-- часть persistent-полей датасетов (которые жёстко ждут Currency) стала
-- падать с EDatabaseError "Type mismatch ... expecting: Currency actual:
-- FMTBcd". Общее правило MapRules на всё подключение чинит эту группу,
-- но тут же ломает противоположную (DECIMAL-поля, которые должны
-- остаться FMTBcd) — то же исключение наоборот: "expecting: FMTBcd
-- actual: Currency" (на qryHistory.amount, qryVacation.avg_monthly_salary
-- и т.п.). Единственное решение без глобальных MapRules — вернуть
-- различие в самом типе колонки: MONEY маппится в Currency нативно,
-- без всяких дополнительных правил.
--
-- Применять один раз на базу, где уже выполнен 001_initial_schema.sql
-- со старыми типами NUMERIC(18,2) для этих 7 колонок:
--
--   psql -U <пользователь> -d <база> -f 004_fix_currency_columns.sql
--
-- На новых базах, где 001_initial_schema.sql выполняется впервые (уже
-- с MONEY), этот файл не нужен.
-- ============================================================================

ALTER TABLE employees      ALTER COLUMN base_salary     TYPE MONEY USING base_salary::money;

ALTER TABLE payroll_journal ALTER COLUMN gross_amount    TYPE MONEY USING gross_amount::money;
ALTER TABLE payroll_journal ALTER COLUMN tax_amount      TYPE MONEY USING tax_amount::money;
ALTER TABLE payroll_journal ALTER COLUMN pension_amount  TYPE MONEY USING pension_amount::money;
ALTER TABLE payroll_journal ALTER COLUMN net_amount      TYPE MONEY USING net_amount::money;
ALTER TABLE payroll_journal ALTER COLUMN union_amount    TYPE MONEY USING union_amount::money;
ALTER TABLE payroll_journal ALTER COLUMN alimony_amount  TYPE MONEY USING alimony_amount::money;

-- salary_history.amount, sick_leave_journal.*, vacation_journal.* —
-- НЕ трогаем: в исходной SQLite-схеме это DECIMAL(18,2), они и должны
-- остаться NUMERIC(18,2)/FMTBcd, как есть.
