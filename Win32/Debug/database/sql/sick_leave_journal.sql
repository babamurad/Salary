CREATE TABLE IF NOT EXISTS sick_leave_journal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    emp_id INTEGER NOT NULL,       -- ID сотрудника
    calc_date DATE NOT NULL,       -- Дата проведения расчета
    start_date DATE NOT NULL,      -- Дата начала болезни
    end_date DATE NOT NULL,        -- Дата окончания болезни
    days_count INTEGER NOT NULL,   -- Количество дней болезни
    avg_daily_salary DECIMAL(18, 2), -- Среднедневной заработок (базовый 100%)
    experience_years INTEGER,        -- Стаж сотрудника на момент болезни (полных лет)
    payment_percent DECIMAL(5, 2),   -- Процент оплаты по стажу (например, 60, 80 или 100)
    total_amount DECIMAL(18, 2),     -- Итоговая сумма к выплате
    FOREIGN KEY (emp_id) REFERENCES employees(id)
);