CREATE TABLE IF NOT EXISTS salary_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    emp_id INTEGER NOT NULL,       -- Ссылка на сотрудника
    period_date DATE NOT NULL,     -- Месяц и год (например, '2025-01-01')
    amount DECIMAL(18, 2) DEFAULT 0, -- Сумма начисления за этот месяц
    FOREIGN KEY (emp_id) REFERENCES employees(id) ON DELETE CASCADE
);

-- Индекс для быстрого поиска по сотруднику и дате
CREATE UNIQUE INDEX IF NOT EXISTS idx_salary_history_emp_period 
ON salary_history (emp_id, period_date);
-- Таблица для ввода доходов за прошлые периоды (для расчета отпускных и больничных)