CREATE TABLE settings (
    key_name TEXT PRIMARY KEY,
    key_value REAL
);
-- Сразу добавим базовые данные для Туркменистана
INSERT INTO settings VALUES ('income_tax', 10.0);
INSERT INTO settings VALUES ('pension_fund', 2.0);
INSERT INTO settings VALUES ('min_salary_limit', 0);