CREATE TABLE IF NOT EXISTS "sick_leave_rates" (
    "id" INTEGER PRIMARY KEY,
	"min_years" INTEGER,
	"max_years" INTEGER,
    "percent" REAL
);