-- 11)Weekly Sales Heatmap (Day of Week x Week Number) Sales Performance
-- Week	Mon	Tue	Wed	Thu	Fri	Sat	Sun
-- 1	12,000	10,500	11,200	13,400	18,900	25,000	22,300
-- 2	11,800	10,100	10,900	14,200	19,500	27,100	23,800


with cte as(
select 
month(order_date) as month_order,
dayname(order_date) as day_order,
sum(total_amount) 
from orders 
group by 
month(order_date),dayname(order_date) )

select * from cte group by month_order,day_order order by month_order