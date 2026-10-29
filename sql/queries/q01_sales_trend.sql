-- q01_sales_trend.sql
-- Tendencia de ventas mensual
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT f.order_id) AS orders,
    SUM(i.total_value) AS revenue,
    AVG(i.total_value) AS avg_ticket
FROM fact_orders f
JOIN fact_order_items i ON f.order_id = i.order_id
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status = 'delivered'
GROUP BY 1,2,3
ORDER BY 1,2;
