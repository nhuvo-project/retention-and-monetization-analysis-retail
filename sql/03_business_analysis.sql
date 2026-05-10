-- =========================================
-- 03_business_analysis.sql
-- Purpose: Analyze retention, monetization, customer behavior, and inventory alignment 
-- to diagnose the primary drivers constraining sustainable ecommerce growth
-- =========================================



-- =========================================
-- Q1. How has revenue performance evolved over time?
-- Objective: Assess revenue growth patterns and identify signs of volatility 
-- or structural inconsistency
-- =========================================

WITH monthly_revenue AS (
  SELECT
    order_month,
    ROUND(SUM(sale_price),2) AS revenue

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`

  GROUP BY 1
)

SELECT
  order_month,
  revenue,

  ROUND(
    (revenue - LAG(revenue) OVER(ORDER BY order_month))
    / NULLIF(LAG(revenue) OVER(ORDER BY order_month),0),
  2) AS MoM_growth_rate

FROM monthly_revenue

WHERE order_month >= (
  SELECT DATE_SUB(MAX(order_month), INTERVAL 36 MONTH)
  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`
)

ORDER BY 1 DESC;



-- =========================================
-- Q2. Is the revenue volatility driven by changes in customer dynamics?
-- Objective: Evaluate whether acquisition and repeat customer behavior 
-- explain fluctuations in revenue performance
-- =========================================

WITH first_purchase AS (
  SELECT
    user_id,
    MIN(order_month) AS first_time_buying

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`

  GROUP BY 1
),

customer_label AS (
  SELECT
    b.order_month,
    b.user_id,
    b.sale_price,
    b.order_id,

    CASE
      WHEN first_time_buying = order_month THEN 'New'
      ELSE 'Repeat'
    END AS customer_classification

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data` AS b

  LEFT JOIN first_purchase AS fp
    ON b.user_id = fp.user_id
),

monthly_metric AS (
  SELECT
    order_month,
    customer_classification,

    COUNT(DISTINCT user_id) AS num_customer,
    COUNT(DISTINCT order_id) AS num_order,
    SUM(sale_price) AS revenue

  FROM customer_label

  GROUP BY 1,2
)

SELECT
  order_month,
  customer_classification,

  ROUND(
    SAFE_DIVIDE(
      num_customer,
      SUM(num_customer) OVER (PARTITION BY order_month)
    ),
  2) AS customer_percentage,

  ROUND(SAFE_DIVIDE(revenue,num_order),2) AS AOV,

  revenue

FROM monthly_metric

ORDER BY 1 DESC;



-- =========================================
-- Q3. To what extent is customer value concentrated among repeat vs one-time buyers?
-- Objective: Evaluate how customer value is distributed between repeat and one-time buyers
-- =========================================

WITH customer_base AS (
  SELECT
    customer_type_lifetime,

    COUNT(DISTINCT user_id) AS total_customer,
    SUM(sale_price) AS revenue

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`

  GROUP BY 1
)

SELECT
  customer_type_lifetime,

  ROUND(
    total_customer * 1.0
    / SUM(total_customer) OVER (),
  2) AS customer_percentage,

  ROUND(
    revenue * 1.0
    / SUM(revenue) OVER (),
  2) AS revenue_contribution

FROM customer_base;



-- =========================================
-- Q4. Is repeat customer value driven more by purchase frequency or by stronger purchasing behavior?
-- Objective: Identify whether repeat customer value is driven by stronger purchasing behavior 
-- or by higher purchase frequency
-- =========================================

WITH order_sequence AS (
  SELECT
    order_id,
    user_id,
    sale_price,
    order_status,
    customer_type_lifetime,

    ROW_NUMBER() OVER(
      PARTITION BY user_id
      ORDER BY created_at
    ) AS order_num

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`
),

order_relabeling AS (
  SELECT *,

    CASE
      WHEN customer_type_lifetime = 'One time buyer'
        THEN '1-time'

      WHEN order_num = 1
        THEN '1st-time'

      ELSE 'Repeat'
    END AS segment

  FROM order_sequence
),

customer_level AS (
  SELECT
    user_id,
    segment,

    COUNT(DISTINCT order_id) AS total_order_pc,

    SAFE_DIVIDE(
      COUNT(*),
      COUNT(DISTINCT order_id)
    ) AS basket_size_pc,

    MAX(
      CASE
        WHEN order_status = 'Returned'
          THEN 1
        ELSE 0
      END
    ) AS returned_order,

    SAFE_DIVIDE(
      SUM(sale_price),
      COUNT(DISTINCT order_id)
    ) AS AOV_pc

  FROM order_relabeling

  GROUP BY 1,2
)

SELECT
  segment,

  ROUND(AVG(basket_size_pc),2) AS avg_basket_size_pc,
  ROUND(AVG(AOV_pc),2) AS avg_AOV_pc,
  ROUND(AVG(total_order_pc),2) AS avg_order_pc,
  ROUND(AVG(returned_order),2) AS avg_return_rate

FROM customer_level

GROUP BY 1;



-- =========================================
-- Q5. Where in the post-purchase lifecycle do customers fail to convert into repeat buyers?
-- Objective: Measure retention decay across customer cohorts over time
-- =========================================

WITH user_cohort AS (
  SELECT
    user_id,
    MIN(order_month) AS first_purchase_month

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`

  GROUP BY 1
),

month_index AS (
  SELECT
    uc.user_id,
    uc.first_purchase_month,
    b.order_month,

    DATE_DIFF(
      b.order_month,
      uc.first_purchase_month,
      MONTH
    ) AS month_num,

    ROW_NUMBER() OVER(
      PARTITION BY uc.user_id
      ORDER BY created_at
    ) AS order_sequence

  FROM user_cohort AS uc

  JOIN `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data` AS b
    ON uc.user_id = b.user_id
),

cohort_size AS (
  SELECT
    first_purchase_month,
    COUNT(DISTINCT user_id) AS cohort_size

  FROM month_index

  GROUP BY 1
),

retention_through_time AS (
  SELECT
    first_purchase_month,
    month_num,

    COUNT(DISTINCT user_id) AS active_customer,

    COUNT(
      DISTINCT CASE
        WHEN order_sequence = 2
          THEN user_id
      END
    ) AS customer_2nd_order

  FROM month_index

  GROUP BY 1,2
)

SELECT
  cs.first_purchase_month,
  r.month_num,
  cs.cohort_size,
  r.active_customer,

  ROUND(
    SAFE_DIVIDE(
      r.active_customer,
      cs.cohort_size
    ) * 100,
  2) AS retention_rate,

  ROUND(
    SAFE_DIVIDE(
      customer_2nd_order,
      cs.cohort_size
    ) * 100,
  2) AS conversion_rate,

  ROUND(
    SAFE_DIVIDE(
      r.active_customer,
      LAG(r.active_customer)
      OVER(
        PARTITION BY cs.first_purchase_month
        ORDER BY r.month_num
      )
    ) * 100,
  2) AS decay_rate

FROM cohort_size AS cs

JOIN retention_through_time AS r
  ON cs.first_purchase_month = r.first_purchase_month

WHERE r.month_num <= 12

ORDER BY 1 DESC,2 ASC;



-- =========================================
-- Q6. When do repeat customers repurchase, and what categories drive their repeat behavior?
-- Objective: Analyze repurchase frequency and category-level repeat behavior
-- =========================================

WITH repurchase_base AS (
  SELECT
    user_id,
    order_id,
    category,
    order_month,

    CAST(created_at AS DATE) AS order_date,

    ROW_NUMBER() OVER(
      PARTITION BY user_id
      ORDER BY created_at
    ) AS order_sequence

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`

  WHERE customer_type_lifetime = 'Repeat buyer'
),

interpurchase AS (
  SELECT *,

    DATE_DIFF(
      order_date,
      LAG(order_date)
      OVER(PARTITION BY user_id ORDER BY order_date),
      DAY
    ) AS day_diff

  FROM repurchase_base
),

category_prefer AS (
  SELECT
    category,

    COUNT(DISTINCT user_id) AS repeat_user,
    COUNT(DISTINCT order_id) AS repeat_order,

    ROUND(
      SAFE_DIVIDE(
        COUNT(DISTINCT order_id),
        COUNT(DISTINCT user_id)
      ),
    2) AS orders_per_user,

    RANK() OVER(
      ORDER BY ROUND(
        SAFE_DIVIDE(
          COUNT(DISTINCT order_id),
          COUNT(DISTINCT user_id)
        ),
      2) DESC
    ) AS category_rank

  FROM repurchase_base

  GROUP BY category
)

SELECT
  (
    SELECT ROUND(AVG(day_diff),2)
    FROM interpurchase
    WHERE day_diff IS NOT NULL
  ) AS avg_interpurchase,

  (
    SELECT ARRAY_AGG(
      STRUCT(
        category,
        repeat_user,
        repeat_order,
        orders_per_user
      )
    )
    FROM category_prefer
    WHERE category_rank <= 3
  ) AS top_3_category;



-- =========================================
-- Q7. How much value is lost to returns?
-- Objective: Quantify the financial impact of returns overall 
-- =========================================

SELECT
  SUM(
    CASE
      WHEN order_status = 'Returned'
        THEN sale_price
    END
  ) AS returned_revenue,

  SUM(sale_price) AS total_revenue,

  ROUND(
    SAFE_DIVIDE(
      SUM(
        CASE
          WHEN order_status = 'Returned'
            THEN sale_price
        END
      ),
      SUM(sale_price)
    ),
  2) AS return_rate

FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`;



-- =========================================
-- Q8. Which products/categories drive the highest return rates? 
-- Objective: Identify which categories contribute disproportionately to return-related revenue loss
-- =========================================

SELECT
  category,

  SUM(
    CASE
      WHEN order_status = 'Returned' THEN sale_price
    END) AS returned_revenue,

  ROUND(
    SAFE_DIVIDE(
      SUM(
        CASE
          WHEN order_status = 'Returned' THEN sale_price
        END),
      SUM(sale_price)
    ),
  2) AS return_rate,

  ROUND(
    SAFE_DIVIDE(
      SUM(
        CASE
          WHEN order_status = 'Returned'
            THEN sale_price
        END
      ),
      SUM(SUM(sale_price)) OVER ()
    ),
  2) AS contribution_to_total_sale

FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`

GROUP BY 1

ORDER BY return_rate DESC;



-- =========================================
-- Q9. Which product categories underperform in terms of demand and revenue contribution?
-- Objective: Evaluate category-level monetization performance through 
-- demand, revenue contribution, and pricing efficiency across categories
-- =========================================

WITH each_category AS (
  SELECT
    category,

    COUNT(
      DISTINCT CASE
        WHEN order_status != 'Returned'
          THEN order_id
      END
    ) AS sold_unit,

    SUM(
      CASE
        WHEN order_status != 'Returned'
          THEN sale_price
      END
    ) AS revenue

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`

  GROUP BY 1
)

SELECT
  category,
  sold_unit,

  ROUND(
    SAFE_DIVIDE(
      sold_unit,
      SUM(sold_unit) OVER()
    ),
  2) AS sale_share,

  revenue,

  ROUND(
    SAFE_DIVIDE(
      revenue,
      SUM(revenue) OVER()
    ),
  2) AS revenue_share,

  ROUND(
    SAFE_DIVIDE(
      revenue,
      sold_unit
    ),
  2) AS avg_selling_price

FROM each_category

ORDER BY avg_selling_price DESC;



-- =========================================
-- 10. Is inventory allocation aligned with customer demand?
-- Objective: Assess whether inventory allocation accurately reflects 
-- realized customer demand across categories
-- =========================================

WITH category_level AS (
  SELECT
    category,

    COUNT(DISTINCT inventory_item_id)
      AS inventory_unit,

    COUNT(
      DISTINCT CASE
        WHEN order_status != 'Returned'
          THEN order_id
      END
    ) AS sold_unit

  FROM `just-cosmos-479109-p7.thelook_clean.enriched_and_filtered_data`

  GROUP BY 1
),

category_share AS (
  SELECT *,

    SAFE_DIVIDE(
      inventory_unit,
      SUM(inventory_unit) OVER ()
    ) AS inventory_share,

    SAFE_DIVIDE(
      sold_unit,
      SUM(sold_unit) OVER ()
    ) AS sale_share

  FROM category_level
)

SELECT
  category,

  ROUND(
    inventory_share - sale_share,
  4) AS inventory_sale_gap,

  ROUND(inventory_share,4) AS inventory_share,
  ROUND(sale_share,4) AS sale_share

FROM category_share

ORDER BY inventory_sale_gap DESC;
