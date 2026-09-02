-- ============================================================================
-- Исправление: голый TEXT -> VARCHAR(N) для строковых колонок.
--
-- Зачем: у голого TEXT в PostgreSQL нет объявленной длины, и FireDAC
-- поэтому маппит такую колонку в WideMemo вместо WideString — а старый
-- код (и persistent-поля датасетов) ждут обычную строку (WideString).
-- Результат без этой миграции: EDatabaseError "Type mismatch ...
-- expecting: WideString actual: WideMemo".
--
-- Применять один раз на базу, где уже выполнены 001_initial_schema.sql
-- и 002_users_roles.sql (там сразу VARCHAR — эта миграция только
-- досоздаёт то же самое на уже существующей базе):
--
--   psql -U <пользователь> -d <база> -f 003_fix_text_columns.sql
--
-- ALTER COLUMN ... TYPE VARCHAR(N) без USING безопасен для перевода из
-- TEXT — но упадёт, если в данных уже есть строка длиннее N. На всякий
-- случай лимиты взяты с большим запасом относительно реальных значений.
-- ============================================================================

ALTER TABLE closed_periods  ALTER COLUMN period_str    TYPE VARCHAR(20);

ALTER TABLE company_info    ALTER COLUMN key_name       TYPE VARCHAR(100);
ALTER TABLE company_info    ALTER COLUMN display_name   TYPE VARCHAR(255);
ALTER TABLE company_info    ALTER COLUMN key_value      TYPE VARCHAR(1000);

ALTER TABLE const_settings  ALTER COLUMN key_name       TYPE VARCHAR(100);

ALTER TABLE departments     ALTER COLUMN dept_name      TYPE VARCHAR(255);

ALTER TABLE positions       ALTER COLUMN name           TYPE VARCHAR(255);
ALTER TABLE positions       ALTER COLUMN category       TYPE VARCHAR(100);

ALTER TABLE employees       ALTER COLUMN fio            TYPE VARCHAR(255);
ALTER TABLE employees       ALTER COLUMN bank_account   TYPE VARCHAR(100);

ALTER TABLE emp_adjustments ALTER COLUMN adj_name       TYPE VARCHAR(255);

ALTER TABLE settings        ALTER COLUMN sys_name       TYPE VARCHAR(100);
ALTER TABLE settings        ALTER COLUMN display_name   TYPE VARCHAR(255);

ALTER TABLE timesheet       ALTER COLUMN status_code    TYPE VARCHAR(10);
ALTER TABLE timesheet       ALTER COLUMN notes          TYPE VARCHAR(500);

-- app_users / audit_log — если 002_users_roles.sql уже применялся с TEXT
ALTER TABLE app_users       ALTER COLUMN username       TYPE VARCHAR(100);
ALTER TABLE app_users       ALTER COLUMN password_hash  TYPE VARCHAR(128);
ALTER TABLE app_users       ALTER COLUMN password_salt  TYPE VARCHAR(128);
ALTER TABLE app_users       ALTER COLUMN full_name      TYPE VARCHAR(255);
ALTER TABLE app_users       ALTER COLUMN role           TYPE VARCHAR(50);

ALTER TABLE audit_log       ALTER COLUMN username       TYPE VARCHAR(100);
ALTER TABLE audit_log       ALTER COLUMN action         TYPE VARCHAR(50);
ALTER TABLE audit_log       ALTER COLUMN table_name     TYPE VARCHAR(100);
ALTER TABLE audit_log       ALTER COLUMN record_id      TYPE VARCHAR(100);
ALTER TABLE audit_log       ALTER COLUMN details        TYPE VARCHAR(2000);
