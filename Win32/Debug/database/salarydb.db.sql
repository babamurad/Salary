BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "closed_periods" (
	"period_str"	TEXT,
	PRIMARY KEY("period_str")
);
CREATE TABLE IF NOT EXISTS "const_settings" (
	"key_name"	TEXT,
	"key_value"	REAL,
	PRIMARY KEY("key_name")
);
CREATE TABLE IF NOT EXISTS "departments" (
	"id"	INTEGER,
	"dept_name"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "emp_adjustments" (
	"emp_id"	INTEGER,
	"adj_name"	TEXT,
	"adj_value"	REAL,
	"is_percent"	BOOLEAN,
	FOREIGN KEY("emp_id") REFERENCES "employees"("id")
);
CREATE TABLE IF NOT EXISTS "employees" (
	"id"	INTEGER,
	"tabno"	INTEGER NOT NULL UNIQUE,
	"fio"	TEXT NOT NULL,
	"hire_date"	DATE,
	"base_salary"	CURRENCY DEFAULT 0,
	"dept_id"	INTEGER,
	"pos_id"	INTEGER,
	"status"	INTEGER DEFAULT 1,
	"prior_exp_years"	INTEGER DEFAULT 0,
	"prior_exp_months"	INTEGER DEFAULT 0,
	"dependents_count"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("dept_id") REFERENCES "departments"("id") ON DELETE SET NULL,
	FOREIGN KEY("pos_id") REFERENCES "positions"("id") ON DELETE SET NULL
);
CREATE TABLE IF NOT EXISTS "payroll_journal" (
	"id"	INTEGER,
	"emp_id"	INTEGER,
	"period_date"	DATE,
	"gross_amount"	CURRENCY,
	"tax_amount"	CURRENCY,
	"pension_amount"	CURRENCY,
	"net_amount"	CURRENCY,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("emp_id") REFERENCES "employees"("id")
);
CREATE TABLE IF NOT EXISTS "positions" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL UNIQUE,
	"category"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "production_calendar" (
	"cal_date"	DATE,
	"day_type"	INTEGER,
	"description"	TEXT,
	PRIMARY KEY("cal_date")
);
CREATE TABLE IF NOT EXISTS "salary_history" (
	"id"	INTEGER,
	"emp_id"	INTEGER NOT NULL,
	"period_date"	DATE NOT NULL,
	"amount"	DECIMAL(18, 2) DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("emp_id") REFERENCES "employees"("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "settings" (
	"key_name"	TEXT,
	"key_value"	REAL,
	PRIMARY KEY("key_name")
);
CREATE TABLE IF NOT EXISTS "sick_leave_journal" (
	"id"	INTEGER,
	"emp_id"	INTEGER NOT NULL,
	"calc_date"	DATE NOT NULL,
	"start_date"	DATE NOT NULL,
	"end_date"	DATE NOT NULL,
	"days_count"	INTEGER NOT NULL,
	"avg_daily_salary"	DECIMAL(18, 2),
	"experience_years"	INTEGER,
	"payment_percent"	DECIMAL(5, 2),
	"total_amount"	DECIMAL(18, 2),
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("emp_id") REFERENCES "employees"("id")
);
CREATE TABLE IF NOT EXISTS "sick_leave_rates" (
	"min_years"	INTEGER,
	"percent"	REAL,
	PRIMARY KEY("min_years")
);
CREATE TABLE IF NOT EXISTS "vacation_journal" (
	"id"	INTEGER,
	"emp_id"	INTEGER NOT NULL,
	"calc_date"	DATE NOT NULL,
	"start_date"	DATE NOT NULL,
	"end_date"	DATE NOT NULL,
	"days_count"	INTEGER NOT NULL,
	"avg_monthly_salary"	DECIMAL(18, 2),
	"avg_daily_salary"	DECIMAL(18, 2),
	"total_amount"	DECIMAL(18, 2),
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("emp_id") REFERENCES "employees"("id")
);
INSERT INTO "departments" VALUES (1,'Администрация');
INSERT INTO "departments" VALUES (2,'Бухгалтерия');
INSERT INTO "departments" VALUES (3,'Отдел кадров');
INSERT INTO "departments" VALUES (4,'Производственный цех');
INSERT INTO "departments" VALUES (5,'Транспортный отдел');
INSERT INTO "departments" VALUES (6,'Склад');
INSERT INTO "departments" VALUES (7,'Техотдел');
INSERT INTO "employees" VALUES (1,1,'Ivan Ivanow','2020-01-01',1000,1,1,1,0,0,0);
INSERT INTO "employees" VALUES (2,2,'Петров','2020-01-01',1000,2,3,1,0,0,0);
INSERT INTO "payroll_journal" VALUES (37,1,'2026-03-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (38,2,'2026-03-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (39,1,'2026-04-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (40,2,'2026-04-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (41,1,'2026-01-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (42,2,'2026-01-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (43,1,'2026-05-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (44,2,'2026-05-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (45,1,'2026-02-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (46,2,'2026-02-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (47,1,'2026-08-01',1000,100,20,880);
INSERT INTO "payroll_journal" VALUES (48,2,'2026-08-01',1000,100,20,880);
INSERT INTO "positions" VALUES (1,'Директор','АУП');
INSERT INTO "positions" VALUES (2,'Главный бухгалтер','АУП');
INSERT INTO "positions" VALUES (3,'Бухгалтер','АУП');
INSERT INTO "positions" VALUES (4,'Начальник цеха','Производство');
INSERT INTO "positions" VALUES (5,'Мастер','Производство');
INSERT INTO "positions" VALUES (6,'Водитель','Транспорт');
INSERT INTO "positions" VALUES (7,'Кладовщик','Склад');
INSERT INTO "salary_history" VALUES (1,1,'2025-12-01',1000);
INSERT INTO "salary_history" VALUES (2,2,'2025-12-01',1200);
INSERT INTO "salary_history" VALUES (3,2,'2025-11-01',950);
INSERT INTO "salary_history" VALUES (4,2,'2025-10-01',980);
INSERT INTO "settings" VALUES ('income_tax',10.0);
INSERT INTO "settings" VALUES ('pension_fund',2.0);
INSERT INTO "settings" VALUES ('min_salary_limit',0.0);
INSERT INTO "settings" VALUES ('dependent_deduction',50.0);
INSERT INTO "sick_leave_journal" VALUES (1,1,'2026-03-01','2026-02-01','2026-02-05',5,33.6700336700337,6,60,101.010101010101);
INSERT INTO "sick_leave_journal" VALUES (2,2,'2026-03-01','2026-02-05','2026-02-08',4,35.13,6,60,84.31);
INSERT INTO "sick_leave_rates" VALUES (5,60.0);
INSERT INTO "sick_leave_rates" VALUES (7,80.0);
INSERT INTO "sick_leave_rates" VALUES (8,100.0);
INSERT INTO "vacation_journal" VALUES (4,1,'2026-03-01','2025-02-28','2026-02-28',366,166.666666666667,5.61167227833894,2053.87205387205);
INSERT INTO "vacation_journal" VALUES (5,1,'2026-03-01','2025-02-28','2026-02-28',366,166.666666666667,5.61167227833894,2053.87205387205);
INSERT INTO "vacation_journal" VALUES (6,2,'2026-03-01','2025-08-28','2026-02-28',185,183.333333333333,6.17283950617284,1141.97530864198);
INSERT INTO "vacation_journal" VALUES (7,2,'2026-03-01','2025-02-28','2026-02-28',366,260.833333333333,8.78226711560045,3214.30976430976);
CREATE UNIQUE INDEX IF NOT EXISTS "idx_salary_history_emp_period" ON "salary_history" (
	"emp_id",
	"period_date"
);
COMMIT;
