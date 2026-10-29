-- q02_top_categories.sql
-- Top categorías por ingresos y rating
SELECT
    p.product_category_name_english AS category,
    COUNT(DISTINCT i.order_id) AS orders,
    SUM(i.total_value) AS revenue,
    AVG(r.review_score) AS avg_review,
    AVG(f.delivery_days) AS avg_delivery_days
FROM fact_order_items i
JOIN dim_product p ON i.product_key = p.product_key
JOIN fact_orders f ON i.order_id = f.order_id
LEFT JOIN fact_reviews r ON f.order_id = r.order_id
GROUP BY 1
ORDER BY revenue DESC
LIMIT 15;
