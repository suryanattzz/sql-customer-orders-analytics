-- Report queries

use customer_orders;

-- Top 5 Products based on Revenue and Quantity

select 
product_id,
quantity,
product_name,
category,
total_amount,
total_revenue 
from product_revenue_order_table
order by total_revenue desc
limit 5;

select 
product_id,
quantity,
product_name,
category,
total_amount,
total_revenue 
from product_revenue_order_table
order by quantity desc
limit 5;


-- Revenue by day/week

select 
order_date,
SUM(total_revenue) as "Revenue Per Day"
from product_revenue_order_table
group by order_date order by sum(total_revenue) desc;

SELECT
    YEAR(order_date) AS year,
    WEEK(order_date) AS week,
    SUM(total_revenue) AS "Revenue Per Week"
FROM product_revenue_order_table
GROUP BY year, week
ORDER BY year, week;


-- Identification of customers with no orders.

select 
c.customer_id,
c.first_name,
c.last_name,
c.email,
c.phone,
c.city 
from 
customers c left join orders o 
on c.customer_id = o.customer_id 
where o.customer_id is Null;


-- Customer classification (Repeat vs. One-Time).

SELECT
customer_id,
first_name,
last_name,
email,
city,
COUNT(order_id) AS order_count
FROM customer_order_table
GROUP BY customer_id
HAVING COUNT(order_id) > 1;


-- Customer lifetime value and top 5 revenue-generating customers
SELECT
customer_id,
first_name,
last_name,
email,
city,
sum(total_amount) AS Customer_Lifetime_Value
FROM customer_order_table
GROUP BY
    customer_id
ORDER BY Customer_Lifetime_Value Desc
limit 5;

SELECT
customer_id,
first_name,
last_name,
email,
city,
sum(total_amount) AS "Customer Lifetime Value"
FROM customer_order_table
GROUP BY
    customer_id;

