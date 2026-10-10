-- A.5 Device Type Query
-- Used for: Table 5.1, Figure 5.1
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_* (1 Nov 2020 to 31 Jan 2021)

SELECT
  device.category AS device_type,
  event_name,
  COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('session_start','view_item','add_to_cart','begin_checkout','purchase')
  AND device.category IS NOT NULL
GROUP BY device_type, event_name
ORDER BY device_type, event_count DESC
