-- Insert 100 return events linked to order items
INSERT INTO returns (
	order_item_id,
	order_id,
	product_id,
	customer_id,
	return_reason,
	return_status,
	refund_amount,
	returned_at,
	processed_at
)
SELECT
	r.order_item_id,
	r.order_id,
	r.product_id,
	r.customer_id,
	r.return_reason,
	r.return_status,
	r.refund_amount,
	r.returned_at,
	CASE
		WHEN r.return_status IN ('Approved', 'Rejected', 'Refunded')
			THEN DATE_ADD(r.returned_at, INTERVAL (r.order_item_id % 10) DAY)
		ELSE NULL
	END AS processed_at
FROM (
	SELECT
		oi.order_item_id,
		oi.order_id,
		oi.product_id,
		o.customer_id,
		ELT((oi.order_item_id % 4) + 1,
			'Defective', 'Wrong item', 'Changed mind', 'Damaged'
		) AS return_reason,
		ELT((oi.order_item_id % 4) + 1,
			'Pending', 'Approved', 'Rejected', 'Refunded'
		) AS return_status,
		CASE
			WHEN ELT((oi.order_item_id % 4) + 1, 'Pending', 'Approved', 'Rejected', 'Refunded') = 'Rejected' THEN 0.00
			ELSE ROUND(
				LEAST(oi.line_total, oi.line_total * (0.5 + (oi.order_item_id % 4) * 0.1)),
				2
			)
		END AS refund_amount,
		GREATEST(
			DATE_SUB(CURRENT_TIMESTAMP, INTERVAL (oi.order_item_id * 4) DAY),
			o.order_date
		) AS returned_at
	FROM order_items oi
	JOIN orders o ON o.order_id = oi.order_id
	WHERE oi.order_item_id <= 100
) r;
