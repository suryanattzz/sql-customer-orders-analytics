-- Insert inventory records for all products
INSERT INTO product_inventory (
	product_id,
	stock_quantity,
	reserved_quantity,
	restock_threshold,
	restock_quantity,
	unit_cost,
	last_restocked_at,
	updated_at
)
SELECT
	p.product_id,
	CASE
		WHEN p.product_id % 4 = 0 THEN (20 + (p.product_id % 15)) - 2
		ELSE (20 + (p.product_id % 15)) + (p.product_id % 30)
	END AS stock_quantity,
	p.product_id % 5 AS reserved_quantity,
	20 + (p.product_id % 15) AS restock_threshold,
	40 + (p.product_id % 20) AS restock_quantity,
	p.cost AS unit_cost,
	CASE
		WHEN p.product_id % 5 = 0 THEN NULL
		ELSE DATE_SUB(CURRENT_TIMESTAMP, INTERVAL (p.product_id % 120) DAY)
	END AS last_restocked_at,
	CURRENT_TIMESTAMP AS updated_at
FROM products p
WHERE p.product_id <= 100;
