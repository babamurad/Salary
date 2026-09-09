ALTER TABLE employees
ADD COLUMN pension_rate REAL DEFAULT 2.0;

ALTER TABLE employees
ADD COLUMN pay_type INTEGER DEFAULT 0;

ALTER TABLE employees
ADD COLUMN schedule_type INTEGER DEFAULT 0;

ALTER TABLE employees
ADD COLUMN hourly_rate REAL DEFAULT 0;      -- Часовая ставка (для вахтовиков и водителей)