create or replace view product_revenue_order_table as
select 
	oi.order_id,oi.product_id, oi.quantity, oi.unit_price,
	p.product_name,p.category,
	o.status, o.total_amount, o.order_date,
    (oi.line_total * (p.price - p.cost) / p.price) as total_revenue
from order_items oi 
join products p on oi.product_id = p.product_id 
join orders o on oi.order_id = o.order_id 
where o.status in ("pending","Shipped","Delivered" );

create or replace view customer_order_table as
SELECT
c.customer_id,
c.first_name,
c.last_name,
c.email,
c.phone,
c.city ,
o.order_id,
o.total_amount
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;