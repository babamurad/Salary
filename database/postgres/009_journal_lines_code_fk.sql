-- ============================================================================
-- Исправление: journal_lines ссылается на счета по КОДУ
-- (account_debit_code/account_credit_code), а не по внутреннему id.
--
-- Зачем: бухгалтер вводит проводку, думая кодами счетов ("Дт 70, Кт 68"),
-- а не служебными числовыми id счетов — так поле в сетке Delphi можно
-- просто печатать, без отдельного визуального компонента-подбора счёта.
--
-- Безопасно пересоздаёт journal_lines (DROP + CREATE) — таблица только
-- что создана в 007_ledger_core.sql и никаких проводок в ней ещё нет.
-- Если вы уже успели ввести проводки вручную до этой миграции — ОСТАНОВИТЕСЬ
-- и сначала сохраните их (выгрузка/скриншот), это удалит все строки
-- journal_lines.
--
-- Применять один раз, после 007_ledger_core.sql/008_seed_accounts.sql:
--
--   psql -U <пользователь> -d <база> -f 009_journal_lines_code_fk.sql
--
-- На новых базах, где 007_ledger_core.sql выполняется впервые (уже с
-- account_debit_code/account_credit_code), этот файл не нужен.
-- ============================================================================

DROP TABLE IF EXISTS journal_lines;

CREATE TABLE journal_lines (
    id                  SERIAL PRIMARY KEY,
    entry_id            INTEGER NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    line_no             INTEGER NOT NULL DEFAULT 1,
    account_debit_code  VARCHAR(20) NOT NULL REFERENCES accounts(code),
    account_credit_code VARCHAR(20) NOT NULL REFERENCES accounts(code),
    amount              MONEY NOT NULL DEFAULT 0,
    description         VARCHAR(500)
);

CREATE INDEX idx_journal_lines_entry  ON journal_lines (entry_id);
CREATE INDEX idx_journal_lines_debit  ON journal_lines (account_debit_code);
CREATE INDEX idx_journal_lines_credit ON journal_lines (account_credit_code);
