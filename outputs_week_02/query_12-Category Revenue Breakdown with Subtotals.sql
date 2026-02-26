-- 12)Category Revenue Breakdown with Subtotals 


with cte as (select 
p.product_name,
p.category,
oi.line_total 
from products p
left join order_items oi 
on p.product_id = oi.product_id
)

SELECT
  CASE
    WHEN category IS NULL THEN 'Grand Total'
    ELSE category
  END AS category,
  CASE
    WHEN product_name IS NULL AND category IS NOT NULL
      THEN 'Category Subtotal'
    WHEN product_name IS NULL AND category IS NULL
      THEN 'Grand Total'
    ELSE product_name
  END AS product_name,
  SUM(line_total) AS revenue
FROM cte
GROUP BY category, product_name with rollup;