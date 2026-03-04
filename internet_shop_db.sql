-- ============================================================
--  База данных: Интернет-магазин
--  СУБД: PostgreSQL 16
--  Студент: Медведев Богдан Александрович, ИСП-33
--  Учебная практика ПМ 11, март 2026
-- ============================================================

-- Создать и подключиться к базе данных
-- (выполнить вне транзакции, или через psql):
-- CREATE DATABASE internet_shop ENCODING 'UTF8';
-- \c internet_shop

-- ============================================================
-- 1. УДАЛЕНИЕ ОБЪЕКТОВ (если существуют)
-- ============================================================

DROP VIEW  IF EXISTS v_sales_report  CASCADE;
DROP VIEW  IF EXISTS v_stock_status  CASCADE;
DROP TABLE IF EXISTS order_items     CASCADE;
DROP TABLE IF EXISTS orders          CASCADE;
DROP TABLE IF EXISTS products        CASCADE;
DROP TABLE IF EXISTS customers       CASCADE;
DROP TABLE IF EXISTS suppliers       CASCADE;
DROP TABLE IF EXISTS categories      CASCADE;

-- ============================================================
-- 2. СОЗДАНИЕ ТАБЛИЦ
-- ============================================================

-- Категории товаров
CREATE TABLE categories (
    id          SERIAL       PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Поставщики
CREATE TABLE suppliers (
    id           SERIAL       PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    phone        VARCHAR(20),
    email        VARCHAR(100) UNIQUE
);

-- Товары
CREATE TABLE products (
    id             SERIAL          PRIMARY KEY,
    name           VARCHAR(200)    NOT NULL,
    description    TEXT,
    price          DECIMAL(10, 2)  NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER         NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id    INTEGER         REFERENCES categories(id) ON DELETE SET NULL,
    supplier_id    INTEGER         REFERENCES suppliers(id)  ON DELETE SET NULL
);

-- Покупатели
CREATE TABLE customers (
    id        SERIAL       PRIMARY KEY,
    full_name VARCHAR(200) NOT NULL,
    email     VARCHAR(100) NOT NULL UNIQUE,
    phone     VARCHAR(20),
    address   TEXT
);

-- Заказы
CREATE TABLE orders (
    id          SERIAL      PRIMARY KEY,
    customer_id INTEGER     NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    order_date  DATE        NOT NULL DEFAULT CURRENT_DATE,
    status      VARCHAR(30) NOT NULL DEFAULT 'new'
                            CHECK (status IN ('new','processing','shipped','completed','cancelled'))
);

-- Состав заказа
CREATE TABLE order_items (
    id          SERIAL         PRIMARY KEY,
    order_id    INTEGER        NOT NULL REFERENCES orders(id)   ON DELETE CASCADE,
    product_id  INTEGER        NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity    INTEGER        NOT NULL CHECK (quantity > 0),
    unit_price  DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0)
);

-- ============================================================
-- 3. ИНДЕКСЫ
-- ============================================================

CREATE INDEX idx_products_category    ON products(category_id);
CREATE INDEX idx_products_supplier    ON products(supplier_id);
CREATE INDEX idx_orders_customer      ON orders(customer_id);
CREATE INDEX idx_items_order          ON order_items(order_id);
CREATE INDEX idx_items_product        ON order_items(product_id);
CREATE INDEX idx_orders_date          ON orders(order_date);
CREATE INDEX idx_orders_status        ON orders(status);

-- ============================================================
-- 4. ТЕСТОВЫЕ ДАННЫЕ
-- ============================================================

INSERT INTO categories (name, description) VALUES
    ('Электроника',  'Смартфоны, ноутбуки, планшеты, аксессуары'),
    ('Одежда',       'Мужская и женская одежда, аксессуары'),
    ('Книги',        'Художественная и учебная литература'),
    ('Спорт',        'Спортивные товары и инвентарь'),
    ('Дом и сад',    'Товары для дома, сада и дачи');

INSERT INTO suppliers (company_name, phone, email) VALUES
    ('ТехноПоставки',   '+7-900-111-22-33', 'info@techno.ru'),
    ('МодаОпт',         '+7-900-444-55-66', 'opt@moda.ru'),
    ('КнигоМир',        '+7-900-777-88-99', 'books@knigomir.ru'),
    ('СпортТрейд',      '+7-900-222-33-44', 'trade@sport.ru');

INSERT INTO products (name, description, price, stock_quantity, category_id, supplier_id) VALUES
    ('Samsung Galaxy A55',     '6.6 дюймов, 8GB RAM, 256GB',        35000.00,  50, 1, 1),
    ('Lenovo IdeaPad 3',       '15.6 дюймов, Core i5, 16GB RAM',    65000.00,  20, 1, 1),
    ('Apple AirPods Pro 2',    'Активное шумоподавление, MagSafe',  22000.00,  35, 1, 1),
    ('Планшет Xiaomi Pad 6',   '11 дюймов, 8GB RAM, 256GB',         28000.00,  15, 1, 1),
    ('Футболка хлопковая',     '100% хлопок, размеры S-XXL',          1200.00, 200, 2, 2),
    ('Джинсы классические',    'Прямой крой, размеры 28-38',          3500.00,  80, 2, 2),
    ('Толстовка с капюшоном',  'Тёплая, унисекс',                    2800.00,  60, 2, 2),
    ('Учебник PostgreSQL 16',  'Полное руководство по СУБД',           890.00, 100, 3, 3),
    ('Python для начинающих',  'Введение в программирование',         750.00,  75, 3, 3),
    ('Чистый код',             'Роберт Мартин, бестселлер',          1100.00,  40, 3, 3),
    ('Гантели 5 кг (пара)',    'Литые, покрытие резина',             2500.00,  25, 4, 4),
    ('Коврик для йоги',        'NBR 10мм, 183x61 см',                1800.00,  45, 4, 4);

INSERT INTO customers (full_name, email, phone, address) VALUES
    ('Иванов Иван Иванович',      'ivan@mail.ru',    '+7-900-100-00-01', 'Хабаровск, ул. Ленина, 1'),
    ('Петрова Анна Сергеевна',    'anna@gmail.com',  '+7-900-200-00-02', 'Хабаровск, пр. Мира, 15'),
    ('Сидоров Дмитрий Олегович',  'dima@yandex.ru',  '+7-900-300-00-03', 'Хабаровск, ул. Карла Маркса, 7'),
    ('Козлова Елена Павловна',    'elena@mail.ru',   '+7-900-400-00-04', 'Хабаровск, ул. Пушкина, 22'),
    ('Новиков Алексей Михайлович','alex@gmail.com',  '+7-900-500-00-05', 'Комсомольск-на-Амуре, пр. Октябрьский, 3');

INSERT INTO orders (customer_id, order_date, status) VALUES
    (1, '2026-03-01', 'completed'),
    (2, '2026-03-03', 'new'),
    (3, '2026-03-05', 'processing'),
    (1, '2026-03-07', 'shipped'),
    (4, '2026-03-10', 'new'),
    (5, '2026-03-11', 'completed');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1,  1, 35000.00),
    (1, 8,  2,   890.00),
    (2, 5,  3,  1200.00),
    (2, 7,  1,  2800.00),
    (3, 2,  1, 65000.00),
    (3, 9,  1,   750.00),
    (4, 3,  1, 22000.00),
    (4, 6,  2,  3500.00),
    (5, 11, 2,  2500.00),
    (5, 12, 1,  1800.00),
    (6, 10, 3,  1100.00),
    (6, 4,  1, 28000.00);

-- ============================================================
-- 5. ПРЕДСТАВЛЕНИЯ (VIEW)
-- ============================================================

-- Отчёт по продажам
CREATE OR REPLACE VIEW v_sales_report AS
SELECT
    o.id            AS order_id,
    cu.full_name    AS customer,
    o.order_date,
    o.status,
    p.name          AS product,
    c.name          AS category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders       o
JOIN customers    cu ON o.customer_id  = cu.id
JOIN order_items  oi ON o.id           = oi.order_id
JOIN products     p  ON oi.product_id  = p.id
JOIN categories   c  ON p.category_id  = c.id;

-- Состояние склада
CREATE OR REPLACE VIEW v_stock_status AS
SELECT
    p.name          AS product,
    c.name          AS category,
    s.company_name  AS supplier,
    p.price,
    p.stock_quantity,
    CASE
        WHEN p.stock_quantity = 0     THEN 'Нет в наличии'
        WHEN p.stock_quantity < 10    THEN 'Заканчивается'
        ELSE                               'В наличии'
    END             AS availability
FROM products   p
JOIN categories c ON p.category_id = c.id
LEFT JOIN suppliers s ON p.supplier_id = s.id;

-- ============================================================
-- 6. ХРАНИМЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
-- ============================================================

-- Процедура создания заказа
CREATE OR REPLACE PROCEDURE create_order(
    p_customer_id INTEGER,
    p_product_id  INTEGER,
    p_quantity    INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_order_id INTEGER;
    v_price    DECIMAL(10, 2);
    v_stock    INTEGER;
BEGIN
    -- Проверяем наличие товара
    SELECT price, stock_quantity
    INTO   v_price, v_stock
    FROM   products
    WHERE  id = p_product_id
    FOR UPDATE;

    IF v_stock < p_quantity THEN
        RAISE EXCEPTION 'Недостаточно товара на складе: есть %, запрошено %',
              v_stock, p_quantity;
    END IF;

    -- Создаём заказ
    INSERT INTO orders (customer_id, status)
    VALUES (p_customer_id, 'new')
    RETURNING id INTO v_order_id;

    -- Добавляем позицию
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_quantity, v_price);

    -- Уменьшаем остаток
    UPDATE products
    SET    stock_quantity = stock_quantity - p_quantity
    WHERE  id = p_product_id;

    RAISE NOTICE 'Заказ №% успешно создан', v_order_id;
END;
$$;

-- Функция: итоговая сумма заказа
CREATE OR REPLACE FUNCTION get_order_total(p_order_id INTEGER)
RETURNS DECIMAL(10, 2)
LANGUAGE plpgsql AS $$
DECLARE
    v_total DECIMAL(10, 2);
BEGIN
    SELECT SUM(quantity * unit_price)
    INTO   v_total
    FROM   order_items
    WHERE  order_id = p_order_id;
    RETURN COALESCE(v_total, 0);
END;
$$;

-- Функция: проверка наличия товара
CREATE OR REPLACE FUNCTION is_product_available(
    p_product_id INTEGER,
    p_quantity   INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
DECLARE
    v_stock INTEGER;
BEGIN
    SELECT stock_quantity INTO v_stock
    FROM   products
    WHERE  id = p_product_id;
    RETURN COALESCE(v_stock, 0) >= p_quantity;
END;
$$;

-- ============================================================
-- 7. КОНТРОЛЬНЫЕ ЗАПРОСЫ (проверка данных)
-- ============================================================

-- Все товары с категорией
SELECT p.name, p.price, p.stock_quantity, c.name AS category
FROM   products p JOIN categories c ON p.category_id = c.id
ORDER  BY c.name, p.name;

-- Заказы с суммами
SELECT o.id, cu.full_name, o.order_date, o.status,
       get_order_total(o.id) AS total_amount
FROM   orders o JOIN customers cu ON o.customer_id = cu.id
ORDER  BY o.order_date;

-- Топ-5 продаваемых товаров
SELECT p.name, SUM(oi.quantity) AS total_sold
FROM   order_items oi JOIN products p ON oi.product_id = p.id
GROUP  BY p.name
ORDER  BY total_sold DESC
LIMIT  5;

-- Состояние склада
SELECT * FROM v_stock_status ORDER BY availability, product;

-- Отчёт по продажам (завершённые заказы)
SELECT * FROM v_sales_report WHERE status = 'completed';

-- Проверить наличие товара
SELECT is_product_available(1, 5) AS "Samsung доступен (5 шт)";

-- Создать тестовый заказ
CALL create_order(2, 5, 2);  -- Петрова заказывает 2 футболки
