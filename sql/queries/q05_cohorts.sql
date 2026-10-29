-- q05_cohorts.sql
-- Cohortes de retención
WITH first_purchase AS (
    SELECT customer_key, DATE_TRUNC('month', MIN(order_purchase_timestamp)) AS cohort_month
    FROM fact_orders WHERE order_status='delivered' GROUP BY 1
),
activity AS (
    SELECT f.customer_key, DATE_TRUNC('month', f.order_purchase_timestamp) AS activity_month
    FROM fact_orders f WHERE f.order_status='delivered'
)
SELECT
    fp.cohort_month,
    DATE_DIFF('month', fp.cohort_month, a.activity_month) AS month_number,
    COUNT(DISTINCT a.customer_key) AS customers
FROM first_purchase fp
JOIN activity a ON fp.customer_key = a.customer_key
GROUP BY 1,2
ORDER BY 1,2;
