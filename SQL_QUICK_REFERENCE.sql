-- ================================================================
-- SQL QUICK REFERENCE - EXECUTABLE EXAMPLES
-- Customer Orders Analytics Project
-- ================================================================
-- Copy-paste ready SQL snippets with sample data
-- ================================================================

USE customer_orders;

-- ================================================================
-- WINDOW FUNCTIONS EXAMPLES
-- ================================================================

-- LAG() - Month-over-Month Change
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS revenue,
    LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS prev_month,
    ROUND(
        (SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')))
        / LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) * 100,
        2
    ) AS mom_pct_change
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
LIMIT 10;


-- NTILE() - Divide into Quintiles (5 groups)
SELECT
    customer_id,
    order_count,
    lifetime_value,
    NTILE(5) OVER (ORDER BY order_count) AS frequency_quintile,
    NTILE(5) OVER (ORDER BY lifetime_value) AS monetary_quintile
FROM rpt_customer_rfm
LIMIT 20;


-- RANK() - Ranking within Groups
SELECT
    category,
    product_name,
    units_sold,
    RANK() OVER (PARTITION BY category ORDER BY units_sold DESC) AS rank_in_category
FROM rpt_product_dashboard
WHERE units_sold > 0
LIMIT 20;


-- ROW_NUMBER() - Sequential Numbering per Customer
SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS purchase_sequence
FROM orders
LIMIT 20;


-- SUM() OVER() - Percentage of Total
SELECT
    category,
    total_revenue,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS pct_of_total
FROM rpt_category_breakdown
WHERE category != 'TOTAL'
LIMIT 10;


-- ================================================================
-- AGGREGATION EXAMPLES
-- ================================================================

-- Basic Aggregations
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT product_id) AS unique_products,
    SUM(total_amount) AS lifetime_value,
    AVG(total_amount) AS avg_order_value,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY customer_id
LIMIT 10;


-- COALESCE - Handle NULLs
SELECT
    customer_id,
    COALESCE(SUM(total_amount), 0) AS lifetime_value,
    COALESCE(status, 'Unknown') AS order_status
FROM orders
GROUP BY customer_id, status
LIMIT 10;


-- NULLIF - Safe Division
SELECT
    product_id,
    product_name,
    gross_revenue,
    total_margin,
    ROUND(
        total_margin / NULLIF(gross_revenue, 0) * 100,
        2
    ) AS margin_percentage
FROM rpt_product_dashboard
LIMIT 10;


-- ================================================================
-- CTE (Common Table Expression) EXAMPLES
-- ================================================================

-- Single CTE
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    revenue,
    AVG(revenue) OVER () AS avg_monthly_revenue
FROM monthly_sales
ORDER BY month
LIMIT 10;


-- Multiple CTEs (Pipeline)
WITH
    customer_first_order AS (
        SELECT
            customer_id,
            MIN(order_date) AS first_order_date
        FROM orders
        GROUP BY customer_id
    ),
    customer_segments AS (
        SELECT
            cfo.customer_id,
            cfo.first_order_date,
            COUNT(o.order_id) AS total_orders,
            CASE
                WHEN COUNT(o.order_id) = 1 THEN 'One-Time'
                WHEN COUNT(o.order_id) BETWEEN 2 AND 5 THEN 'Regular'
                ELSE 'VIP'
            END AS segment
        FROM customer_first_order cfo
        LEFT JOIN orders o ON o.customer_id = cfo.customer_id
        GROUP BY cfo.customer_id, cfo.first_order_date
    )
SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM customer_segments
GROUP BY segment;


-- ================================================================
-- DATE & TIME FUNCTIONS
-- ================================================================

-- Date Formatting
SELECT
    order_date,
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    DATE_FORMAT(order_date, '%Y-Q%q') AS year_quarter,
    DATE_FORMAT(order_date, '%W') AS day_name
FROM orders
LIMIT 10;


-- DATEDIFF - Days Between Dates
SELECT
    customer_id,
    last_order_date,
    DATEDIFF(CURRENT_DATE, last_order_date) AS days_since_last_order,
    CASE
        WHEN DATEDIFF(CURRENT_DATE, last_order_date) <= 30 THEN 'Active'
        WHEN DATEDIFF(CURRENT_DATE, last_order_date) <= 90 THEN 'At Risk'
        ELSE 'Churned'
    END AS status
FROM rpt_customer_rfm
WHERE order_count > 0
LIMIT 10;


-- Date Part Extraction
SELECT
    order_date,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    QUARTER(order_date) AS quarter,
    WEEK(order_date) AS week,
    DAYOFWEEK(order_date) AS dow,
    DAYNAME(order_date) AS day_name
FROM orders
LIMIT 10;


-- TIMESTAMPDIFF - Months Between
SELECT
    customer_id,
    first_order_date,
    last_order_date,
    TIMESTAMPDIFF(MONTH, first_order_date, last_order_date) AS customer_lifetime_months
FROM rpt_customer_rfm
WHERE order_count > 1
LIMIT 10;


-- ================================================================
-- CONDITIONAL LOGIC (CASE WHEN)
-- ================================================================

-- Simple CASE for Segmentation
SELECT
    customer_id,
    lifetime_value,
    CASE
        WHEN lifetime_value >= 1000 THEN 'Premium'
        WHEN lifetime_value >= 500 THEN 'Gold'
        WHEN lifetime_value >= 200 THEN 'Silver'
        ELSE 'Bronze'
    END AS tier
FROM rpt_customer_rfm
LIMIT 20;


-- Conditional Aggregation (Pivot Pattern)
SELECT
    YEAR(order_date) AS year,
    WEEK(order_date) AS week,
    SUM(CASE WHEN DAYOFWEEK(order_date) = 1 THEN total_amount ELSE 0 END) AS sunday_sales,
    SUM(CASE WHEN DAYOFWEEK(order_date) = 2 THEN total_amount ELSE 0 END) AS monday_sales,
    SUM(CASE WHEN DAYOFWEEK(order_date) = 3 THEN total_amount ELSE 0 END) AS tuesday_sales,
    SUM(CASE WHEN DAYOFWEEK(order_date) = 4 THEN total_amount ELSE 0 END) AS wednesday_sales,
    SUM(CASE WHEN DAYOFWEEK(order_date) = 5 THEN total_amount ELSE 0 END) AS thursday_sales,
    SUM(CASE WHEN DAYOFWEEK(order_date) = 6 THEN total_amount ELSE 0 END) AS friday_sales,
    SUM(CASE WHEN DAYOFWEEK(order_date) = 7 THEN total_amount ELSE 0 END) AS saturday_sales
FROM orders
GROUP BY YEAR(order_date), WEEK(order_date)
LIMIT 10;


-- ================================================================
-- JOINS EXAMPLES
-- ================================================================

-- INNER JOIN - Matching Records
SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    p.product_name,
    oi.quantity,
    oi.line_total
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON p.product_id = oi.product_id
LIMIT 20;


-- LEFT JOIN - Find Non-Matching Records
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) = 0
LIMIT 10;


-- ================================================================
-- GROUP BY WITH ROLLUP
-- ================================================================

-- Subtotals and Grand Totals
SELECT
    COALESCE(category, '** GRAND TOTAL **') AS category,
    COALESCE(product_name, '** Category Total **') AS product,
    SUM(total_units) AS units_sold,
    ROUND(SUM(total_revenue), 2) AS revenue
FROM rpt_category_breakdown
WHERE category IS NOT NULL
GROUP BY category, product_name WITH ROLLUP
LIMIT 30;


-- Using GROUPING() to Detect Rollup Rows
SELECT
    CASE
        WHEN GROUPING(category) = 1 THEN '=== GRAND TOTAL ==='
        ELSE category
    END AS category,
    CASE
        WHEN GROUPING(product_name) = 1 AND GROUPING(category) = 0 THEN '--- Subtotal ---'
        WHEN GROUPING(product_name) = 1 AND GROUPING(category) = 1 THEN '--- Overall ---'
        ELSE product_name
    END AS product,
    SUM(total_revenue) AS revenue,
    GROUPING(category) AS is_category_total,
    GROUPING(product_name) AS is_product_total
FROM rpt_category_breakdown
WHERE category IS NOT NULL
GROUP BY category, product_name WITH ROLLUP
LIMIT 20;


-- ================================================================
-- STRING FUNCTIONS
-- ================================================================

-- CONCAT - Combine Strings
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    CONCAT(city, ', India') AS location,
    CONCAT('Customer #', customer_id) AS customer_label
FROM customers
LIMIT 10;


-- UPPER/LOWER - Case Conversion
SELECT
    order_id,
    status,
    UPPER(status) AS status_upper,
    LOWER(status) AS status_lower
FROM orders
LIMIT 10;


-- ================================================================
-- RANKING PATTERNS
-- ================================================================

-- Top 5 per Category
WITH ranked_products AS (
    SELECT
        category,
        product_name,
        units_sold,
        RANK() OVER (PARTITION BY category ORDER BY units_sold DESC) AS rank_in_category
    FROM rpt_product_dashboard
    WHERE units_sold > 0
)
SELECT *
FROM ranked_products
WHERE rank_in_category <= 5
ORDER BY category, rank_in_category;


-- Top and Bottom Combined
WITH revenue_rankings AS (
    SELECT
        product_name,
        net_revenue,
        RANK() OVER (ORDER BY net_revenue DESC) AS top_rank,
        RANK() OVER (ORDER BY net_revenue ASC) AS bottom_rank
    FROM rpt_product_dashboard
    WHERE units_sold > 0
)
SELECT
    'Top 5' AS group_type,
    product_name,
    net_revenue,
    top_rank AS rank
FROM revenue_rankings
WHERE top_rank <= 5

UNION ALL

SELECT
    'Bottom 5' AS group_type,
    product_name,
    net_revenue,
    bottom_rank AS rank
FROM revenue_rankings
WHERE bottom_rank <= 5
ORDER BY group_type DESC, rank;


-- ================================================================
-- ADVANCED PATTERNS
-- ================================================================

-- Running Total
SELECT
    order_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM orders
ORDER BY order_date
LIMIT 20;


-- Moving Average (7-day)
SELECT
    order_date,
    total_amount,
    AVG(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day
FROM orders
ORDER BY order_date
LIMIT 20;


-- Year-over-Year Growth
WITH yearly_revenue AS (
    SELECT
        YEAR(order_date) AS year,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY YEAR(order_date)
)
SELECT
    year,
    revenue,
    LAG(revenue) OVER (ORDER BY year) AS prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year)) * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY year), 0),
        2
    ) AS yoy_growth_pct
FROM yearly_revenue
ORDER BY year;


-- First vs Repeat Purchase Split
WITH customer_purchases AS (
    SELECT
        customer_id,
        order_id,
        total_amount,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS purchase_number
    FROM orders
)
SELECT
    CASE WHEN purchase_number = 1 THEN 'First Purchase' ELSE 'Repeat Purchase' END AS purchase_type,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value,
    ROUND(SUM(total_amount) * 100.0 / SUM(SUM(total_amount)) OVER (), 2) AS revenue_pct
FROM customer_purchases
GROUP BY CASE WHEN purchase_number = 1 THEN 'First Purchase' ELSE 'Repeat Purchase' END;


-- Cohort Retention Analysis
WITH customer_cohorts AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
),
cohort_activity AS (
    SELECT
        cc.cohort_month,
        DATE_FORMAT(o.order_date, '%Y-%m') AS activity_month,
        TIMESTAMPDIFF(MONTH, STR_TO_DATE(CONCAT(cc.cohort_month, '-01'), '%Y-%m-%d'), o.order_date) AS months_from_first
    FROM customer_cohorts cc
    JOIN orders o ON o.customer_id = cc.customer_id
)
SELECT
    cohort_month,
    months_from_first,
    COUNT(DISTINCT customer_id) AS active_customers
FROM cohort_activity
WHERE months_from_first BETWEEN 0 AND 6
GROUP BY cohort_month, months_from_first
ORDER BY cohort_month, months_from_first
LIMIT 50;


-- ================================================================
-- END OF QUICK REFERENCE
-- All queries are ready to execute against customer_orders database
-- ================================================================
