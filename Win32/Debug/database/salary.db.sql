BEGIN TRANSACTION;
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
CREATE TABLE IF NOT EXISTS "settings" (
	"key_name"	TEXT,
	"key_value"	REAL,
	PRIMARY KEY("key_name")
);
CREATE TABLE IF NOT EXISTS "sick_leave_rates" (
	"min_years"	INTEGER,
	"percent"	REAL,
	PRIMARY KEY("min_years")
);
INSERT INTO "departments" VALUES (1,'Администрация');
INSERT INTO "departments" VALUES (2,'Бухгалтерия');
INSERT INTO "departments" VALUES (3,'Отдел кадров');
INSERT INTO "departments" VALUES (4,'Производственный цех');
INSERT INTO "departments" VALUES (5,'Транспортный отдел');
INSERT INTO "departments" VALUES (6,'Склад');
INSERT INTO "positions" VALUES (1,'Директор','АУП');
INSERT INTO "positions" VALUES (2,'Главный бухгалтер','АУП');
INSERT INTO "positions" VALUES (3,'Бухгалтер','АУП');
INSERT INTO "positions" VALUES (4,'Начальник цеха','Производство');
INSERT INTO "positions" VALUES (5,'Мастер','Производство');
INSERT INTO "positions" VALUES (6,'Водитель','Транспорт');
INSERT INTO "positions" VALUES (7,'Кладовщик','Склад');
INSERT INTO "settings" VALUES ('income_tax',10.0);
INSERT INTO "settings" VALUES ('pension_fund',2.0);
INSERT INTO "settings" VALUES ('min_salary_limit',0.0);
COMMIT;
