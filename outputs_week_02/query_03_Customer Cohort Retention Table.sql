-- 3) Customer Cohort Retention 

-- Customers are grouped into cohorts based on their first purchase month.
-- Retention shows how many customers return in later months.
-- Month 0 always starts at 100% (all customers in the cohort).
-- Retention typically decreases over time as customers churn.
-- Example
-- Cohort	Month 0	Month 1	Month 2	Month 3
-- Jan 2024	100%	68%	52%	39%
-- Feb 2024	100%	72%	55%	42%
use customer_orders;
create or replace view cte as(
select customer_id,
first_order ,
first_order as cohort_month
-- date_format(first_order,"%M-%Y") as cohort_month 
from(
select customer_id,
min(order_date) as first_order
from orders 
group by customer_id) as t);

create or replace view cte1 as(
select 
o.customer_id,
-- date_format(o.order_date,"%M-%Y") as order_month,
o.order_date,
c.cohort_month ,
c.first_order
from orders o 
left join cte c 
on o.customer_id = c.customer_id 
order by o.customer_id,o.order_date);

create or replace view cte2 as(
select 
customer_id,
-- date_format(o.order_date,"%M-%Y") as order_month,
order_date,
cohort_month ,
first_order,
TIMESTAMPDIFF(MONTH, first_order, order_date) as month_count
from cte1);

select 
cohort_month,
month_count,
count(distinct customer_id)
from cte2
group by cohort_month,month_count  ;



-- 1️⃣ Get each customer's first purchase month (Cohort Month)
WITH cohort_cte AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m-01') AS cohort_month
    FROM orders
    GROUP BY customer_id
),

-- 2️⃣ Get each order with its order month
orders_cte AS (
    SELECT
        o.customer_id,
        DATE_FORMAT(o.order_date, '%Y-%m-01') AS order_month
    FROM orders o
),

-- 3️⃣ Join and calculate month difference
retention_cte AS (
    SELECT
        c.customer_id,
        c.cohort_month,
        o.order_month,
        TIMESTAMPDIFF(MONTH, c.cohort_month, o.order_month) AS month_number
    FROM cohort_cte c
    JOIN orders_cte o
        ON c.customer_id = o.customer_id
),

-- 4️⃣ Count active customers per cohort per month
active_users AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM retention_cte
    GROUP BY cohort_month, month_number
),

-- 5️⃣ Get cohort sizes (Month 0 users)
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM cohort_cte
    GROUP BY cohort_month
)

-- 🔥 Final Retention Table (Pivot Format)
SELECT
    a.cohort_month,

    ROUND(100 * SUM(CASE WHEN month_number = 0 THEN active_customers END) 
          / MAX(cs.total_customers), 2) AS Month_0,

    ROUND(100 * SUM(CASE WHEN month_number = 1 THEN active_customers END) 
          / MAX(cs.total_customers), 2) AS Month_1,

    ROUND(100 * SUM(CASE WHEN month_number = 2 THEN active_customers END) 
          / MAX(cs.total_customers), 2) AS Month_2,

    ROUND(100 * SUM(CASE WHEN month_number = 3 THEN active_customers END) 
          / MAX(cs.total_customers), 2) AS Month_3

FROM active_users a
JOIN cohort_size cs
    ON a.cohort_month = cs.cohort_month

GROUP BY a.cohort_month
ORDER BY a.cohort_month;




