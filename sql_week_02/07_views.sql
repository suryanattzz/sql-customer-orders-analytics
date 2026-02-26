-- ================================================================
-- LAYERED SQL PIPELINE FOR WEEK 2
-- ================================================================
-- Layer 1: Raw Data (base tables - already created)
-- Layer 2: Staging/Cleaned Views (data transformation)
-- Layer 3: Aggregated Reporting Views (business metrics)
-- ================================================================

USE customer_orders;

-- ================================================================
-- LAYER 2: STAGING / CLEANED VIEWS
-- ================================================================

-- Staging: Clean order data with customer and status information
CREATE OR REPLACE VIEW stg_orders_enriched AS
SELECT
    o.order_id,
    o.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.city,
    o.order_date,
    COALESCE(o.status, 'Unknown') AS status,
    o.total_amount,
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    QUARTER(o.order_date) AS order_quarter,
    DAYOFWEEK(o.order_date) AS day_of_week,
    WEEK(o.order_date) AS week_number
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;


-- Staging: Order items with product details and margin calculation
CREATE OR REPLACE VIEW stg_order_items_enriched AS
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    p.product_name,
    p.category,
    p.price AS product_price,
    p.cost AS product_cost,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    (p.price - p.cost) AS unit_margin,
    ((p.price - p.cost) / NULLIF(p.price, 0)) * 100 AS margin_percentage,
    oi.line_total - (p.cost * oi.quantity) AS line_margin
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id;


-- Staging: Returns with order and product context
CREATE OR REPLACE VIEW stg_returns_enriched AS
SELECT
    r.return_id,
    r.order_item_id,
    r.order_id,
    r.product_id,
    r.customer_id,
    r.return_reason,
    r.return_status,
    r.refund_amount,
    r.returned_at,
    r.processed_at,
    DATEDIFF(r.processed_at, r.returned_at) AS processing_days,
    CASE
        WHEN r.processed_at IS NULL THEN 'Pending'
        WHEN DATEDIFF(r.processed_at, r.returned_at) <= 3 THEN 'Fast'
        WHEN DATEDIFF(r.processed_at, r.returned_at) <= 7 THEN 'Normal'
        ELSE 'Slow'
    END AS processing_speed
FROM returns r;


-- Staging: Promotions with active status
CREATE OR REPLACE VIEW stg_promotions_active AS
SELECT
    promo_id,
    promo_code,
    promo_name,
    discount_type,
    discount_value,
    min_order_value,
    usage_limit,
    times_used,
    start_date,
    end_date,
    CASE
        WHEN CURRENT_DATE BETWEEN start_date AND end_date THEN 'Active'
        WHEN CURRENT_DATE < start_date THEN 'Scheduled'
        ELSE 'Expired'
    END AS promo_status,
    CASE
        WHEN usage_limit IS NULL THEN 999999
        ELSE usage_limit - times_used
    END AS remaining_uses
FROM promotions;


-- Staging: Inventory with stock status flags
CREATE OR REPLACE VIEW stg_inventory_status AS
SELECT
    pi.inventory_id,
    pi.product_id,
    p.product_name,
    p.category,
    pi.stock_quantity,
    pi.reserved_quantity,
    pi.stock_quantity - pi.reserved_quantity AS available_quantity,
    pi.restock_threshold,
    pi.restock_quantity,
    pi.unit_cost,
    pi.last_restocked_at,
    CASE
        WHEN pi.stock_quantity <= 0 THEN 'Out of Stock'
        WHEN pi.stock_quantity <= pi.restock_threshold THEN 'Low Stock'
        WHEN pi.stock_quantity <= pi.restock_threshold * 1.5 THEN 'Moderate'
        ELSE 'Adequate'
    END AS stock_status,
    CASE
        WHEN pi.stock_quantity <= pi.restock_threshold THEN 'URGENT'
        WHEN pi.stock_quantity <= pi.restock_threshold * 1.3 THEN 'MODERATE'
        ELSE 'LOW'
    END AS restock_priority
FROM product_inventory pi
JOIN products p ON p.product_id = pi.product_id;


-- ================================================================
-- LAYER 3: AGGREGATED REPORTING VIEWS
-- ================================================================

-- Report: Customer order summary with lifetime metrics
CREATE OR REPLACE VIEW rpt_customer_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_value,
    COALESCE(AVG(o.total_amount), 0) AS avg_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURRENT_DATE, MAX(o.order_date)) AS days_since_last_order,
    CASE
        WHEN COUNT(DISTINCT o.order_id) = 0 THEN 'No Orders'
        WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.city;


-- Report: Product performance with sales and returns
CREATE OR REPLACE VIEW rpt_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.cost,
    COUNT(DISTINCT oi.order_id) AS times_sold,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    COALESCE(COUNT(r.return_id), 0) AS return_count,
    COALESCE(SUM(r.refund_amount), 0) AS total_refunds,
    ROUND(
        COALESCE(COUNT(r.return_id), 0) * 100.0 / NULLIF(COUNT(DISTINCT oi.order_item_id), 0),
        2
    ) AS return_rate_pct
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN returns r ON r.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price, p.cost;


-- Report: Monthly revenue trends
CREATE OR REPLACE VIEW rpt_monthly_revenue AS
SELECT
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    DATE_FORMAT(o.order_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM orders o
GROUP BY YEAR(o.order_date), MONTH(o.order_date), DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY year, month;


-- Report: Category performance breakdown
CREATE OR REPLACE VIEW rpt_category_performance AS
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT oi.order_id) AS order_count,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.line_total) AS total_revenue,
    AVG(p.price) AS avg_product_price,
    SUM(oi.line_total - (p.cost * oi.quantity)) AS total_margin
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category;


-- Report: Promotion effectiveness
CREATE OR REPLACE VIEW rpt_promotion_effectiveness AS
SELECT
    pr.promo_id,
    pr.promo_code,
    pr.promo_name,
    pr.discount_type,
    pr.discount_value,
    COUNT(DISTINCT op.order_id) AS times_used,
    SUM(op.discount_applied) AS total_discount_given,
    AVG(op.discount_applied) AS avg_discount_per_order,
    SUM(o.total_amount) AS revenue_with_promo,
    AVG(o.total_amount) AS avg_order_value_with_promo
FROM promotions pr
LEFT JOIN order_promotions op ON op.promo_id = pr.promo_id
LEFT JOIN orders o ON o.order_id = op.order_id
GROUP BY pr.promo_id, pr.promo_code, pr.promo_name, pr.discount_type, pr.discount_value;


-- Report: Inventory alerts (low stock items)
CREATE OR REPLACE VIEW rpt_inventory_alerts AS
SELECT
    pi.product_id,
    p.product_name,
    p.category,
    pi.stock_quantity,
    pi.reserved_quantity,
    pi.stock_quantity - pi.reserved_quantity AS available_quantity,
    pi.restock_threshold,
    pi.restock_quantity,
    CASE
        WHEN pi.stock_quantity <= 0 THEN 'CRITICAL'
        WHEN pi.stock_quantity <= pi.restock_threshold * 0.5 THEN 'URGENT'
        WHEN pi.stock_quantity <= pi.restock_threshold THEN 'MODERATE'
        ELSE 'LOW'
    END AS alert_level,
    pi.last_restocked_at,
    DATEDIFF(CURRENT_DATE, pi.last_restocked_at) AS days_since_restock
FROM product_inventory pi
JOIN products p ON p.product_id = pi.product_id
WHERE pi.stock_quantity <= pi.restock_threshold
ORDER BY pi.stock_quantity ASC;
