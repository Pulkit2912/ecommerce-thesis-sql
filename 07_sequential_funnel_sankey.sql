-- A.7 Sequential Funnel (Sankey) Query
-- Used for: Figure 2.1
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_* (1 Nov 2020 to 31 Jan 2021)

WITH session_events AS (
  SELECT
    CONCAT(user_pseudo_id, '-', CAST((SELECT value.int_value FROM UNNEST(event_params)
      WHERE key = 'ga_session_id') AS STRING)) AS session_id,
    event_name,
    event_timestamp
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name IN ('session_start','view_item','add_to_cart','begin_checkout','purchase')
),
first_times AS (
  SELECT
    session_id,
    MIN(CASE WHEN event_name = 'session_start'  THEN event_timestamp END) AS t_session_start,
    MIN(CASE WHEN event_name = 'view_item'      THEN event_timestamp END) AS t_view_item,
    MIN(CASE WHEN event_name = 'add_to_cart'    THEN event_timestamp END) AS t_add_to_cart,
    MIN(CASE WHEN event_name = 'begin_checkout' THEN event_timestamp END) AS t_begin_checkout,
    MIN(CASE WHEN event_name = 'purchase'       THEN event_timestamp END) AS t_purchase
  FROM session_events
  GROUP BY session_id
),
progress AS (
  SELECT
    t_session_start IS NOT NULL AS reached_session_start,
    t_session_start IS NOT NULL
      AND t_view_item IS NOT NULL AND t_view_item > t_session_start
      AS reached_view_item,
    t_session_start IS NOT NULL
      AND t_view_item IS NOT NULL AND t_view_item > t_session_start
      AND t_add_to_cart IS NOT NULL AND t_add_to_cart > t_view_item
      AS reached_add_to_cart,
    t_session_start IS NOT NULL
      AND t_view_item IS NOT NULL AND t_view_item > t_session_start
      AND t_add_to_cart IS NOT NULL AND t_add_to_cart > t_view_item
      AND t_begin_checkout IS NOT NULL AND t_begin_checkout > t_add_to_cart
      AS reached_begin_checkout,
    t_session_start IS NOT NULL
      AND t_view_item IS NOT NULL AND t_view_item > t_session_start
      AND t_add_to_cart IS NOT NULL AND t_add_to_cart > t_view_item
      AND t_begin_checkout IS NOT NULL AND t_begin_checkout > t_add_to_cart
      AND t_purchase IS NOT NULL AND t_purchase > t_begin_checkout
      AS reached_purchase
  FROM first_times
)
SELECT 'Session Start' AS source, 'View Item' AS target, COUNTIF(reached_view_item) AS value FROM progress
UNION ALL SELECT 'Session Start', 'Exit after Session Start', COUNTIF(reached_session_start AND NOT reached_view_item) FROM progress
UNION ALL SELECT 'View Item', 'Add to Cart', COUNTIF(reached_add_to_cart) FROM progress
UNION ALL SELECT 'View Item', 'Exit after View Item', COUNTIF(reached_view_item AND NOT reached_add_to_cart) FROM progress
UNION ALL SELECT 'Add to Cart', 'Begin Checkout', COUNTIF(reached_begin_checkout) FROM progress
UNION ALL SELECT 'Add to Cart', 'Exit after Add to Cart', COUNTIF(reached_add_to_cart AND NOT reached_begin_checkout) FROM progress
UNION ALL SELECT 'Begin Checkout', 'Purchase', COUNTIF(reached_purchase) FROM progress
UNION ALL SELECT 'Begin Checkout', 'Exit after Begin Checkout', COUNTIF(reached_begin_checkout AND NOT reached_purchase) FROM progress
