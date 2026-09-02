-- ============================================================================
-- Исправление: INTEGER -> BIGINT для sick_leave_rates.min_years/max_years.
--
-- Зачем: SQLite хранит INTEGER произвольной величины (manifest typing) —
-- у верхней ступени стажа обычно стоит условная "бесконечность"
-- (например 999999999) как max_years, и FireDAC под SQLite определял
-- такую колонку как LargeInt (64-бит). Обычный 4-байтовый INTEGER в
-- PostgreSQL даёт EDatabaseError "Type mismatch ... expecting: LargeInt
-- actual: Integer" при открытии qrySickLeaveRates.
--
-- Применять один раз на базу, где уже выполнен 001_initial_schema.sql
-- со старыми типами INTEGER для этих колонок:
--
--   psql -U <пользователь> -d <база> -f 005_fix_sick_leave_rates_bigint.sql
--
-- На новых базах, где 001_initial_schema.sql выполняется впервые (уже
-- с BIGINT), этот файл не нужен.
-- ============================================================================

ALTER TABLE sick_leave_rates ALTER COLUMN min_years TYPE BIGINT;
ALTER TABLE sick_leave_rates ALTER COLUMN max_years TYPE BIGINT;
