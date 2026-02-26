-- Insert 100 products with realistic data (prices match order_items unit_price formula)
INSERT INTO products (product_id, product_name, category, price, cost, created_at)
SELECT
	n AS product_id,
	CONCAT('Product ', n) AS product_name,
	ELT((n % 6) + 1,
		'Electronics','Home','Apparel','Sports','Beauty','Grocery'
	) AS category,
	ROUND(10 + (n % 50) * 1.25, 2) AS price,
	ROUND((10 + (n % 50) * 1.25) * 0.6, 2) AS cost,
	CURRENT_DATE - INTERVAL (n % 365) DAY AS created_at
FROM (
	SELECT a.n + (b.n * 10) + 1 AS n
	FROM (
		SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
		UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
	) a
	CROSS JOIN (
		SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
		UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
	) b
) seq
WHERE n <= 100;

