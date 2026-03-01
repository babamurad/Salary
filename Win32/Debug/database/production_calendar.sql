CREATE TABLE IF NOT EXISTS production_calendar (
    year INTEGER,
    month INTEGER,
    working_days INTEGER,
    working_hours INTEGER,
    PRIMARY KEY (year, month)
);

INSERT OR IGNORE INTO production_calendar (year, month, working_days, working_hours) VALUES (2026, 1, 20, 160);
INSERT OR IGNORE INTO production_calendar (year, month, working_days, working_hours) VALUES (2026, 2, 19, 152);