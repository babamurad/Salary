CREATE VIEW v_current_payroll AS
SELECT 
    e.id,
    e.fio,
    e.base_salary,
    -- Пенсионный 2%
    ROUND(e.base_salary * (SELECT key_value FROM const_settings WHERE key_name = 'pension_rate') / 100, 2) as pension_val,
    -- Подоходный 10% (упрощенно)
    ROUND((e.base_salary - (e.base_salary * 0.02)) * (SELECT key_value FROM const_settings WHERE key_name = 'tax_rate') / 100, 2) as tax_val
FROM employees e
WHERE e.status = 1;