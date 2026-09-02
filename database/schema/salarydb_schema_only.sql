CREATE TABLE IF NOT EXISTS "closed_periods" (
	"period_str"	TEXT,
	PRIMARY KEY("period_str")
);
CREATE TABLE IF NOT EXISTS "company_info" (
	"id"	INTEGER,
	"key_name"	TEXT NOT NULL UNIQUE,
	"display_name"	TEXT NOT NULL,
	"key_value"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
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
	"pension_rate"	REAL DEFAULT 2.0,
	"pay_type"	INTEGER DEFAULT 0,
	"schedule_type"	INTEGER DEFAULT 0,
	"hourly_rate"	REAL DEFAULT 0,
	"wage_type"	INTEGER NOT NULL DEFAULT 0,
	"is_rotation"	INTEGER NOT NULL DEFAULT 0,
	"work_fraction"	REAL DEFAULT 1.0,
	"is_tax_exempt"	INTEGER DEFAULT 0,
	"class_rank"	INTEGER DEFAULT 0,
	"trade_union"	INTEGER DEFAULT 0,
	"alimony_percent"	REAL DEFAULT 0.0,
	"bank_account"	TEXT,
	"sick_leave_percent"	INTEGER DEFAULT 60,
	"birth_date"	DATE,
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
	"union_amount"	CURRENCY DEFAULT 0,
	"alimony_amount"	CURRENCY DEFAULT 0,
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
	"id"	INTEGER,
	"sys_name"	TEXT UNIQUE,
	"display_name"	TEXT,
	"calc_type"	INTEGER,
	"key_value"	REAL,
	"is_active"	INTEGER DEFAULT 1,
	PRIMARY KEY("id" AUTOINCREMENT)
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
	"id"	INTEGER,
	"min_years"	INTEGER,
	"max_years"	INTEGER,
	"percent"	REAL,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "timesheet" (
	"id"	INTEGER,
	"emp_id"	INTEGER NOT NULL,
	"work_date"	DATE NOT NULL,
	"hours_worked"	REAL DEFAULT 0,
	"status_code"	TEXT(5) DEFAULT 'Я',
	"notes"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("emp_id") REFERENCES "employees"("id")
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
CREATE INDEX IF NOT EXISTS "idx_timesheet_date" ON "timesheet" (
	"work_date"
);
CREATE INDEX IF NOT EXISTS "idx_timesheet_emp_date" ON "timesheet" (
	"emp_id",
	"work_date"
);
