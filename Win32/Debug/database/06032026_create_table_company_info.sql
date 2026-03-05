CREATE TABLE "company_info" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "key_name" TEXT UNIQUE NOT NULL,
    "display_name" TEXT NOT NULL,
    "key_value" TEXT
);

INSERT INTO "company_info" ("key_name", "display_name", "key_value") VALUES 
('company_name', 'Название компании', 'ХО "TM Tourism"'),
('address', 'Юридический адрес', 'Туркменистан, г. Туркменабад'),
('phone', 'Телефон / WhatsApp', '+99365865881'),
('email', 'Электронная почта', 'babamurad2010@yandex.ru'),
('website', 'Веб-сайт', 'tmtourism.com'),
('bank_name', 'Наименование банка', ''),
('bank_account', 'Расчетный счет', ''),
('director_title', 'Должность руководителя', 'Директор'),
('director_fio', 'Ф.И.О. руководителя', ''),
('accountant_title', 'Должность гл. бухгалтера', 'Главный бухгалтер'),
('accountant_fio', 'Ф.И.О. гл. бухгалтера', '');