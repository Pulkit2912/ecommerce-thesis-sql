-- A.4 Customer Segmentation Query
-- Used for: Table 4.1, Figure 4.1
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_* (1 Nov 2020 to 31 Jan 2021)

WITH user_purchases AS (
  SELECT
    user_pseudo_id,
    COUNT(DISTINCT ecommerce.transaction_id) AS purchase_count,
    AVG(ecommerce.purchase_revenue) AS avg_order_value
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
  GROUP BY user_pseudo_id
),
segments AS (
  SELECT
    user_pseudo_id,
    avg_order_value,
    CASE WHEN purchase_count > 1 THEN 'Repeat Buyer' ELSE 'One-Time Buyer' END AS segment
  FROM user_purchases
),
sessions AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    event_name,
    event_timestamp
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
),
pages_per_user AS (
  SELECT
    user_pseudo_id,
    COUNT(*) AS total_page_views,
    COUNT(DISTINCT session_id) AS total_sessions
  FROM sessions
  WHERE event_name = 'page_view'
  GROUP BY user_pseudo_id
),
session_duration AS (
  SELECT
    user_pseudo_id,
    session_id,
    TIMESTAMP_DIFF(TIMESTAMP_MICROS(MAX(event_timestamp)), TIMESTAMP_MICROS(MIN(event_timestamp)), SECOND) AS duration_seconds
  FROM sessions
  GROUP BY user_pseudo_id, session_id
),
avg_duration_per_user AS (
  SELECT user_pseudo_id, AVG(duration_seconds) AS avg_session_seconds
  FROM session_duration
  GROUP BY user_pseudo_id
)
SELECT
  s.segment,
  COUNT(DISTINCT s.user_pseudo_id) AS num_users,
  ROUND(AVG(s.avg_order_value), 2) AS avg_order_value,
  ROUND(AVG(SAFE_DIVIDE(p.total_page_views, p.total_sessions)), 2) AS avg_pages_per_session,
  ROUND(AVG(d.avg_session_seconds), 0) AS avg_session_seconds
FROM segments s
LEFT JOIN pages_per_user p ON s.user_pseudo_id = p.user_pseudo_id
LEFT JOIN avg_duration_per_user d ON s.user_pseudo_id = d.user_pseudo_id
GROUP BY s.segment
