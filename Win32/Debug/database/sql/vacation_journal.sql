CREATE TABLE IF NOT EXISTS vacation_journal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    emp_id INTEGER NOT NULL,       -- ID сотрудника
    calc_date DATE NOT NULL,       -- Дата проведения расчета
    start_date DATE NOT NULL,      -- Дата начала отпуска
    end_date DATE NOT NULL,        -- Дата окончания отпуска
    days_count INTEGER NOT NULL,   -- Количество календарных дней
    avg_monthly_salary DECIMAL(18, 2), -- Среднемесячный заработок за 12 мес.
    avg_daily_salary DECIMAL(18, 2),   -- Среднедневной заработок
    total_amount DECIMAL(18, 2),       -- Итоговая сумма к выплате
    FOREIGN KEY (emp_id) REFERENCES employees(id)
);