# SQL Concepts & Functions Cheat Sheet
## Customer Orders Analytics Project

This cheat sheet documents all SQL concepts, functions, and techniques used in this project with practical examples and explanations.

---

## Table of Contents
1. [Window Functions](#window-functions)
2. [Aggregation Functions](#aggregation-functions)
3. [Common Table Expressions (CTEs)](#common-table-expressions-ctes)
4. [Date & Time Functions](#date--time-functions)
5. [Conditional Logic](#conditional-logic)
6. [Joins](#joins)
7. [Grouping & Rollup](#grouping--rollup)
8. [String Functions](#string-functions)
9. [Ranking & Scoring](#ranking--scoring)
10. [Data Pipeline Patterns](#data-pipeline-patterns)

---

## Window Functions

### 1. LAG() - Access Previous Row Data

**Syntax:**
```sql
LAG(column_name, offset, default_value) OVER (ORDER BY sort_column)
```

**Why Used:** Calculate Month-over-Month (MoM) changes by comparing current month with previous month.

**Example from Query 01:**
```sql
SELECT
    year_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY order_year, order_month) AS previous_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_year, order_month)) 
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY order_year, order_month), 0) * 100,
        2
    ) AS mom_change_pct
FROM monthly_revenue;
```

**Logic:**
- `LAG(monthly_revenue)` gets the previous row's revenue
- Division calculates percentage change
- `NULLIF` prevents division by zero errors

---

### 2. NTILE() - Divide Data into N Equal Buckets

**Syntax:**
```sql
NTILE(n) OVER (ORDER BY column_name)
```

**Why Used:** Create percentile-based scoring (quintiles) for RFM analysis.

**Example from Query 02:**
```sql
SELECT
    customer_id,
    -- Recency: Lower days = higher score (reversed order)
    NTILE(5) OVER (ORDER BY days_since_last_order DESC) AS recency_score,
    -- Frequency: More orders = higher score
    NTILE(5) OVER (ORDER BY order_count ASC) AS frequency_score,
    -- Monetary: Higher value = higher score
    NTILE(5) OVER (ORDER BY lifetime_value ASC) AS monetary_score
FROM customers;
```

**Logic:**
- Divides customers into 5 equal groups (quintiles)
- Score 5 = top 20%, Score 1 = bottom 20%
- Each metric ordered differently based on business logic

---

### 3. RANK() - Assign Ranks with Gaps

**Syntax:**
```sql
RANK() OVER (PARTITION BY group_column ORDER BY value_column DESC)
```

**Why Used:** Rank products within categories while handling ties.

**Example from Query 06:**
```sql
SELECT
    category,
    product_name,
    margin_pct,
    RANK() OVER (PARTITION BY category ORDER BY margin_pct DESC) AS margin_rank_in_category,
    RANK() OVER (ORDER BY margin_pct DESC) AS overall_margin_rank
FROM products;
```

**Logic:**
- `PARTITION BY category` creates separate rankings per category
- Ties get same rank, next rank skips numbers (1, 2, 2, 4)
- Allows both category-level and global rankings

---

### 4. ROW_NUMBER() - Sequential Numbering

**Syntax:**
```sql
ROW_NUMBER() OVER (PARTITION BY group_column ORDER BY sort_column)
```

**Why Used:** Identify first vs. repeat purchases for each customer.

**Example from Query 04:**
```sql
SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS purchase_number
FROM orders;
```

**Logic:**
- Each customer gets their own sequence (1, 2, 3...)
- `purchase_number = 1` identifies first-time purchases
- `purchase_number > 1` identifies repeat purchases

---

### 5. SUM() OVER() - Running/Cumulative Totals

**Syntax:**
```sql
SUM(column) OVER (ORDER BY sort_column ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
```

**Why Used:** Calculate percentage of total revenue.

**Example from Query 04:**
```sql
SELECT
    purchase_type,
    total_revenue,
    ROUND(
        total_revenue * 100.0 / SUM(total_revenue) OVER (),
        2
    ) AS revenue_percentage
FROM revenue_split;
```

**Logic:**
- `SUM() OVER ()` calculates grand total across all rows
- Division gives each row's share of total
- Empty `OVER()` means no partitioning/ordering

---

## Aggregation Functions

### 1. COUNT() - Count Rows or Non-NULL Values

**Syntax:**
```sql
COUNT(*)              -- Count all rows
COUNT(column)         -- Count non-NULL values
COUNT(DISTINCT col)   -- Count unique values
```

**Example:**
```sql
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(promotion_id) AS orders_with_promo  -- NULL excluded
FROM orders
GROUP BY customer_id;
```

---

### 2. SUM() - Total of Values

**Why Used:** Calculate total revenue, quantities, margins.

**Example:**
```sql
SELECT
    category,
    SUM(quantity) AS total_units_sold,
    SUM(line_total) AS total_revenue,
    SUM(line_margin) AS total_margin
FROM order_items
GROUP BY category;
```

---

### 3. AVG() - Average of Values

**Why Used:** Calculate average order value, margin percentages.

**Example:**
```sql
SELECT
    customer_id,
    AVG(total_amount) AS avg_order_value,
    AVG(DATEDIFF(CURRENT_DATE, order_date)) AS avg_days_between_orders
FROM orders
GROUP BY customer_id;
```

---

### 4. MIN() and MAX() - Extremes

**Why Used:** Find first/last order dates, date ranges.

**Example from RFM Analysis:**
```sql
SELECT
    customer_id,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(CURRENT_DATE, MAX(order_date)) AS days_since_last_order
FROM orders
GROUP BY customer_id;
```

---

### 5. COALESCE() - Handle NULL Values

**Syntax:**
```sql
COALESCE(value1, value2, default_value)
```

**Why Used:** Replace NULL with meaningful defaults.

**Example:**
```sql
SELECT
    customer_id,
    COALESCE(SUM(total_amount), 0) AS lifetime_value,
    COALESCE(status, 'Unknown') AS order_status
FROM orders;
```

**Logic:**
- Returns first non-NULL argument
- Prevents NULL in calculations/reports

---

### 6. NULLIF() - Prevent Division by Zero

**Syntax:**
```sql
NULLIF(expression1, expression2)
```

**Why Used:** Safe division operations.

**Example:**
```sql
SELECT
    product_id,
    ROUND(
        (revenue - cost) / NULLIF(revenue, 0) * 100,
        2
    ) AS margin_percentage
FROM products;
```

**Logic:**
- Returns NULL if both expressions are equal
- Division by NULL = NULL (not error)

---

## Common Table Expressions (CTEs)

### 1. Basic CTE - Temporary Named Result Set

**Syntax:**
```sql
WITH cte_name AS (
    SELECT ...
)
SELECT * FROM cte_name;
```

**Why Used:** Break complex queries into readable steps.

**Example from Query 01:**
```sql
WITH monthly_revenue AS (
    SELECT
        order_month,
        SUM(total_amount) AS monthly_revenue
    FROM orders
    GROUP BY order_month
)
SELECT
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY month) AS prev_month
FROM monthly_revenue;
```

**Logic:**
- Named subquery executed once
- Improves readability and maintainability
- Can be referenced multiple times

---

### 2. Multiple CTEs - Chained Logic

**Syntax:**
```sql
WITH cte1 AS (...),
     cte2 AS (...),
     cte3 AS (...)
SELECT * FROM cte3;
```

**Example from Query 03 (Cohort Retention):**
```sql
WITH customer_cohorts AS (
    -- Step 1: Identify first purchase month
    SELECT customer_id, DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
),
cohort_activity AS (
    -- Step 2: Track activity by month
    SELECT cc.customer_id, cc.cohort_month, o.order_date
    FROM customer_cohorts cc
    JOIN orders o ON o.customer_id = cc.customer_id
),
cohort_size AS (
    -- Step 3: Count cohort sizes
    SELECT cohort_month, COUNT(*) AS cohort_customers
    FROM customer_cohorts
    GROUP BY cohort_month
)
SELECT * FROM cohort_size;
```

**Logic:**
- Each CTE builds on previous ones
- Creates clear data pipeline
- Step-by-step transformation

---

## Date & Time Functions

### 1. DATE_FORMAT() - Format Dates

**Syntax:**
```sql
DATE_FORMAT(date_column, 'format_string')
```

**Common Formats:**
- `'%Y-%m'` → 2026-02
- `'%Y-%m-%d'` → 2026-02-19
- `'%M %Y'` → February 2026

**Example:**
```sql
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');
```

---

### 2. DATEDIFF() - Days Between Dates

**Syntax:**
```sql
DATEDIFF(date1, date2)  -- Returns date1 - date2 in days
```

**Why Used:** Calculate customer recency, processing times.

**Example:**
```sql
SELECT
    customer_id,
    last_order_date,
    DATEDIFF(CURRENT_DATE, last_order_date) AS days_since_last_order
FROM customers;
```

---

### 3. TIMESTAMPDIFF() - Interval Between Timestamps

**Syntax:**
```sql
TIMESTAMPDIFF(unit, start_timestamp, end_timestamp)
```

**Units:** SECOND, MINUTE, HOUR, DAY, WEEK, MONTH, YEAR

**Example from Query 03:**
```sql
SELECT
    cohort_month,
    order_date,
    TIMESTAMPDIFF(MONTH, first_order_date, order_date) AS months_since_first
FROM cohort_activity;
```

---

### 4. Date Extraction Functions

**Syntax:**
```sql
YEAR(date_column)
MONTH(date_column)
QUARTER(date_column)
WEEK(date_column)
DAYOFWEEK(date_column)  -- 1=Sunday, 7=Saturday
DAYNAME(date_column)    -- 'Monday', 'Tuesday', ...
```

**Example from Staging Layer:**
```sql
SELECT
    order_date,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    QUARTER(order_date) AS order_quarter,
    WEEK(order_date) AS order_week,
    DAYOFWEEK(order_date) AS order_dow,
    DAYNAME(order_date) AS order_day_name
FROM orders;
```

---

### 5. CURRENT_DATE and CURRENT_TIMESTAMP

**Syntax:**
```sql
CURRENT_DATE         -- Date only (2026-02-19)
CURRENT_TIMESTAMP    -- Date + time (2026-02-19 14:30:00)
```

**Example:**
```sql
SELECT
    customer_id,
    DATEDIFF(CURRENT_DATE, last_order_date) AS days_inactive
FROM customers;
```

---

## Conditional Logic

### 1. CASE WHEN - Conditional Values

**Syntax:**
```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END
```

**Why Used:** Create segments, categories, flags.

**Example from Query 05 (Churn Risk):**
```sql
SELECT
    customer_id,
    days_since_last_order,
    CASE
        WHEN days_since_last_order IS NULL THEN 'Never Purchased'
        WHEN days_since_last_order <= 30 THEN 'Active (0-30 days)'
        WHEN days_since_last_order <= 60 THEN 'Moderate Risk (31-60 days)'
        WHEN days_since_last_order <= 90 THEN 'High Risk (61-90 days)'
        ELSE 'Churned (90+ days)'
    END AS churn_risk_segment
FROM customers;
```

---

### 2. Conditional Aggregation

**Pattern:**
```sql
SUM(CASE WHEN condition THEN 1 ELSE 0 END) AS count_matching
SUM(CASE WHEN condition THEN value ELSE 0 END) AS sum_matching
```

**Example from Query 11 (Heatmap):**
```sql
SELECT
    week_number,
    SUM(CASE WHEN order_dow = 1 THEN total_amount ELSE 0 END) AS sunday_sales,
    SUM(CASE WHEN order_dow = 2 THEN total_amount ELSE 0 END) AS monday_sales,
    SUM(CASE WHEN order_dow = 3 THEN total_amount ELSE 0 END) AS tuesday_sales
FROM orders
GROUP BY week_number;
```

**Logic:**
- Pivots rows into columns
- Creates cross-tabulation
- Each CASE acts as a filter

---

## Joins

### 1. INNER JOIN - Matching Records Only

**Syntax:**
```sql
SELECT *
FROM table1 t1
INNER JOIN table2 t2 ON t1.key = t2.key
```

**Why Used:** Link orders with customers, products with sales.

**Example:**
```sql
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    oi.quantity
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON p.product_id = oi.product_id;
```

---

### 2. LEFT JOIN - Keep All Left Table Rows

**Syntax:**
```sql
SELECT *
FROM table1 t1
LEFT JOIN table2 t2 ON t1.key = t2.key
```

**Why Used:** Find customers without orders, products without sales.

**Example (Customers with No Orders):**
```sql
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING COUNT(o.order_id) = 0;
```

---

### 3. Self Join - Join Table to Itself

**Why Used:** Compare rows within same table (cohort analysis).

**Example:**
```sql
SELECT
    a.customer_id,
    a.order_date AS first_order,
    b.order_date AS subsequent_order
FROM orders a
JOIN orders b ON a.customer_id = b.customer_id
    AND b.order_date > a.order_date;
```

---

## Grouping & Rollup

### 1. GROUP BY - Basic Aggregation

**Syntax:**
```sql
SELECT column1, column2, AGG_FUNC(column3)
FROM table
GROUP BY column1, column2
```

**Example:**
```sql
SELECT
    category,
    product_name,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY category, product_name;
```

---

### 2. GROUP BY WITH ROLLUP - Subtotals & Grand Totals

**Syntax:**
```sql
SELECT column1, column2, SUM(value)
FROM table
GROUP BY column1, column2 WITH ROLLUP
```

**Why Used:** Create hierarchical summary reports with subtotals.

**Example from Query 08 (Return Rates):**
```sql
SELECT
    COALESCE(category, 'TOTAL') AS category,
    COALESCE(product_name, 'Subtotal') AS product_name,
    SUM(items_returned) AS total_returns,
    ROUND(SUM(items_returned) * 100.0 / SUM(items_sold), 2) AS return_rate
FROM sales
GROUP BY category, product_name WITH ROLLUP;
```

**Output Pattern:**
```
Electronics | Phone X      | 10 | 5.2%
Electronics | Laptop Y     | 5  | 3.1%
Electronics | -- Subtotal  | 15 | 4.2%  ← Category rollup
Home        | Chair Z      | 8  | 6.1%
Home        | -- Subtotal  | 8  | 6.1%
TOTAL       | -- Total     | 23 | 5.0%  ← Grand total
```

---

### 3. GROUPING() - Detect Rollup Rows

**Syntax:**
```sql
GROUPING(column)  -- Returns 1 if rollup row, 0 if detail row
```

**Why Used:** Identify and label subtotal/total rows.

**Example from Query 12:**
```sql
SELECT
    CASE
        WHEN GROUPING(category) = 1 THEN 'GRAND TOTAL'
        ELSE category
    END AS category,
    CASE
        WHEN GROUPING(product_name) = 1 AND GROUPING(category) = 0 THEN '-- Category Subtotal --'
        WHEN GROUPING(product_name) = 1 AND GROUPING(category) = 1 THEN '-- All Categories --'
        ELSE product_name
    END AS product_name,
    SUM(revenue) AS total_revenue
FROM sales
GROUP BY category, product_name WITH ROLLUP;
```

**Logic:**
- `GROUPING(col) = 1` means that column is aggregated in this row
- Allows custom labels for different rollup levels

---

### 4. HAVING - Filter After Aggregation

**Syntax:**
```sql
SELECT column, COUNT(*)
FROM table
GROUP BY column
HAVING COUNT(*) > 10
```

**Why vs WHERE:**
- `WHERE` filters before aggregation
- `HAVING` filters after aggregation

**Example:**
```sql
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS lifetime_value
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1 AND SUM(total_amount) > 500;
```

---

## String Functions

### 1. CONCAT() - Combine Strings

**Syntax:**
```sql
CONCAT(string1, string2, ...)
```

**Example:**
```sql
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score
FROM customers;
```

---

### 2. UPPER() / LOWER() - Case Conversion

**Example:**
```sql
SELECT
    UPPER(status) AS status_upper,
    LOWER(email) AS email_normalized
FROM orders;
```

---

### 3. SUBSTRING() - Extract Part of String

**Syntax:**
```sql
SUBSTRING(string, start_position, length)
```

**Example:**
```sql
SELECT
    order_id,
    SUBSTRING(order_date, 1, 7) AS year_month  -- '2026-02-19' → '2026-02'
FROM orders;
```

---

## Ranking & Scoring

### 1. NTILE() for Quintile Scoring (Covered Above)

### 2. Custom Score Calculation

**Pattern:**
```sql
CASE
    WHEN value >= threshold1 THEN 5
    WHEN value >= threshold2 THEN 4
    WHEN value >= threshold3 THEN 3
    WHEN value >= threshold4 THEN 2
    ELSE 1
END AS score
```

**Example (Manual RFM Scoring):**
```sql
SELECT
    customer_id,
    CASE
        WHEN lifetime_value >= 1000 THEN 5
        WHEN lifetime_value >= 500 THEN 4
        WHEN lifetime_value >= 200 THEN 3
        WHEN lifetime_value >= 100 THEN 2
        ELSE 1
    END AS monetary_score
FROM customers;
```

---

### 3. RANK() vs DENSE_RANK() vs ROW_NUMBER()

**Comparison:**
```sql
SELECT
    product_name,
    sales,
    RANK() OVER (ORDER BY sales DESC) AS rank_with_gaps,        -- 1,2,2,4
    DENSE_RANK() OVER (ORDER BY sales DESC) AS rank_no_gaps,    -- 1,2,2,3
    ROW_NUMBER() OVER (ORDER BY sales DESC) AS sequential       -- 1,2,3,4
FROM products;
```

**When to Use:**
- `RANK()`: Standard competition ranking (Olympic medals)
- `DENSE_RANK()`: No gaps in ranking
- `ROW_NUMBER()`: Unique sequential numbers (always different)

---

## Data Pipeline Patterns

### 1. Three-Layer Architecture

**Layer 1: Raw Data**
```sql
-- Base tables: customers, orders, products, etc.
```

**Layer 2: Staging/Transformation**
```sql
CREATE VIEW stg_order_facts AS
SELECT
    o.*,
    c.customer_name,
    YEAR(o.order_date) AS order_year,
    COALESCE(o.status, 'Unknown') AS clean_status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;
```

**Layer 3: Reporting/Aggregation**
```sql
CREATE VIEW rpt_monthly_revenue AS
SELECT
    order_year,
    order_month,
    SUM(total_amount) AS revenue
FROM stg_order_facts
GROUP BY order_year, order_month;
```

**Why This Pattern:**
- **Separation of Concerns:** Raw → Clean → Aggregate
- **Reusability:** Staging views used by multiple reports
- **Performance:** Pre-computed transformations
- **Maintainability:** Changes isolated to specific layers

---

### 2. CTE Pipeline Pattern

**Pattern:**
```sql
WITH
    step1_extract AS (
        -- Get raw data
    ),
    step2_transform AS (
        -- Clean and transform
    ),
    step3_enrich AS (
        -- Add calculated fields
    ),
    step4_aggregate AS (
        -- Final aggregation
    )
SELECT * FROM step4_aggregate;
```

**Why:**
- Clear, linear data flow
- Easy to debug (test each CTE)
- Self-documenting code

---

### 3. Dimensional Modeling Pattern

**Fact Table (Events/Transactions):**
```sql
CREATE VIEW fact_sales AS
SELECT
    order_id,           -- PK
    customer_id,        -- FK to customer dimension
    product_id,         -- FK to product dimension
    order_date,         -- Time dimension
    quantity,           -- Measure
    revenue,            -- Measure
    margin              -- Measure
FROM order_items;
```

**Dimension Tables (Context):**
```sql
CREATE VIEW dim_customer AS
SELECT
    customer_id,        -- PK
    customer_name,
    city,
    segment
FROM customers;
```

**Why:**
- Fast aggregations (fact table optimized)
- Rich context (dimension tables)
- Standard BI pattern

---

## Performance Optimization Tips

### 1. Use Indexes on JOIN/WHERE Columns
```sql
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
```

### 2. Filter Early in Pipeline
```sql
-- GOOD: Filter in CTE
WITH recent_orders AS (
    SELECT * FROM orders WHERE order_date >= '2025-01-01'
)
SELECT ... FROM recent_orders ...

-- AVOID: Filter late
SELECT * FROM orders ... WHERE order_date >= '2025-01-01'
```

### 3. Use Staging Views to Avoid Repeated JOINs
```sql
-- Create once
CREATE VIEW stg_order_customer AS
SELECT o.*, c.customer_name FROM orders o JOIN customers c ...

-- Use many times
SELECT ... FROM stg_order_customer ...
```

### 4. Limit Window Function Scope
```sql
-- GOOD: Partition to reduce scope
RANK() OVER (PARTITION BY category ORDER BY sales DESC)

-- AVOID: Full table sort
RANK() OVER (ORDER BY sales DESC)  -- If category ranking is enough
```

---

## Common Query Patterns

### 1. Top N per Group
```sql
WITH ranked AS (
    SELECT
        category,
        product_name,
        sales,
        RANK() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM products
)
SELECT * FROM ranked WHERE rn <= 5;
```

### 2. Running Total
```sql
SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM daily_sales;
```

### 3. Percentage of Total
```sql
SELECT
    category,
    revenue,
    ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS pct_of_total
FROM category_sales;
```

### 4. Year-over-Year Growth
```sql
SELECT
    year,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY year) AS prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue, 1) OVER (ORDER BY year)) * 100.0
        / LAG(revenue, 1) OVER (ORDER BY year),
        2
    ) AS yoy_growth_pct
FROM annual_sales;
```

### 5. Finding Gaps (No Orders)
```sql
SELECT c.*
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.customer_id IS NULL;
```

---

## Best Practices Summary

1. **CTEs for Readability:** Break complex queries into named steps
2. **Window Functions for Analytics:** Avoid self-joins when possible
3. **COALESCE for NULL Handling:** Prevent unexpected NULLs in reports
4. **NULLIF for Safe Division:** Avoid division by zero errors
5. **Staging Layer:** Pre-compute common transformations
6. **Descriptive Names:** Use clear CTE and column names
7. **Comments:** Explain business logic, not obvious syntax
8. **Formatting:** Consistent indentation and line breaks
9. **Test Incrementally:** Build CTEs one at a time
10. **Index Strategically:** On FK, date, and WHERE columns

---

## Quick Reference Table

| Task | Function/Pattern | Example |
|------|------------------|---------|
| Previous row | `LAG()` | `LAG(revenue) OVER (ORDER BY date)` |
| Next row | `LEAD()` | `LEAD(revenue) OVER (ORDER BY date)` |
| Percentile buckets | `NTILE(n)` | `NTILE(5) OVER (ORDER BY value)` |
| Ranking | `RANK()` | `RANK() OVER (ORDER BY sales DESC)` |
| Sequential number | `ROW_NUMBER()` | `ROW_NUMBER() OVER (PARTITION BY customer ORDER BY date)` |
| Running total | `SUM() OVER()` | `SUM(qty) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING)` |
| % of total | Division by total | `value / SUM(value) OVER () * 100` |
| Safe division | `NULLIF()` | `value / NULLIF(divisor, 0)` |
| Default for NULL | `COALESCE()` | `COALESCE(status, 'Unknown')` |
| Conditional value | `CASE WHEN` | `CASE WHEN x > 10 THEN 'High' ELSE 'Low' END` |
| Days between | `DATEDIFF()` | `DATEDIFF(CURRENT_DATE, order_date)` |
| Months between | `TIMESTAMPDIFF()` | `TIMESTAMPDIFF(MONTH, date1, date2)` |
| Format date | `DATE_FORMAT()` | `DATE_FORMAT(date, '%Y-%m')` |
| Subtotals | `WITH ROLLUP` | `GROUP BY a, b WITH ROLLUP` |
| Detect rollup | `GROUPING()` | `GROUPING(column)` |
| Combine strings | `CONCAT()` | `CONCAT(first, ' ', last)` |

---

**End of Cheat Sheet**

*This document covers all major SQL concepts used in the Customer Orders Analytics Project. Refer to specific query files in `outputs_week_02/` for complete implementations.*
