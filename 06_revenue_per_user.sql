-- A.6 Total Revenue per User Query
-- Used for: Figure 4.2
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_* (1 Nov 2020 to 31 Jan 2021)

WITH user_purchases AS (
  SELECT
    user_pseudo_id,
    COUNT(DISTINCT ecommerce.transaction_id) AS purchase_count,
    SUM(ecommerce.purchase_revenue) AS total_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
  GROUP BY user_pseudo_id
),
segments AS (
  SELECT
    user_pseudo_id,
    total_revenue,
    CASE WHEN purchase_count > 1 THEN 'Repeat Buyer' ELSE 'One-Time Buyer' END AS segment
  FROM user_purchases
)
SELECT
  segment,
  COUNT(DISTINCT user_pseudo_id) AS num_users,
  ROUND(AVG(total_revenue), 2) AS avg_total_revenue_per_user
FROM segments
GROUP BY segment
