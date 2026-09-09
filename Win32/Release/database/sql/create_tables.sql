-- Сотрудники
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fio TEXT NOT NULL,
    hire_date DATE,
    base_salary CURRENCY DEFAULT 0,
    status INTEGER DEFAULT 1 -- 1: активен, 0: уволен
);

-- Глобальные константы (налоги ТМ, лимиты)
CREATE TABLE const_settings (
    key_name TEXT PRIMARY KEY,
    key_value REAL
);

-- Журнал начислений (для истории)
CREATE TABLE payroll_journal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    emp_id INTEGER,
    period_date DATE, -- Первое число месяца
    gross_amount CURRENCY, -- Начислено
    tax_amount CURRENCY,   -- Удержано (10%)
    pension_amount CURRENCY, -- Пенсионный (2%)
    net_amount CURRENCY,   -- К выдаче
    FOREIGN KEY(emp_id) REFERENCES employees(id)
);