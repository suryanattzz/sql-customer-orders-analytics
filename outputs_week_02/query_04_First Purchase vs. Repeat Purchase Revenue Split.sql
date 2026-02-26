-- 4)First Purchase vs. Repeat Purchase Revenue Split


with cte as(
select c.customer_id,o.order_id,o.order_date,o.total_amount,
row_number() over (partition by customer_id order by order_date) as ranks
from customers c 
left join 
orders o on c.customer_id = o.customer_id
),
cte2 as(
select * 
,case when ranks>1 then "Repeated Purchase"
when ranks=1 then "First Purchase"
end as rankss
from cte),
cte3 as
(select customer_id,rankss,sum(total_amount) as total_amount from cte2 group by customer_id,rankss)


SELECT
    rankss,
    sum(total_amount) AS revenue,
    round(
        sum(total_amount) /sum(sum(total_amount)) OVER () * 100, 2
    ) AS percentage
FROM cte3
GROUP BY rankss;




create view first_repeat_history as(
SELECT
  customer_id,
  SUM(CASE WHEN rankss = 'ones' THEN total_amount ELSE 0 END) AS first_purchase_amount,
  SUM(CASE WHEN rankss = 'repeats' THEN total_amount ELSE 0 END) AS repeat_purchase_amount
FROM cte3
GROUP BY customer_id);







