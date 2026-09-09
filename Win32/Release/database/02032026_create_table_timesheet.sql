-- Таблица ежедневного учета рабочего времени (Табель)
CREATE TABLE IF NOT EXISTS timesheet (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    emp_id INTEGER NOT NULL,
    work_date DATE NOT NULL,         -- Конкретная дата (например, 2026-03-15)
    hours_worked REAL DEFAULT 0,     -- Количество часов (может быть 8, 11, 0)
    status_code TEXT(5) DEFAULT 'Я', -- Буквенный код (Я, В, Р, ВМ, Б)
    notes TEXT,                      -- Примечание (например, "Поломка двигателя")
    FOREIGN KEY (emp_id) REFERENCES employees(id)
);

-- Создаем индексы для мгновенной скорости поиска и фильтрации табеля
CREATE INDEX IF NOT EXISTS idx_timesheet_emp_date ON timesheet(emp_id, work_date);
CREATE INDEX IF NOT EXISTS idx_timesheet_date ON timesheet(work_date);