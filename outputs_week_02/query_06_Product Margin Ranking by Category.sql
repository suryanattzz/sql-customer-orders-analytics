-- 6)Product Margin Ranking by Category
create or replace view profit_by_product as(
select 
p.product_id,
p.product_name,
p.category,
p.cost,
p.price,
oi.line_total,
((p.price-p.cost)/p.price) as profit_percent, 
round((line_total*((p.price-p.cost)/p.price)),2) as total_PROFIT
from products p 
left join order_items oi 
on p.product_id = oi.product_id
);


select category,avg(profit_percent),sum(total_PROFIT) from profit_by_product group by category



