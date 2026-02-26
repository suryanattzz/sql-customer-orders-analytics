-- 10)Promotion Effectiveness Report

-- | Order Type        | Total Orders | Total Revenue | Avg Order Value |
-- | ----------------- | ------------ | ------------- | --------------- |
-- | With Promotion    | 420          | 315,000       | 750             |
-- | Without Promotion | 580          | 580,000       | 1,000           |

with cte as(
select  o.order_id,
o.customer_id,
o.order_date,
o.total_amount,
op.promo_id,
op.discount_applied,
case 
when op.discount_applied = 0 then total_amount
else null
end as Without_Promotion ,
case 
when op.discount_applied != 0 then total_amount-discount_applied
else null
end as With_Promotion
from orders o 
left join order_promotions op 
on o.order_id = op.order_id )


select 
count(With_Promotion) over() as orders_with_promo,
count(Without_Promotion) over() as orders_without_promo,
sum(With_Promotion) over() as With_Promotion,
sum(Without_Promotion) over() as Without_Promotion,
round(sum(With_Promotion) over()/count(With_Promotion) over(),2) as avg_revenue_promo,
round(sum(Without_Promotion) over()/count(Without_Promotion) over(),2) as avg_revenue_without_promo
from cte limit 1












