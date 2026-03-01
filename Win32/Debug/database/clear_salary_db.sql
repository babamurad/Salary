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
	"year"	INTEGER,
	"month"	INTEGER,
	"working_days"	INTEGER,
	"working_hours"	INTEGER,
	PRIMARY KEY("year","month")
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
CREATE UNIQUE INDEX IF NOT EXISTS "idx_salary_history_emp_period" ON "salary_history" (
	"emp_id",
	"period_date"
);
COMMIT;
