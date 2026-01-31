CREATE DATABASE star_schema;
USE star_schema;

CREATE TABLE staging_orders (
	row_id INT,
    order_id VARCHAR(20),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    ship_mode VARCHAR(50),
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    postal_code VARCHAR(20),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2)
);

SELECT COUNT(*) FROM staging_orders;
SELECT * FROM staging_orders LIMIT 5;

CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE dim_date (
    date_key INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE,
    year INT,
    month INT,
    day INT
);

CREATE TABLE dim_region (
    region_key INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(50),
    region VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE fact_sales (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_key INT,
    product_key INT,
    date_key INT,
    region_key INT,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2),

    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (region_key) REFERENCES dim_region(region_key)
);

INSERT INTO dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT customer_id, customer_name, segment
FROM staging_orders;

INSERT INTO dim_product (product_id, product_name, category, sub_category)
SELECT DISTINCT product_id, product_name, category, sub_category
FROM staging_orders;

INSERT INTO dim_date (order_date, year, month, day)
SELECT DISTINCT
    parsed_date,
    YEAR(parsed_date),
    MONTH(parsed_date),
    DAY(parsed_date)
FROM (
    SELECT
        CASE
            -- MM-DD-YYYY (month ≤ 12)
            WHEN CAST(SUBSTRING_INDEX(order_date, '-', 1) AS UNSIGNED) <= 12
            THEN STR_TO_DATE(order_date, '%m-%d-%Y')

            -- DD-MM-YYYY (day > 12)
            ELSE STR_TO_DATE(order_date, '%d-%m-%Y')
        END AS parsed_date
    FROM staging_orders
    WHERE order_date IS NOT NULL
) t
WHERE parsed_date IS NOT NULL;

INSERT INTO dim_region (country, region, state, city)
SELECT DISTINCT country, region, state, city
FROM staging_orders;

INSERT INTO fact_sales (
    customer_key, product_key, date_key, region_key,
    sales, quantity, discount, profit
)
SELECT
    dc.customer_key,
    dp.product_key,
    dd.date_key,
    dr.region_key,
    s.sales,
    s.quantity,
    s.discount,
    s.profit
FROM staging_orders s
JOIN dim_customer dc 
    ON s.customer_id = dc.customer_id
JOIN dim_product dp 
    ON s.product_id = dp.product_id
JOIN dim_region dr 
    ON s.country = dr.country
   AND s.region = dr.region
   AND s.state = dr.state
   AND s.city = dr.city
JOIN dim_date dd
    ON dd.order_date =
       CASE
           -- MM-DD-YYYY
           WHEN CAST(SUBSTRING_INDEX(s.order_date, '-', 1) AS UNSIGNED) <= 12
           THEN STR_TO_DATE(s.order_date, '%m-%d-%Y')

           -- DD-MM-YYYY
           ELSE STR_TO_DATE(s.order_date, '%d-%m-%Y')
       END;

CREATE INDEX idx_fact_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_product ON fact_sales(product_key);
CREATE INDEX idx_fact_date ON fact_sales(date_key);
CREATE INDEX idx_fact_region ON fact_sales(region_key);

SELECT
    dp.category,
    SUM(fs.sales) AS total_sales,
    SUM(fs.profit) AS total_profit
FROM fact_sales fs
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_sales DESC;

-- Compare counts
SELECT COUNT(*) FROM staging_orders;
SELECT COUNT(*) FROM fact_sales;

-- Missing foreign keys
SELECT COUNT(*)
FROM fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL
   OR date_key IS NULL
   OR region_key IS NULL;









