-- 2)RFM Customer Scoring 
-- Recency (R): Measures how recently a customer made a purchase
-- → More recent = higher score (e.g., 5 = very recent, 1 = long ago)

-- Frequency (F): Measures how often a customer purchases
-- → More purchases = higher score

-- Monetary (M): Measures total money spent by a customer
-- → Higher spending = higher score

-- Scoring Method:
-- → Customers are ranked into buckets (usually 1–5) for each metric
-- → Example: R=5, F=4, M=3 → RFM Score = 543


create or replace view customer_order_view as(
select c.customer_id,first_name,
case 
when count(o.order_id)=0|null then 0
when count(o.order_id)<2 then 1
when count(o.order_id)<3 then 2 
when count(o.order_id)<4 then 3
when count(o.order_id)<5 then 4
else 5 
end as freq_cnt,

sum(o.total_amount)as revenue_by_customer ,

datediff(curdate(),max(o.order_date)) as diff_dates

from customers c 
left join 
orders o on c.customer_id = o.customer_id 
group by c.customer_id
);


create or replace view customer_rankings as(
select customer_id,
first_name,
revenue_by_customer,
freq_cnt,
case 
when revenue_by_customer=0|null then 0
when revenue_by_customer<150 then 1
when revenue_by_customer<300 then 2 
when revenue_by_customer<500 then 3
when revenue_by_customer<800 then 4
else 5
end as revenue_rank,
case 
when diff_dates is null then 0
when diff_dates<30 then 5
when diff_dates<90 then 4 
when diff_dates<150 then 3
when diff_dates<210 then 2
else 1
end as date_rank
from customer_order_view
);

select *,(freq_cnt + revenue_rank + date_rank) as RFM_Score from customer_rankings;






-- with cte1 as(
-- select c.customer_id,max(o.order_date) as max_date,
-- datediff(curdate(),max(o.order_date)) as diff_dates
-- from customers c 
-- left join 
-- orders o on c.customer_id = o.customer_id 
-- group by c.customer_id)

-- select *,case 
-- when diff_dates is null then 0
-- when diff_dates<30 then 5
-- when diff_dates<90 then 4 
-- when diff_dates<150 then 3
-- when diff_dates<210 then 2
-- else 1
-- end as date_rank from cte1 




