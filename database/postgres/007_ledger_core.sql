-- ============================================================================
-- Этап 2: ядро двойной записи — план счетов + проводки.
--
-- Модель (как в 1С): хозяйственная операция описывается ДОКУМЕНТОМ
-- (доходной/расходной ведомостью, кассовым ордером и т.п.), а проводки —
-- это её отражение на счетах (Дт/Кт). journal_entries/journal_lines —
-- универсальное хранилище проводок независимо от того, откуда они
-- взялись: введены бухгалтером вручную (is_manual=1) или сформированы
-- из документа автоматически (is_manual=0, doc_type/doc_id указывают
-- на источник — появится в Этапе 3, когда зарплата начнёт формировать
-- проводки). Бухгалтер может открыть и поправить любую проводку в обоих
-- случаях — правила разнесения по счетам сами по себе не жёсткие,
-- никакой проверки "правильности" типа счёта здесь нет (план счетов —
-- просто справочник, старый учёт продолжает идти как шёл).
--
-- amount-поля — MONEY (не NUMERIC): FireDAC нативно мапит MONEY в
-- Currency без доп. настроек (см. историю миграции Этапа 1 в
-- README.md — почему NUMERIC(18,2) для денег доставляет проблемы).
-- ============================================================================

CREATE TABLE IF NOT EXISTS accounts (
    id            SERIAL PRIMARY KEY,
    code          VARCHAR(20)  NOT NULL UNIQUE,   -- '14124100'
    code_display  VARCHAR(30),                     -- '1412 41 00' — для показа
    name          VARCHAR(500) NOT NULL,
    account_type  VARCHAR(50),   -- Активы/Обязательства/Капитал.../Доходы/
                                  -- Расходы/Забалансовые счета — черновая
                                  -- разметка, см. database/coa/README.md,
                                  -- ничем не проверяется программой
    category      VARCHAR(10),   -- '14'   (раздел)
    subcategory   VARCHAR(10),   -- '141'
    acct_group    VARCHAR(10),   -- '1412' ("group" — зарезервированное слово SQL)
    synthetic     VARCHAR(20),   -- синтетический код старого плана, если есть
    old_code      VARCHAR(50),   -- код(ы) старого плана счетов (может быть
                                  -- несколько через запятую — так в источнике)
    code_length   INTEGER,
    is_active     INTEGER NOT NULL DEFAULT 1,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_accounts_category ON accounts (category);
CREATE INDEX IF NOT EXISTS idx_accounts_type ON accounts (account_type);

CREATE TABLE IF NOT EXISTS journal_entries (
    id            SERIAL PRIMARY KEY,
    entry_number  VARCHAR(50),    -- номер документа (заполняет бухгалтер/автонумерация — на выбор в UI)
    entry_date    DATE NOT NULL,
    description   VARCHAR(500),
    doc_type      VARCHAR(50),    -- NULL/'manual' — введено бухгалтером вручную;
                                   -- 'payroll_accrual' и т.п. появятся в Этапе 3
    doc_id        INTEGER,        -- id записи в таблице-источнике документа
    is_manual     INTEGER NOT NULL DEFAULT 1,
    status        VARCHAR(20) NOT NULL DEFAULT 'draft',
        -- 'draft'  — черновик, можно свободно менять/удалять
        -- 'posted' — проведён: правка запрещена (следит Delphi-форма),
        --            исправление — только встречной проводкой (сторно),
        --            не редактированием этой записи
    created_by    VARCHAR(100),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_journal_entries_date ON journal_entries (entry_date);
CREATE INDEX IF NOT EXISTS idx_journal_entries_doc ON journal_entries (doc_type, doc_id);

-- Классическая "проводка" (как в 1С): одна строка = один счёт дебета +
-- один счёт кредита + сумма. Документ (journal_entries) обычно содержит
-- несколько таких строк (например, начисление зарплаты — это Дт
-- затрат/Кт 70 на начисление, плюс отдельные строки Дт 70/Кт 68 и
-- Дт 70/Кт 69 на удержания). У такой формы строки дебет и кредит
-- балансируются самой её структурой — отдельная проверка "сумма
-- дебета = сумме кредита по документу" не нужна, это гарантировано
-- конструкцией таблицы.
--
-- Счета — по КОДУ (account_debit_code/credit_code), а не по внутреннему
-- id: бухгалтер вводит проводку, думая кодами счетов ("Дт 70, Кт 68"),
-- а не служебными числовыми id — так поле в сетке Delphi можно просто
-- печатать, без отдельного визуального компонента-подбора счёта.
CREATE TABLE IF NOT EXISTS journal_lines (
    id                  SERIAL PRIMARY KEY,
    entry_id            INTEGER NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    line_no             INTEGER NOT NULL DEFAULT 1,
    account_debit_code  VARCHAR(20) NOT NULL REFERENCES accounts(code),
    account_credit_code VARCHAR(20) NOT NULL REFERENCES accounts(code),
    amount              MONEY NOT NULL DEFAULT 0,
    description         VARCHAR(500)
);

CREATE INDEX IF NOT EXISTS idx_journal_lines_entry ON journal_lines (entry_id);
CREATE INDEX IF NOT EXISTS idx_journal_lines_debit ON journal_lines (account_debit_code);
CREATE INDEX IF NOT EXISTS idx_journal_lines_credit ON journal_lines (account_credit_code);
