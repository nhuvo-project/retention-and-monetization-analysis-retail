-- =========================================
-- 01_data_cleaning.sql
-- Purpose: Clean and standardize transactional data before analytical transformation
-- =========================================

CREATE OR REPLACE VIEW `just-cosmos-479109-p7.thelook_clean.cleaned_transaction_data` AS

SELECT *
FROM `just-cosmos-479109-p7.thelook_raw.summary_table`

WHERE status != 'Cancelled'
  AND sale_price > 0
  AND retail_price > 0
  AND inventory_entry_date IS NOT NULL
  AND created_at IS NOT NULL;
