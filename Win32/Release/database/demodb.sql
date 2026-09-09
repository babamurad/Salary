BEGIN TRANSACTION;

-- =====================================================
-- 1. Дополнение справочников
-- =====================================================

-- Добавляем недостающие должности (без повтора "Кладовщик")
INSERT INTO "positions" ("id", "name", "category") VALUES
(8, 'Специалист по кадрам', 'АУП'),
(9, 'Инженер-технолог', 'Производство'),
(10, 'Оператор станка', 'Производство'),
(11, 'Механик', 'Транспорт'),
(12, 'Экспедитор', 'Транспорт'),
(13, 'Грузчик', 'Склад'),
(15, 'Инженер-конструктор', 'ИТР'),
(16, 'Программист', 'ИТР'),
(17, 'Экономист', 'АУП'),
(18, 'Начальник отдела кадров', 'АУП'),
(19, 'Заместитель директора', 'АУП');

-- Добавляем недостающую ставку больничного для стажа менее 5 лет
INSERT INTO "sick_leave_rates" ("min_years", "percent") VALUES (0, 60.0);

-- =====================================================
-- 2. Добавление 48 сотрудников (id с 3 по 50)
-- =====================================================

INSERT INTO "employees" ("id", "tabno", "fio", "hire_date", "base_salary", "dept_id", "pos_id", "status", "prior_exp_years", "prior_exp_months", "dependents_count") VALUES
(3, 3, 'Сергеев Сергей Петрович', '2018-02-10', 2800, 1, 19, 1, 15, 0, 2),
(4, 4, 'Антонова Анна Викторовна', '2019-05-20', 2200, 2, 2, 1, 8, 3, 1),
(5, 5, 'Петрова Ольга Ивановна', '2020-07-15', 1700, 2, 3, 1, 4, 6, 0),
(6, 6, 'Сидоров Иван Петрович', '2021-09-01', 1600, 2, 3, 1, 2, 0, 2),
(7, 7, 'Козлова Елена Дмитриевна', '2022-01-12', 1900, 2, 17, 1, 5, 0, 1),
(8, 8, 'Николаев Николай Николаевич', '2017-11-03', 2000, 3, 18, 1, 12, 0, 3),
(9, 9, 'Смирнова Мария Александровна', '2020-03-25', 1400, 3, 8, 1, 3, 5, 0),
(10, 10, 'Кузнецов Дмитрий Алексеевич', '2022-06-30', 1300, 3, 8, 1, 1, 2, 1),
(11, 11, 'Попов Андрей Сергеевич', '2019-10-10', 2100, 4, 4, 1, 7, 0, 2),
(12, 12, 'Васильев Владимир Владимирович', '2020-12-01', 1700, 4, 5, 1, 4, 8, 0),
(13, 13, 'Зайцева Татьяна Юрьевна', '2021-04-18', 1500, 4, 5, 1, 3, 0, 2),
(14, 14, 'Морозов Павел Павлович', '2022-08-22', 1400, 4, 9, 1, 2, 4, 1),
(15, 15, 'Волков Александр Александрович', '2023-02-14', 1300, 4, 9, 1, 1, 0, 0),
(16, 16, 'Алексеева Наталья Игоревна', '2023-09-05', 1200, 4, 9, 1, 0, 7, 0),
(17, 17, 'Лебедев Артем Викторович', '2024-01-20', 1100, 4, 10, 1, 0, 0, 0),
(18, 18, 'Семенова Ирина Васильевна', '2024-03-11', 1100, 4, 10, 1, 0, 0, 1),
(19, 19, 'Григорьев Григорий Григорьевич', '2024-06-01', 1150, 4, 10, 1, 0, 0, 2),
(20, 20, 'Павлова Оксана Олеговна', '2025-01-15', 1200, 4, 10, 1, 0, 0, 0),
(21, 21, 'Борисов Борис Борисович', '2025-03-01', 1250, 4, 10, 1, 0, 0, 1),
(22, 22, 'Федоров Федор Федорович', '2025-05-10', 1300, 4, 10, 1, 0, 0, 0),
(23, 23, 'Михайлов Михаил Михайлович', '2025-07-20', 1350, 4, 10, 1, 0, 0, 2),
(24, 24, 'Тарасова Татьяна Тарасовна', '2025-09-01', 1400, 4, 10, 1, 0, 0, 1),
(25, 25, 'Белов Бел Белович', '2025-11-11', 1450, 4, 10, 1, 0, 0, 0),
(26, 26, 'Комаров Комар Комарович', '2026-01-05', 1500, 4, 10, 1, 0, 0, 0),
(27, 27, 'Соколов Сокол Соколович', '2018-08-08', 2000, 5, 6, 1, 10, 0, 3),
(28, 28, 'Орлов Орел Орлович', '2019-12-12', 1800, 5, 6, 1, 7, 6, 2),
(29, 29, 'Гусев Гусь Гусевич', '2020-04-04', 1700, 5, 11, 1, 5, 0, 1),
(30, 30, 'Лебедев Лебедь Лебедевич', '2021-07-07', 1600, 5, 11, 1, 3, 9, 0),
(31, 31, 'Журавлев Журавль Журавлевич', '2022-10-10', 1500, 5, 12, 1, 2, 4, 1),
(32, 32, 'Цапля Цапля Цаплевич', '2023-02-02', 1400, 5, 12, 1, 1, 2, 0),
(33, 33, 'Пеликан Пеликан Пеликанович', '2024-05-05', 1300, 5, 12, 1, 0, 8, 2),
(34, 34, 'Фламинго Фламинго Фламингович', '2025-08-08', 1200, 5, 6, 1, 0, 0, 1),
(35, 35, 'Складской Склад Складской', '2019-03-03', 1600, 6, 7, 1, 6, 0, 2),
(36, 36, 'Полочкин Полка Полкович', '2020-06-06', 1500, 6, 7, 1, 4, 5, 1),
(37, 37, 'Ящиков Ящик Ящикович', '2021-09-09', 1400, 6, 7, 1, 3, 0, 0),
(38, 38, 'Грузчиков Грузчик Грузчикович', '2022-11-11', 1300, 6, 13, 1, 2, 2, 2),
(39, 39, 'Тяжелов Тяжело Тяжелович', '2023-04-04', 1200, 6, 13, 1, 1, 4, 0),
(40, 40, 'Легков Легко Легкович', '2024-07-07', 1100, 6, 13, 1, 0, 6, 1),
(41, 41, 'Завсклад Завсклад Завскладович', '2025-10-10', 1800, 6, 7, 1, 0, 0, 0),
(42, 42, 'Технический Техник Техникович', '2020-01-01', 1900, 7, 15, 1, 5, 0, 2),
(43, 43, 'Инженеров Инженер Инженерович', '2021-02-02', 1800, 7, 15, 1, 4, 3, 1),
(44, 44, 'Программистов Программ Программович', '2022-03-03', 2000, 7, 16, 1, 3, 6, 0),
(45, 45, 'Кодиров Код Кодович', '2023-04-04', 1700, 7, 16, 1, 2, 0, 2),
(46, 46, 'Схемов Схема Схемович', '2024-05-05', 1600, 7, 15, 1, 1, 9, 1),
(47, 47, 'Микросхемов Микро Микрович', '2025-06-06', 1500, 7, 16, 1, 0, 2, 0),
(48, 48, 'Админов Админ Админович', '2021-08-08', 2200, 1, 1, 1, 8, 0, 3),
(49, 49, 'Замдиректоров Зам Замович', '2022-09-09', 2100, 1, 19, 1, 6, 5, 2),
(50, 50, 'Экономов Эконом Экономович', '2023-12-12', 1700, 1, 17, 1, 4, 0, 1);

-- =====================================================
-- 3. История окладов (salary_history) за 7 месяцев
-- =====================================================

-- Декабрь 2025 (сотрудник 26 ещё не работает)
INSERT INTO "salary_history" ("emp_id", "period_date", "amount")
SELECT id, '2025-12-01', base_salary
FROM employees
WHERE id BETWEEN 3 AND 50 AND id != 26;

-- Январь 2026 (сотрудник 26 ещё не работает)
INSERT INTO "salary_history" ("emp_id", "period_date", "amount")
SELECT id, '2026-01-01',
  CASE WHEN id = 3 THEN 3000 ELSE base_salary END
FROM employees
WHERE id BETWEEN 3 AND 50 AND id != 26;

-- Февраль 2026
INSERT INTO "salary_history" ("emp_id", "period_date", "amount")
SELECT id, '2026-02-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    ELSE base_salary
  END
FROM employees
WHERE id BETWEEN 3 AND 50;

-- Март 2026
INSERT INTO "salary_history" ("emp_id", "period_date", "amount")
SELECT id, '2026-03-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END
FROM employees
WHERE id BETWEEN 3 AND 50;

-- Апрель 2026
INSERT INTO "salary_history" ("emp_id", "period_date", "amount")
SELECT id, '2026-04-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END
FROM employees
WHERE id BETWEEN 3 AND 50;

-- Май 2026
INSERT INTO "salary_history" ("emp_id", "period_date", "amount")
SELECT id, '2026-05-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END
FROM employees
WHERE id BETWEEN 3 AND 50;

-- Июнь 2026
INSERT INTO "salary_history" ("emp_id", "period_date", "amount")
SELECT id, '2026-06-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END
FROM employees
WHERE id BETWEEN 3 AND 50;

-- =====================================================
-- 4. Расчётный журнал (payroll_journal) за те же месяцы
-- =====================================================

-- Декабрь 2025
INSERT INTO "payroll_journal" ("emp_id", "period_date", "gross_amount", "tax_amount", "pension_amount", "net_amount")
SELECT id, '2025-12-01',
  base_salary,
  base_salary*0.1,
  base_salary*0.02,
  base_salary*0.88
FROM employees
WHERE id BETWEEN 3 AND 50 AND id != 26;

-- Январь 2026
INSERT INTO "payroll_journal" ("emp_id", "period_date", "gross_amount", "tax_amount", "pension_amount", "net_amount")
SELECT id, '2026-01-01',
  CASE WHEN id = 3 THEN 3000 ELSE base_salary END,
  (CASE WHEN id = 3 THEN 3000 ELSE base_salary END)*0.1,
  (CASE WHEN id = 3 THEN 3000 ELSE base_salary END)*0.02,
  (CASE WHEN id = 3 THEN 3000 ELSE base_salary END)*0.88
FROM employees
WHERE id BETWEEN 3 AND 50 AND id != 26;

-- Февраль 2026
INSERT INTO "payroll_journal" ("emp_id", "period_date", "gross_amount", "tax_amount", "pension_amount", "net_amount")
SELECT id, '2026-02-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    ELSE base_salary
  END,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    ELSE base_salary
  END)*0.1,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    ELSE base_salary
  END)*0.02,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    ELSE base_salary
  END)*0.88
FROM employees
WHERE id BETWEEN 3 AND 50;

-- Март 2026
INSERT INTO "payroll_journal" ("emp_id", "period_date", "gross_amount", "tax_amount", "pension_amount", "net_amount")
SELECT id, '2026-03-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END)*0.1,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END)*0.02,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END)*0.88
FROM employees
WHERE id BETWEEN 3 AND 50;

-- Апрель 2026
INSERT INTO "payroll_journal" ("emp_id", "period_date", "gross_amount", "tax_amount", "pension_amount", "net_amount")
SELECT id, '2026-04-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END)*0.1,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END)*0.02,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    ELSE base_salary
  END)*0.88
FROM employees
WHERE id BETWEEN 3 AND 50;

-- Май 2026
INSERT INTO "payroll_journal" ("emp_id", "period_date", "gross_amount", "tax_amount", "pension_amount", "net_amount")
SELECT id, '2026-05-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END)*0.1,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END)*0.02,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END)*0.88
FROM employees
WHERE id BETWEEN 3 AND 50;

-- Июнь 2026
INSERT INTO "payroll_journal" ("emp_id", "period_date", "gross_amount", "tax_amount", "pension_amount", "net_amount")
SELECT id, '2026-06-01',
  CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END)*0.1,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END)*0.02,
  (CASE
    WHEN id = 3 THEN 3000
    WHEN id = 8 THEN 2200
    WHEN id = 27 THEN 2200
    WHEN id = 35 THEN 1800
    WHEN id = 42 THEN 2100
    ELSE base_salary
  END)*0.88
FROM employees
WHERE id BETWEEN 3 AND 50;

-- =====================================================
-- 5. Отпуска (vacation_journal) для 15 сотрудников
-- =====================================================

INSERT INTO "vacation_journal" ("emp_id", "calc_date", "start_date", "end_date", "days_count", "avg_monthly_salary", "avg_daily_salary", "total_amount") VALUES
(3,  '2026-06-15', '2026-07-01', '2026-07-14', 14, 3000.00, 102.39, 1433.46),
(4,  '2026-05-20', '2026-06-10', '2026-06-23', 14, 2200.00, 75.09, 1051.26),
(8,  '2026-04-01', '2026-04-15', '2026-05-05', 21, 2200.00, 75.09, 1576.89),
(11, '2026-07-10', '2026-08-01', '2026-08-14', 14, 2100.00, 71.67, 1003.38),
(15, '2026-02-01', '2026-02-20', '2026-03-06', 15, 1300.00, 44.37, 665.55),
(20, '2026-03-15', '2026-04-01', '2026-04-10', 10, 1200.00, 40.96, 409.60),
(27, '2026-05-01', '2026-05-15', '2026-05-28', 14, 2200.00, 75.09, 1051.26),
(30, '2026-08-01', '2026-08-10', '2026-08-23', 14, 1600.00, 54.61, 764.54),
(35, '2026-01-10', '2026-02-01', '2026-02-14', 14, 1800.00, 61.43, 860.02),
(38, '2026-06-01', '2026-06-15', '2026-06-28', 14, 1300.00, 44.37, 621.18),
(42, '2026-04-20', '2026-05-01', '2026-05-21', 21, 2100.00, 71.67, 1505.07),
(44, '2026-07-20', '2026-08-01', '2026-08-21', 21, 2000.00, 68.26, 1433.46),
(46, '2026-03-01', '2026-03-10', '2026-03-23', 14, 1600.00, 54.61, 764.54),
(48, '2026-02-15', '2026-03-01', '2026-03-14', 14, 2200.00, 75.09, 1051.26),
(50, '2026-05-05', '2026-06-01', '2026-06-14', 14, 1700.00, 58.02, 812.28);

-- =====================================================
-- 6. Больничные (sick_leave_journal) для 8 сотрудников
-- =====================================================

INSERT INTO "sick_leave_journal" ("emp_id", "calc_date", "start_date", "end_date", "days_count", "avg_daily_salary", "experience_years", "payment_percent", "total_amount") VALUES
(5,  '2026-02-10', '2026-02-10', '2026-02-15', 6,  56.66,  6, 60.0, 203.98),
(9,  '2026-03-05', '2026-03-05', '2026-03-09', 5,  46.67,  4, 60.0, 140.01),
(12, '2026-04-12', '2026-04-12', '2026-04-18', 7,  58.02,  5, 60.0, 243.68),
(18, '2026-05-20', '2026-05-20', '2026-05-25', 6,  37.54,  2, 60.0, 135.14),
(25, '2026-06-01', '2026-06-01', '2026-06-07', 7,  49.49,  0, 60.0, 207.86),
(29, '2026-07-15', '2026-07-15', '2026-07-20', 6,  58.02,  5, 60.0, 208.87),
(33, '2026-08-01', '2026-08-01', '2026-08-08', 8,  44.37,  1, 60.0, 212.98),
(40, '2026-03-22', '2026-03-22', '2026-03-28', 7,  37.54,  0, 60.0, 157.67);

-- =====================================================
-- 7. Завершение транзакции
-- =====================================================

COMMIT;