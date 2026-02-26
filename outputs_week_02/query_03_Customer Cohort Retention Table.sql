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
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m-01') AS order_month
    FROM orders 
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

use customer_orders;


