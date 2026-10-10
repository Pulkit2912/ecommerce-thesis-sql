-- A.3 Traffic Source Segmentation Query
-- Used for: Table 3.1, Figure 3.1
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_* (1 Nov 2020 to 31 Jan 2021)

SELECT
  traffic_source.medium AS traffic_medium,
  event_name,
  COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('session_start','view_item','add_to_cart','begin_checkout','purchase')
AND traffic_source.medium IS NOT NULL
AND traffic_source.medium != '(data deleted)'
GROUP BY traffic_medium, event_name
ORDER BY traffic_medium, event_count DESC
