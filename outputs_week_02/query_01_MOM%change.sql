-- 1) Monthly Revenue Trend with MoM % Change
-- Group revenue by month
-- Calculate total revenue for each month
-- Compare each month with the previous month
-- Find the % increase or decrease (MoM = Month-over-Month)

with total_revenue as(
select 
date_format(o.order_date,"%Y-%m") as revenue_per_month,
sum(o.total_amount) as total_revenue
from 
orders o 
where o.status="Delivered" 
group by date_format(o.order_date,"%Y-%m")
)

select *,
lag(total_revenue) over (order by revenue_per_month) as nxt_month , 
round(
(total_revenue-lag(total_revenue) over (order by revenue_per_month))
/total_revenue *100
,2) as diff_percentage 
from total_revenue;
