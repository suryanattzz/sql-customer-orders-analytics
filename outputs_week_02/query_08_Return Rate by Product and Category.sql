-- 8)Return Rate by Product and Category

-- | product   | category    | sold_qty | returned_qty | return_rate |
-- | --------- | ----------- | -------- | ------------ | ----------- |
-- | Product A | Electronics | 500      | 40           | 8%          |
-- | Product B | Apparel     | 300      | 75           | 25%         |

create or replace view product_items_view as(
select 
p.product_id,
p.product_name,
p.category,
oi.order_item_id,
oi.quantity
from products p 
join order_items oi on p.product_id = oi.product_id
);

with cte as(
select * from returns where return_status not in ('approved','refunded')
),
cte1 as(
select 
pr.product_name,
pr.category,
pr.quantity as quantity_sold,
case 
when c.return_id is null then 0
else pr.quantity
end as return_qan
from product_items_view pr left join cte c on pr.product_id = c.product_id
)


select *,round((return_qan/quantity_sold)*100,2) as 'return_precent' from cte1

