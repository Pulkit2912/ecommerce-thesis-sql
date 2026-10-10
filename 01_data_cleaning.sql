-- A.1 Data Cleaning and Column Selection
-- Used for: Section 1.3 (data cleaning and column selection)
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_* (1 Nov 2020 to 31 Jan 2021)

SELECT
  event_date,
  event_name,
  user_pseudo_id,
  traffic_source.medium AS traffic_medium,
  traffic_source.source AS traffic_source,
  device.category AS device_category,
  ecommerce.purchase_revenue AS purchase_revenue,
  ecommerce.transaction_id AS transaction_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('session_start','view_item','add_to_cart','begin_checkout','purchase')
  AND traffic_source.medium IS NOT NULL
  AND traffic_source.medium != '(data deleted)'
