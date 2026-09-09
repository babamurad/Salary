CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	tabno INTEGER NOT NULL UNIQUE,
    fio TEXT NOT NULL,
    hire_date DATE,
    base_salary CURRENCY DEFAULT 0,
    dept_id INTEGER, -- Ссылка на отдел
    pos_id INTEGER,  -- Ссылка на должность
    status INTEGER DEFAULT 1,
    FOREIGN KEY(dept_id) REFERENCES departments(id) ON DELETE SET NULL,
    FOREIGN KEY(pos_id) REFERENCES positions(id) ON DELETE SET NULL
);