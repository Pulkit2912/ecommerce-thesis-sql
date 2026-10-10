-- A.2 Funnel Stage Query
-- Used for: Table 2.1, Figure 1.1
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_* (1 Nov 2020 to 31 Jan 2021)

SELECT event_name, COUNT(*) AS event_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('session_start','view_item','add_to_cart','begin_checkout','purchase')
GROUP BY event_name
ORDER BY event_count DESC
