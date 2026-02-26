# 📊 Customer Orders Schema & Analytics Platform

A comprehensive **MySQL database project** featuring a production-ready e-commerce schema, 18+ analytical queries, and advanced reporting dashboards—combining AI-assisted database architecture with hand-crafted analytical queries for business intelligence.

---

## 🎯 Project Overview

This project demonstrates end-to-end data engineering and analytics:
- **Phase 1 (Week 01)**: Core e-commerce schema with foundational business reports
- **Phase 2 (Week 02)**: Advanced analytics covering RFM segmentation, cohort retention, churn prediction, and inventory management

**Real-world use case**: Support e-commerce decision-making through customer segmentation, product performance analysis, and operational dashboards.

---

## 👥 Credits

| Component | Created By |
|-----------|-----------|
| **Database Schema** | AI-Assisted Design |
| **Sample Data** | AI-Generated (100+ Indian customers, normalized sample datasets) |
| **Analytical Queries** | Hand-Crafted by Surya |
| **Data Integration** | Manual ETL & Validation |
| **Documentation** | Collaborative |

---

## 🏗️ Database Architecture

### **Core Tables (5)**

| Table | Purpose | Records | Key Relationships |
|-------|---------|---------|-------------------|
| `customers` | Customer profiles & metadata | 100 | PK: customer_id |
| `products` | Product catalog with pricing | 100 | PK: product_id |
| `orders` | Order transactions | 100 | FK: customer_id |
| `order_items` | Line items per order | 100+ | FKs: order_id, product_id |
| `returns` | Return/refund records | 100 | FKs: order_item_id, product_id |

### **Extended Tables (3)**

| Table | Purpose |
|-------|---------|
| `promotions` | Discount campaigns and coupon codes |
| `order_promotions` | Mapping orders to promotions applied |
| `product_inventory` | Stock levels and reorder tracking |

### **Data Integrity Features**

✅ **Foreign Key Constraints** with CASCADE/RESTRICT policies  
✅ **Data Validation**: orders.total_amount = SUM(order_items.line_total)  
✅ **Realistic Distribution**: Customers with 0, 1, or multiple orders  
✅ **Nullable Status**: ~10% of orders have NULL status (real-world scenario)  
✅ **Time-Series Data**: Orders distributed across 180-day period with shared dates

---

## 📈 Week 01: Foundation Reports (6 Queries)

**Goal**: Establish core business metrics and dashboards

### Query Portfolio

1. **Revenue Trends**
   - Daily and weekly revenue aggregations
   - Identifies peak sales periods and seasonal patterns
   - Output: `Revenue by Day.csv`, `Revenue by Week.csv`

2. **Top 5 Products**
   - Products ranked by revenue and quantity sold
   - Highlights best & worst performers
   - Output: `Top 5 Products based on Revenue.csv`, `Top 5 Products based on Quantity.csv`

3. **Customer Segmentation**
   - Classifies customers as "One-Time", "Repeat", or "No Orders"
   - Enables targeted marketing campaigns
   - Output: `Customer classification (Repeat vs. One-Time).csv`

4. **Customer Lifetime Value (LTV)**
   - Top 5 revenue-generating customers + LTV ranking
   - Identifies VIP customers for retention strategies
   - Output: `Top 5 revenue-generating customers.csv`, `Customer lifetime value.csv`

5. **No-Order Customers**
   - Identifies 10 customers with no purchase history
   - Opportunity for win-back campaigns
   - Output: `Identification of customers with no orders.csv`

6. **Data Exports**
   - Base table exports (customers, products, orders, order_items)
   - Foundation for data pipelines and integration
   - Output: `*_table.csv` (4 files)

### Technical Implementation

```sql
-- Example: Customer Classification with CASE Logic
SELECT 
    customer_id,
    customer_name,
    COUNT(o.order_id) AS order_count,
    CASE 
        WHEN COUNT(o.order_id) = 0 THEN 'No Orders'
        WHEN COUNT(o.order_id) = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    ROUND(SUM(o.total_amount), 2) AS lifetime_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY lifetime_value DESC;
```

---

## 🔬 Week 02: Advanced Analytics (12 Queries)

**Goal**: Unlock deep customer and product insights through sophisticated analytics

### 1️⃣ **Customer Analytics (5 Queries)**

#### Query 01: Monthly Revenue Trend with MoM % Change
- Tracks month-over-month revenue growth/decline
- Identifies revenue seasonality and trend direction
- **SQL Technique**: Window functions (LAG), date extraction, arithmetic
- **Business Use**: Revenue forecasting, growth tracking

#### Query 02: RFM Customer Scoring
- **Recency** (R): Days since last purchase  
- **Frequency** (F): Number of orders placed  
- **Monetary** (M): Total amount spent  
- Score range: 1-5 per metric; combos like 555 = "Champions", 321 = "Potential"
- **SQL Technique**: NTILE() window functions for percentile-based bucketing
- **Business Use**: Segment customers for personalized campaigns

#### Query 03: Customer Cohort Retention Table
- Tracks cohort (first-purchase-month) retention over 12 months
- Measures month-by-month repeat purchase behavior
- **SQL Technique**: Self-joins, TIMESTAMPDIFF, MONTH aggregations
- **Business Use**: Evaluate product/marketing effectiveness cohort-by-cohort

#### Query 05: Customer Churn Risk Segmentation
- Categorizes customers: "Active (0-30d)", "Moderate Risk (31-60d)", "High Risk (61-90d)", "Churned (90+d)"
- Triggers automated re-engagement campaigns
- **SQL Technique**: CASE expressions with date ranges
- **Business Use**: Proactive retention, churn prevention

#### Query 04: First Purchase vs Repeat Purchase Split
- Compares first-time buyer revenue vs repeat buyer revenue
- Measures repeat purchase contribution to total revenue
- **SQL Technique**: ROW_NUMBER() PARTITION BY for purchase sequencing
- **Business Use**: Optimize acquisition vs retention spending

### 2️⃣ **Product Analytics (4 Queries)**

#### Query 06: Product Margin Ranking by Category
- Ranks products within each category by profit margin %
- Identifies high-margin products to promote
- **SQL Technique**: RANK() window function partitioned by category
- **Business Use**: Pricing optimization, portfolio management

#### Query 08: Return Rate by Product & Category
- Calculates return % for each product and category
- Identifies quality issues or customer expectations mismatches
- **SQL Technique**: ROLLUP for multi-level subtotals, conditional aggregation
- **Business Use**: Quality control, product improvement prioritization

#### Query 09: Top & Bottom 5 Products by Net Revenue
- Net revenue = Gross revenue - refunds (after returns)
- Identifies most and least profitable products
- **SQL Technique**: RANK() with UNION ALL for dual ranking
- **Business Use**: Portfolio pruning, discontinuation decisions

#### Query 07: Low Stock & Restock Alert Report
- Flags products below reorder levels
- Categorized by urgency (OUT_OF_STOCK → CRITICAL → LOW → WATCH)
- **SQL Technique**: Inventory status classification with priority ranking
- **Business Use**: Prevent stockouts, optimize inventory levels

### 3️⃣ **Operational Analytics (3 Queries)**

#### Query 10: Promotion Effectiveness Report
- Compares order metrics: with promotion vs without promotion
- Measures net revenue per redemption
- **SQL Technique**: UNION ALL for comparison analysis, LAG() for AOV differences
- **Business Use**: ROI analysis, campaign budget allocation

#### Query 11: Weekly Sales Heatmap (Day-of-Week × Week)
- Pivot table showing sales by day-of-week and week number
- Identifies best-selling days and seasonal patterns
- **SQL Technique**: Pre-pivoted aggregations, conditional aggregation
- **Business Use**: Staffing optimization, flash sale timing

#### Query 12: Category Revenue Breakdown with Subtotals
- Revenue by category → product-level detail → grand total
- Hierarchical rollup showing contribution percentages
- **SQL Technique**: ROLLUP WITH GROUP BY, GROUPING() functions
- **Business Use**: P&L reporting, category performance dashboards

---

## 🗂️ Project Structure

```
customer-orders-sql-project/
├── sql_week_01/                    ← Core database setup
│   ├── 00_create_database.sql      # Database initialization
│   ├── 01_schema.sql               # Table definitions & relationships
│   ├── 02_insert_customers.sql     # 100 Indian customers + metadata
│   ├── 03_insert_products.sql      # 100 products across 6 categories
│   ├── 04_insert_orders.sql        # 100 orders with realistic distribution
│   ├── 05_insert_order_items.sql   # 101 line items with pricing
│   ├── 06_reports.sql              # 6 business intelligence queries
│   ├── 07_views.sql                # Reusable views for reports
│   └── 08_indexes.sql              # Query optimization indexes
│
├── sql_week_02/                    ← Advanced analytics & extensions
│   ├── 00_create_database.sql      # Database setup reference
│   ├── 01_schema.sql               # Extended schema with returns, promotions
│   ├── 02_insert_returns.sql       # 100 return transactions
│   ├── 03_insert_promotions.sql    # 50 promotional campaigns
│   ├── 04_insert_order_promotions.sql
│   ├── 05_insert_product_inventory.sql
│   └── 09_indexes_week_02.sql      # 18+ indexes for Week 02 analytics
│
├── outputs_week_02/                ← Hand-crafted analytics queries
│   ├── query_01_MOM%change.sql              # Monthly revenue trend
│   ├── query_02_RFM_customer_score.sql      # RFM segmentation
│   ├── query_03_Customer Cohort Retention.sql
│   ├── query_04_First vs Repeat Revenue.sql
│   ├── query_05_Customer Churn Risk.sql
│   ├── query_06_Product Margin Ranking.sql
│   ├── query_07_Low-Stock Restock Alert.sql
│   ├── query_08_Return Rate by Product.sql
│   ├── query_09_Top Bottom Products.sql
│   ├── query_10_Promotion Effectiveness.sql
│   ├── query_11_Weekly Sales Heatmap.sql
│   └── query_12_Category Breakdown.sql
│
├── outputs_csv/                    ← Query result exports
│   ├── Revenue by Day.csv
│   ├── Top 5 Products based on Revenue.csv
│   ├── Customer lifetime value.csv
│   └── ... (15+ CSV exports)
│
├── ERD Diagrams_week_01/           ← Database relationship diagrams
└── ERD Diagrams_week_02/
```

---

## 🚀 Quick Start

### **Prerequisites**
- MySQL 8.0+ (local or remote)
- VS Code with SQLTools extension
- Git (for version control)

### **Installation Steps**

```bash
# 1. Clone repository
git clone https://github.com/suryanattzz/sql-customer-orders-analytics.git
cd sql-customer-orders-analytics

# 2. Execute Week 01 setup (in order)
mysql -u root -p < sql_week_01/00_create_database.sql
mysql -u root -p < sql_week_01/01_schema.sql
mysql -u root -p < sql_week_01/02_insert_customers.sql
mysql -u root -p < sql_week_01/03_insert_products.sql
mysql -u root -p < sql_week_01/04_insert_orders.sql
mysql -u root -p < sql_week_01/05_insert_order_items.sql

# 3. Create views for reports
mysql -u root -p < sql_week_01/07_views.sql

# 4. (Optional) Create indexes for optimization
mysql -u root -p < sql_week_01/08_indexes.sql

# 5. Run reports and export to CSV
mysql -u root -p < sql_week_01/06_reports.sql
# Copy output to outputs_csv/
```

### **Running Queries**

Open any `.sql` file in VS Code → SQLTools → Execute → Export to CSV

---

## 📊 Technical Highlights

### **Database Features**
- ✅ Normalized schema (3NF) with referential integrity
- ✅ Composite primary & foreign keys
- ✅ Indexes on frequently queried columns (18+ indexes)
- ✅ Views for query abstraction and reusability

### **SQL Techniques Demonstrated**
| Technique | Example | Week |
|-----------|---------|------|
| Window Functions | NTILE(), RANK(), ROW_NUMBER(), LAG() | Week 02 |
| CTEs & WITH Clauses | Staging data for complex calculations | Week 02 |
| ROLLUP & GROUPING | Multi-level aggregations with subtotals | Week 02 |
| Conditional Aggregation | SUM(CASE WHEN...) for metric splits | Both |
| Date Functions | DATEDIFF(), TIMESTAMPDIFF(), DATE_FORMAT() | Both |
| Self-Joins | Cohort retention, repeat purchase analysis | Week 02 |
| Composite Indexes | (column1, column2, column3) optimization | Both |

### **Data Quality**
- 100+ customers with realistic distribution (some with 0 orders, some with 6+)
- 100 products across 6 categories (Electronics, Home, Apparel, Sports, Beauty, Grocery)
- 100 orders with shared dates (realistic scenario)
- ~10% NULL status in orders (business logic)
- Orders.total_amount = SUM(order_items.line_total) ✅ Validated

---

## 📁 CSV Output Summary

| File | Records | Purpose |
|------|---------|---------|
| `Revenue by Day.csv` | 50+ days | Daily sales tracking |
| `Revenue by Week.csv` | 14+ weeks | Weekly aggregation |
| `Top 5 Products based on Revenue.csv` | 5 products | Revenue leaders |
| `Top 5 Products based on Quantity.csv` | 5 products | Volume leaders |
| `Customer classification.csv` | 100 customers | Buyer type segmentation |
| `Customer lifetime value.csv` | 5 customers | Top spenders |
| `*_table.csv` | Base data | Customers, products, orders, items |

---

## 🔧 Maintenance & Optimization

- **Indexes**: 18+ composite indexes optimized for analytical queries
- **Query Performance**: Queries execute in <100ms with indexes
- **Data Consistency**: Foreign key constraints prevent orphaned records
- **Documentation**: Each query includes SQL techniques and business rationale

---

## 📚 Learning Resources

- **SQL Techniques**: Window functions, CTEs, ROLLUP, indexes
- **Database Design**: Normalization, relationships, referential integrity
- **Business Analytics**: RFM analysis, cohort retention, churn prediction, margin analysis
- **Data Engineering**: ETL patterns, data validation, export pipelines

---

## 📝 Notes

- Schema created with AI assistance for structure; queries hand-crafted for business insights
- Sample data is anonymized with Indian naming conventions
- CSV exports are in Week 01 format; Week 02 focuses on SQL query development
- All queries are non-optimized versions; optimization notes available in documentation
- Git repo excludes optimized query variants and documentation files (focus on core analytics)

---

## 🤝 Contributing

This is a personal learning project. For questions or suggestions:
- Review query documentation in each SQL file
- Check ERD diagrams for schema relationships
- Refer to SQL_CHEAT_SHEET.md for quick SQL reference

---

## 📄 License

Open for educational and portfolio use.

---

**Created**: February 2026  
**Repository**: https://github.com/suryanattzz/sql-customer-orders-analytics  
**Status**: Complete (Week 1 & 2)
