-- Insert 100 order items (one per order)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total)
SELECT
	n AS order_id,
	n AS product_id,
	(n % 5) + 1 AS quantity,
	ROUND(10 + (n % 50) * 1.25, 2) AS unit_price,
	ROUND(((n % 5) + 1) * (10 + (n % 50) * 1.25), 2) AS line_total
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

