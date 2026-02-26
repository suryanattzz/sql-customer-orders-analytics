-- Insert 100 promotions with varied discount types and dates
INSERT INTO promotions (
	promo_code,
	promo_name,
	discount_type,
	discount_value,
	min_order_value,
	usage_limit,
	times_used,
	start_date,
	end_date,
	created_at
)
SELECT
	CONCAT('PROMO', LPAD(n, 3, '0')) AS promo_code,
	CONCAT('Campaign ', n) AS promo_name,
	CASE WHEN n % 2 = 0 THEN 'PERCENTAGE' ELSE 'FIXED_AMOUNT' END AS discount_type,
	CASE WHEN n % 2 = 0 THEN 5 + (n % 25) ELSE 5 + (n % 30) END AS discount_value,
	CASE WHEN n % 3 = 0 THEN 50 ELSE 0 END AS min_order_value,
	CASE WHEN n % 10 = 0 THEN NULL ELSE 100 + (n % 200) END AS usage_limit,
	n % 40 AS times_used,
	DATE_SUB(CURRENT_DATE, INTERVAL (n * 3) DAY) AS start_date,
	DATE_ADD(DATE_SUB(CURRENT_DATE, INTERVAL (n * 3) DAY), INTERVAL (30 + (n % 60)) DAY) AS end_date,
	DATE_SUB(CURRENT_TIMESTAMP, INTERVAL (n % 365) DAY) AS created_at
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
