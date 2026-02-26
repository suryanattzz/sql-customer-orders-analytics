-- 7) Low-Stock & Restock Alert Report

-- This report highlights products that are approaching or below their reorder levels, enabling proactive inventory replenishment and avoiding stock-out scenarios

with cte as(
select 
p.product_id,
p.product_name,
p.category,
pi.inventory_id,
pi.stock_quantity,
pi.restock_threshold,
(pi.stock_quantity - pi.restock_threshold) as diff_quantity
from products p 
left join product_inventory pi 
on p.product_id = pi.product_id
)


select *, 
case 
when diff_quantity<-10 then "critical"
when diff_quantity<0 then "low stock"
when diff_quantity<15 then "healthy"
when diff_quantity<30 then "over stocked"
end as stock_status
from cte 
