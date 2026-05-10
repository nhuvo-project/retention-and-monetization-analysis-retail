-- =========================================
-- 02_feature_engineering.sql
-- Purpose: Create analytical features for retention, monetization, and behavioral analysis
-- =========================================

CREATE OR REPLACE VIEW `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data` AS

WITH order_count AS (
  SELECT
    user_id,
    COUNT(DISTINCT order_id) AS unique_order_count

  FROM `just-cosmos-479109-p7.thelook_clean.cleaned_transaction_data`

  GROUP BY user_id
)

SELECT
  s.*,

  -- Discount intensity
  ROUND((retail_price - sale_price) / retail_price, 4)
    AS discount_percentage,

  CASE
    WHEN retail_price = sale_price THEN 'Full Price'
    WHEN (retail_price - sale_price) / retail_price <= 0.2
      THEN 'Light Discount'
    WHEN (retail_price - sale_price) / retail_price <= 0.5
      THEN 'Mid Discount'
    ELSE 'High Discount'
  END AS discount_tier,

  -- Standardized order lifecycle
  CASE
    WHEN status = 'Returned' THEN 'Returned'
    WHEN status IN ('Delivered', 'Complete', 'Success')
      THEN 'Completed'
    ELSE 'In Progress'
  END AS order_status,

  -- Customer purchase behavior
  CASE
    WHEN oc.unique_order_count = 1
      THEN 'One time buyer'
    ELSE 'Repeat buyer'
  END AS customer_type_lifetime,

  -- Monthly cohort alignment
  DATE_TRUNC(DATE(created_at), MONTH)
    AS order_month

FROM `just-cosmos-479109-p7.thelook_clean.cleaned_transaction_data` AS s

LEFT JOIN order_count AS oc
  ON s.user_id = oc.user_id;
