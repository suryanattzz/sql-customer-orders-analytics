-- 5)Customer Churn Risk


-- Days Since Last Order	Segment Label	Meaning
-- 0–30 days	Active	Recently engaged
-- 31–60 days	At Risk	Engagement dropping
-- 61–90 days	High Risk	Likely to churn
-- > 90 days	Churned	Inactive / lost

with cte as(
select 
c.customer_id,
c.first_name,
max(o.order_date) as last_purchase,
datediff(curdate(),max(o.order_date)) as days_inactive
from customers c 
join orders o 
on c.customer_id = o.customer_id
group by c.customer_id),
cte2 as
(
select 
customer_id,
first_name,
last_purchase,
days_inactive,
case
when days_inactive<10 then "active"
when days_inactive<20 then "activity droping"
when days_inactive<60 then "activity stopped"
when days_inactive<90 then "high risk"
else "customer lost/inactive"
end as churn_segment
from cte )

select 
churn_segment,
count(churn_segment),
count(*)/sum(count(*)) over () * 100 as precentage
from cte2 group by churn_segment

