# Customer Orders Schema and Reporting

## Overview
This project builds a MySQL schema for customers, products, orders, and order_items, loads realistic sample data (100+ rows per table), and provides reporting queries and views.

## Structure
- sql/: database creation, schema, inserts, reports, views, and indexes
- outputs/: CSV exports for required reports

## How to Run
1. Run sql/00_create_database.sql
2. Run sql/01_schema.sql
3. Run sql/02_insert_customers.sql through sql/05_insert_order_items.sql
4. Run sql/07_views.sql
5. (Optional) Run sql/08_indexes.sql
6. Run sql_week_01/06_reports.sql (non-optimized) and export each result to outputs_csv/

## Notes
- orders.total_amount aligns with order_items.line_total because each order has one order item in the sample data.
- Some customers have no orders to support the required report.
