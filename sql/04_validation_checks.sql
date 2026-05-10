-- =========================================
-- 04_validation_checks.sql
-- Purpose: Validate data integrity before and after transformation to ensure analytical
-- consistency and prevent unintended issues introduced during cleaning and enrichment
-- =========================================



-- =========================================
-- Validation 1. Raw transactional completeness check
-- Objective: Identify missing critical fields in the source transactional dataset before transformation
-- =========================================

SELECT 
  COUNT(*) AS total_row,

  COUNTIF(order_id IS NULL) AS null_order,
  COUNTIF(user_id IS NULL) AS null_user,
  COUNTIF(product_id IS NULL) AS null_product,
  COUNTIF(inventory_item_id IS NULL) AS null_inventory,
  COUNTIF(status IS NULL) AS null_status,
  COUNTIF(sale_price IS NULL) AS null_sale_price

FROM `bigquery-public-data.thelook_ecommerce.order_items`;



-- =========================================
-- Validation 2. Source table uniqueness check
-- Objective: Verify primary identifier uniqueness across source dimension and transaction tables
-- =========================================

SELECT
  'user' AS table_name,

  COUNT(*) AS total_id,
  COUNT(DISTINCT id) AS unique_id,
  COUNT(*) - COUNT(DISTINCT id) AS duplicate_id

FROM bigquery-public-data.thelook_ecommerce.users

UNION ALL

SELECT
  'product',

  COUNT(*) AS total_id,
  COUNT(DISTINCT id) AS unique_id,
  COUNT(*) - COUNT(DISTINCT id) AS duplicate_id

FROM bigquery-public-data.thelook_ecommerce.products

UNION ALL

SELECT
  'order',

  COUNT(*) AS total_id,
  COUNT(DISTINCT order_id) AS unique_id,
  COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_id

FROM bigquery-public-data.thelook_ecommerce.orders;



-- =========================================
-- Validation 3. Post-transformation integrity check
-- Objective: Ensure cleaning and enrichment steps did not introduce duplicate records, missing
-- categories, or invalid cancelled orders
-- =========================================

SELECT
  COUNT(*) - COUNT(DISTINCT order_item_id)
    AS duplicate_rows,

  COUNT(
    CASE
      WHEN category IS NULL THEN 1
    END
  ) AS null_category,

  COUNT(
    CASE
      WHEN order_status = 'Cancelled' THEN 1
    END
  ) AS remaining_cancelled_orders

FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`;
