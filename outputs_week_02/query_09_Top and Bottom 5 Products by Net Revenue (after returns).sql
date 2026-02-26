-- 9)Top and Bottom 5 Products by Net Revenue (after returns)

create or replace view product_items_view as(
select 
p.product_id,
p.product_name,
p.category,
oi.line_total
from products p 
join order_items oi on p.product_id = oi.product_id
);


with cte as(
select * from returns where return_status in ('approved','refunded')
),
cte1 as(
select pi.product_id,
pi.product_name,
pi.category,
pi.line_total,
c.return_id,
c.return_status,
c.refund_amount,
case 
when return_id is null then pi.line_total
when return_id is not null then (pi.line_total-c.refund_amount)
else 0
end as profit_after_return
from product_items_view pi 
left join cte c 
on c.product_id = pi.product_id)

select 
product_id,product_name,
sum(profit_after_return) as total_revenue 
from cte1 
group by product_id;
