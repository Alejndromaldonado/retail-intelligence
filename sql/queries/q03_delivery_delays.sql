-- q03_delivery_delays.sql
-- Retrasos por estado
SELECT
    c.customer_state AS state,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN f.is_late THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN f.is_late THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct,
    AVG(f.delivery_days) AS avg_delivery_days
FROM fact_orders f
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE f.order_status = 'delivered'
GROUP BY 1
ORDER BY late_pct DESC;
