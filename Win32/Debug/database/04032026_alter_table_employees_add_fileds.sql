-- Добавляем долю ставки (по умолчанию 1.0, то есть полная ставка)
ALTER TABLE employees ADD COLUMN work_fraction REAL DEFAULT 1.0;

-- Добавляем льготу/освобождение от налогов (1 - есть льгота, 0 - нет)
ALTER TABLE employees ADD COLUMN is_tax_exempt INTEGER DEFAULT 0;

-- Добавляем классность (0 - без класса, 1, 2, 3 класс)
ALTER TABLE employees ADD COLUMN class_rank INTEGER DEFAULT 0;

-- Добавляем профсоюз (1 - состоит и платит взносы, 0 - не состоит)
ALTER TABLE employees ADD COLUMN trade_union INTEGER DEFAULT 0;

-- Добавляем алименты (процент удержания, по умолчанию 0)
ALTER TABLE employees ADD COLUMN alimony_percent REAL DEFAULT 0.0;

-- Добавляем банковский счет (строковое поле)
ALTER TABLE employees ADD COLUMN bank_account TEXT;