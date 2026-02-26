-- Insert 100 orders with realistic data (including NULL status values)
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
SELECT
	n AS order_id,
	CASE
		WHEN n <= 30 THEN ((n - 1) % 5) + 1
		ELSE ((n - 1) % 90) + 1
	END AS customer_id,
	CURRENT_DATE - INTERVAL (n * 4) DAY AS order_date,
	CASE
		WHEN n % 10 = 0 THEN NULL
		ELSE ELT((n % 4) + 1, 'Pending','Shipped','Delivered','Cancelled')
	END AS status,
	ROUND(((n % 5) + 1) * (10 + (n % 50) * 1.25), 2) AS total_amount
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
WHERE n <= 100
ORDER BY n;

