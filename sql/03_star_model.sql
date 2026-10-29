-- ============================================================
-- 03_star_model.sql
-- Modelo estrella para Retail Intelligence (Olist)
-- Ejecutar sobre DuckDB o PostgreSQL
-- ============================================================

-- Dimensiones
CREATE TABLE IF NOT EXISTS dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR,
    quarter INT,
    day_of_week INT,
    is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_city VARCHAR,
    customer_state VARCHAR,
    customer_zip_code_prefix VARCHAR
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_key VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_category_name_english VARCHAR,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_key VARCHAR PRIMARY KEY,
    seller_city VARCHAR,
    seller_state VARCHAR
);

CREATE TABLE IF NOT EXISTS dim_geography (
    geo_key VARCHAR PRIMARY KEY,
    zip_code_prefix VARCHAR,
    lat DOUBLE,
    lng DOUBLE,
    city VARCHAR,
    state VARCHAR
);

-- Hechos
CREATE TABLE IF NOT EXISTS fact_orders (
    order_id VARCHAR PRIMARY KEY,
    customer_key VARCHAR REFERENCES dim_customer(customer_key),
    date_key INT REFERENCES dim_date(date_key),
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    delivery_days INT,
    is_late BOOLEAN
);

CREATE TABLE IF NOT EXISTS fact_order_items (
    order_item_id INT,
    order_id VARCHAR REFERENCES fact_orders(order_id),
    product_key VARCHAR REFERENCES dim_product(product_key),
    seller_key VARCHAR REFERENCES dim_seller(seller_key),
    price DOUBLE,
    freight_value DOUBLE,
    total_value DOUBLE
);

CREATE TABLE IF NOT EXISTS fact_payments (
    payment_id INT,
    order_id VARCHAR REFERENCES fact_orders(order_id),
    payment_type VARCHAR,
    payment_installments INT,
    payment_value DOUBLE
);

CREATE TABLE IF NOT EXISTS fact_reviews (
    review_id VARCHAR PRIMARY KEY,
    order_id VARCHAR REFERENCES fact_orders(order_id),
    review_score INT,
    review_comment_title VARCHAR,
    review_comment_message VARCHAR,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
