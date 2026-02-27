CREATE TABLE IF NOT EXISTS "production_calendar" (
    "cal_date" DATE PRIMARY KEY,
    "day_type" INTEGER, -- 0-праздник, 1-выходной, 2-рабочий перенос
    "description" TEXT
);
