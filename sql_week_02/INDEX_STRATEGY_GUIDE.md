# Index Strategy for 12 Week_02 Queries

## Overview
This document outlines the optimal indexing strategy for all 12 advanced optimization queries in Week_02, organized by query and intended to maximize performance for complex analytical workloads.

---

## Query-by-Query Index Mapping

### **Query 01: Monthly Revenue Trend with MoM % Change**
- **Primary Operations**: Filter by order_status + GROUP BY date, Aggregate SUM(total_amount)
- **Recommended Indexes**:
  - `idx_stg_order_facts_status_date` → (order_status, order_date)
  - **Rationale**: Composite index supports both WHERE filter and GROUP BY date extraction

### **Query 02: RFM Customer Scoring**
- **Primary Operations**: Filter order_count, Window partitions on scores, ORDER BY rfm_total
- **Recommended Indexes**:
  - `idx_rpt_customer_rfm_order_count` → (order_count, customer_id)
  - `idx_rpt_customer_rfm_lifetime_value` → (lifetime_value DESC, customer_id)
  - **Rationale**: NTILE window functions on three metrics (recency, frequency, monetary); indexes support both filtering and window function calculations

### **Query 03: Customer Cohort Retention Table**
- **Primary Operations**: JOIN customer_cohorts + stg_order_facts on customer_id, GROUP BY cohort_month + month_offset
- **Recommended Indexes**:
  - `idx_stg_order_facts_customer_date` → (customer_id, order_date)
  - `idx_rpt_customer_rfm_order_count` → (order_count, customer_id)
  - **Rationale**: JOIN on customer_id; TIMESTAMPDIFF on dates needs date index; filtered on order_count > 0

### **Query 04: First vs Repeat Purchase Revenue Split**
- **Primary Operations**: ROW_NUMBER() PARTITION BY customer_id ORDER BY order_date, Aggregate SUM/COUNT
- **Recommended Indexes**:
  - `idx_stg_order_facts_customer_order_date` → (customer_id, order_date, total_amount)
  - **Rationale**: Covering index supports partition, order, and aggregation in single lookup

### **Query 05: Customer Churn Risk Segmentation**
- **Primary Operations**: Filter days_since_last_order ranges, ORDER BY risk_level + lifetime_value
- **Recommended Indexes**:
  - `idx_rpt_customer_rfm_days_since` → (days_since_last_order, customer_id)
  - **Rationale**: Primary filter; sorting on calculated CASE ranges

### **Query 06: Product Margin Ranking by Category**
- **Primary Operations**: GROUP BY product_id + category, RANK() PARTITION BY category ORDER BY margin_pct
- **Recommended Indexes**:
  - `idx_stg_product_sales_category_product` → (category, product_id, product_name, quantity, line_margin)
  - **Rationale**: Covering index supports both GROUP BY and PARTITION BY category

### **Query 07: Low Stock & Restock Alert Report**
- **Primary Operations**: Filter stock_health IN (...), ORDER BY priority_rank + stock_pct
- **Recommended Indexes**:
  - `idx_stg_inventory_health_status_pct` → (stock_health, stock_pct, product_id)
  - **Rationale**: Primary filter on stock_health; secondary sort on stock_pct

### **Query 08: Return Rate by Product and Category**
- **Primary Operations**: GROUP BY category + product_id + product_name, ROLLUP with aggregates
- **Recommended Indexes**:
  - `idx_stg_product_sales_category_returns` → (category, product_id, product_name, is_returned, order_item_id, revenue, refund_amount)
  - **Rationale**: Covering index supports GROUP BY, ROLLUP aggregations, and return calculation

### **Query 09: Top and Bottom 5 Products by Net Revenue**
- **Primary Operations**: RANK() ORDER BY net_revenue, UNION ALL for top/bottom split
- **Recommended Indexes**:
  - `idx_rpt_product_dashboard_net_revenue` → (units_sold, net_revenue DESC, product_id)
  - **Rationale**: Descending index on net_revenue for RANK; filter on units_sold > 0

### **Query 10: Promotion Effectiveness Report**
- **Primary Operations**: Filter has_promotion (0/1), Aggregate SUM/AVG/COUNT, UNION two SELECT blocks
- **Recommended Indexes**:
  - `idx_stg_order_facts_promotion` → (has_promotion, total_amount, order_id)
  - `idx_rpt_promotion_impact_redemption_revenue` → (redemption_count, net_revenue_generated DESC, promo_code)
  - **Rationale**: Two-part query needs indexes on has_promotion filter and promotion detail ranking

### **Query 11: Weekly Sales Heatmap (Day of Week x Week)**
- **Primary Operations**: GROUP BY order_year + week_number, Pre-pivoted DOW columns
- **Recommended Indexes**:
  - `idx_rpt_sales_heatmap_year_week` → (order_year, week_number)
  - **Rationale**: Simple composite supporting GROUP BY year + week; DOW columns already pre-aggregated in view

### **Query 12: Category Revenue Breakdown with Subtotals**
- **Primary Operations**: GROUP BY category + product_name WITH ROLLUP, Aggregate SUM/AVG/COUNT
- **Recommended Indexes**:
  - `idx_stg_product_sales_category_revenue` → (category, product_name, order_id, quantity, revenue, line_margin, margin_pct)
  - **Rationale**: Covering index supports ROLLUP on category/product_name and all aggregations

---

## Index Creation Order (SQL Execution)

To ensure optimal performance, create indexes in this order:

1. **Staging Table Indexes** (Core performance)
   ```
   idx_stg_order_facts_status_date
   idx_stg_order_facts_customer_date
   idx_stg_order_facts_customer_order_date
   idx_stg_order_facts_promotion
   idx_stg_product_sales_category_product
   idx_stg_product_sales_category_returns
   idx_stg_product_sales_category_revenue
   idx_stg_inventory_health_status_pct
   ```

2. **Reporting Table Indexes** (View support)
   ```
   idx_rpt_customer_rfm_order_count
   idx_rpt_customer_rfm_days_since
   idx_rpt_customer_rfm_lifetime_value
   idx_rpt_product_dashboard_net_revenue
   idx_rpt_promotion_impact_redemption_revenue
   idx_rpt_sales_heatmap_year_week
   ```

3. **Base Table Indexes** (Underlying data support)
   ```
   idx_orders_status_date
   idx_orders_customer_date
   idx_order_items_order_product
   idx_returns_order_item_status
   idx_returns_product_status
   idx_products_category_price
   idx_order_promotions_order_promo
   idx_product_inventory_stock_level
   ```

---

## Index Performance Characteristics

| Index | Selectivity | Coverage | Benefit |
|-------|------------|----------|---------|
| (status, order_date) | High | Partial | Query 1 filter + GROUP BY |
| (customer_id, order_date, total_amount) | High | Full | Query 4 ROW_NUMBER + aggregation |
| (category, product_id, ...) | Medium | Full | Queries 6, 8, 12 GROUP BY + rollups |
| (stock_health, stock_pct) | Medium | Partial | Query 7 filter + ORDER BY |
| (has_promotion, total_amount, order_id) | High | Partial | Query 10 split analysis |

---

## Composite Index Strategy

### **Why Composite Indexes?**
- **Single-column efficiency**: Better than multiple single-column indexes
- **Index intersection**: Query optimizer can skip base table lookups
- **JOIN optimization**: Column order matters: JOIN columns first, then filter columns, then aggregation columns

### **Column Ordering Rules Applied**
1. **Equality filters** come first (status, category, has_promotion)
2. **Range/BETWEEN filters** come second (order_date, days_since_last_order)
3. **Aggregate columns** come last (total_amount, line_margin, refund_amount)

---

## Covering Index Considerations

For complex queries with large result sets, consider these covering indexes:

```sql
-- Query 4 covering index (skip base table entirely)
CREATE UNIQUE INDEX idx_orders_items_covering 
    ON order_items(order_id, product_id, quantity, unit_price, line_total);

-- Query 6 covering index (product margins)
CREATE INDEX idx_product_sales_covering 
    ON stg_product_sales_detail(category, product_id, margin_pct, quantity, line_margin);
```

---

## Validation & Monitoring

### **Check Indexes After Creation**
```sql
-- View all indexes on staging tables
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX 
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'customer_orders' 
  AND TABLE_NAME LIKE 'stg_%'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- View all indexes on reporting tables
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME, SEQ_IN_INDEX 
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'customer_orders' 
  AND TABLE_NAME LIKE 'rpt_%'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
```

### **Force Statistics Update (MySQL 8.0)**
```sql
ANALYZE TABLE stg_order_facts;
ANALYZE TABLE stg_product_sales_detail;
ANALYZE TABLE stg_inventory_health;
ANALYZE TABLE rpt_customer_rfm;
ANALYZE TABLE rpt_product_dashboard;
ANALYZE TABLE rpt_promotion_impact;
ANALYZE TABLE rpt_sales_heatmap;
```

### **Verify Query Plan**
```sql
EXPLAIN FORMAT=JSON SELECT ... -- Run with created indexes
-- Look for "used_index" field; if missing, review index creation
```

---

## Performance Impact Summary

| Phase | Expected Improvement | Notes |
|-------|----------------------|-------|
| **Staging Table Indexes** | 40-60% faster | Biggest impact on complex GROUP BY |
| **Reporting Table Indexes** | 20-30% faster | Pre-aggregated tables already optimized |
| **Base Table Indexes** | 15-25% faster | Support for view materialization |
| **Total Expected** | **60-80% faster** | Cumulative effect across all 12 queries |

---

## Next Steps

1. ✅ Execute `09_indexes_week_02.sql` in your MySQL client
2. ✅ Run `ANALYZE TABLE` statements to update statistics
3. ✅ Re-run each of the 12 optimized queries and compare execution times
4. ✅ Monitor `EXPLAIN` output for "Using index" vs "Using temporary"
5. ✅ Keep statistics updated weekly with `ANALYZE TABLE` commands

