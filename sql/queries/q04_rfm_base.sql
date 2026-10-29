-- q04_rfm_base.sql
-- Base RFM para segmentación de clientes
WITH last_date AS (SELECT MAX(order_purchase_timestamp) AS max_date FROM fact_orders),
rfm AS (
    SELECT
        f.customer_key,
        DATE_DIFF('day', MAX(f.order_purchase_timestamp), (SELECT max_date FROM last_date)) AS recency,
        COUNT(DISTINCT f.order_id) AS frequency,
        SUM(i.total_value) AS monetary
    FROM fact_orders f
    JOIN fact_order_items i ON f.order_id = i.order_id
    WHERE f.order_status = 'delivered'
    GROUP BY 1
)
SELECT * FROM rfm;
