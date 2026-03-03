DROP TABLE IF EXISTS "settings";

CREATE TABLE "settings" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "sys_name" TEXT UNIQUE,      -- Для кода (например, 'TAX_INCOME')
    "display_name" TEXT,         -- Для бухгалтера ('Подоходный налог')
    "calc_type" INTEGER,         -- 1 = Начисление (+), 2 = Удержание (-)
    "key_value" REAL,            -- Процент или сумма (10.0, 75.0)
    "is_active" INTEGER DEFAULT 1 -- 1 = Включено, 0 = Выключено
);

-- И сразу заполним её базовыми правилами!
INSERT INTO "settings" ("sys_name", "display_name", "calc_type", "key_value", "is_active") VALUES 
('TAX_INCOME', 'Подоходный налог', 2, 10.0, 1),
('PENSION_FUND', 'Пенсионный фонд', 2, 2.0, 1),
('DEP_DEDUCTION', 'Вычет на иждивенца (сумма)', 2, 50.0, 1),
('BONUS_ROTATION', 'Надбавка за вахту', 1, 75.0, 1),
('BONUS_NIGHT', 'Ночные смены', 1, 20.0, 1),
('BONUS_HOLIDAY', 'Праздничные дни', 1, 100.0, 1),
('BONUS_HAZARD', 'Вредные условия труда', 1, 15.0, 1);