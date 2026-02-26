-- Link promotions to orders (one promo per order)
INSERT INTO order_promotions (
	order_id,
	promo_id,
	discount_applied,
	applied_at
)
SELECT
	o.order_id,
	p.promo_id,
	CASE
		WHEN o.total_amount >= p.min_order_value THEN
			CASE
				WHEN p.discount_type = 'PERCENTAGE'
					THEN ROUND(o.total_amount * (p.discount_value / 100), 2)
				ELSE ROUND(LEAST(p.discount_value, o.total_amount), 2)
			END
		ELSE 0.00
	END AS discount_applied,
	DATE_ADD(o.order_date, INTERVAL (o.order_id % 3) DAY) AS applied_at
FROM orders o
JOIN promotions p ON p.promo_id = o.order_id
WHERE o.order_id <= 100;
