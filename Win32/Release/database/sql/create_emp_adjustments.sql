CREATE TABLE emp_adjustments (
    emp_id INTEGER,
    adj_name TEXT, -- 'Премия', 'Доплата за выслугу'
    adj_value REAL, 
    is_percent BOOLEAN, -- 1 если %, 0 если фикс. сумма
    FOREIGN KEY(emp_id) REFERENCES employees(id)
);