--q1
select 
  format_date('%Y%m',parse_date('%Y%m%d', `date`)) as month, -- Chuyển đổi thành dạng YYYYMM
  count(totals.visits) as visits,
  sum(totals.pageviews) as pageviews,
  sum(totals.transactions) as transactions
from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
where _table_suffix between '0101' and '0331'
group by month
order by month;

--q2
SELECT
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.Bounces) as total_no_of_bounces,
    (sum(totals.Bounces)/sum(totals.visits))* 100.00 as bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY source
ORDER BY total_visits DESC;

--q3
SELECT --Lấy dữ liệu theo tháng
    'Month' AS time_type,
    FORMAT_DATE('%Y%m', DATE(PARSE_DATE('%Y%m%d', date))) AS time,
    trafficSource.source AS source,
    SUM(product.productRevenue) / 1000000 AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
UNNEST(hits) AS hit,
UNNEST(hit.product) AS product
WHERE product.productRevenue IS NOT NULL
GROUP BY time, source

UNION ALL -- Gộp lại với nhau

SELECT --Lấy dữ liệu theo tuần
    'Week' AS time_type,
    FORMAT_DATE('%Y%W', DATE(PARSE_DATE('%Y%m%d', date))) AS time,
    trafficSource.source AS source,
    SUM(product.productRevenue) / 1000000 AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
UNNEST(hits) AS hit,
UNNEST(hit.product) AS product
WHERE product.productRevenue IS NOT NULL
GROUP BY time, source

ORDER BY time_type, revenue desc;

--q4
with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      (sum(totals.pageviews)/count(distinct fullvisitorid)) as avg_pageviews_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions>=1
  and product.productRevenue is not null
  group by month
),

non_purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      sum(totals.pageviews)/count(distinct fullvisitorid) as avg_pageviews_non_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions is null
  and product.productRevenue is null
  group by month
)

select
    pd.*,
    avg_pageviews_non_purchase
from purchaser_data pd
full join non_purchaser_data using(month)
order by pd.month;

--q5
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    sum(totals.transactions)/count(distinct fullvisitorid) as Avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,unnest (hits) hits,
    unnest(product) product
where  totals.transactions>=1
and product.productRevenue is not null
group by month;

--q6
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    ((sum(product.productRevenue)/sum(totals.visits))/power(10,6)) as avg_revenue_by_user_per_visit
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,unnest(hits) hits
  ,unnest(product) product
where product.productRevenue is not null
  and totals.transactions>=1
group by month;

--q7
WITH Customers AS ( --xác định khách hàng đã mua sphẩm
  SELECT distinct fullVisitorId
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
  UNNEST(hits) AS hits,
  UNNEST(hits.product) AS product
  WHERE product.v2ProductName = "YouTube Men's Vintage Henley"
    AND product.productRevenue IS NOT NULL                       -- Chỉ tính những người có revenue
    AND totals.transactions >= 1                                 -- Chỉ lấy người dùng có giao dịch
)

SELECT 
  product.v2ProductName AS other_purchased_products, 
  SUM(product.productQuantity) AS quantity -- 
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST(hits) AS hits,
UNNEST(hits.product) AS product
JOIN Customers USING (fullVisitorId)
WHERE product.v2ProductName != "YouTube Men's Vintage Henley" --Lọc danh sách các sản phẩm khác mà những khách hàng đó đã mua
  AND product.productRevenue IS NOT NULL                        -- Chỉ tính những người có revenue
  AND totals.transactions >= 1                                  -- Chỉ lấy người dùng có giao dịch
GROUP BY product.v2ProductName
ORDER BY quantity DESC;

--q8
with product_data as(
select
    format_date('%Y%m', parse_date('%Y%m%d',date)) as month,
    count(CASE WHEN eCommerceAction.action_type = '2' THEN product.v2ProductName END) as num_product_view,
    count(CASE WHEN eCommerceAction.action_type = '3' THEN product.v2ProductName END) as num_add_to_cart,
    count(CASE WHEN eCommerceAction.action_type = '6' and product.productRevenue is not null THEN product.v2ProductName END) as num_purchase
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
,UNNEST(hits) as hits
,UNNEST (hits.product) as product
where _table_suffix between '20170101' and '20170331'
and eCommerceAction.action_type in ('2','3','6')
group by month
order by month
)

select
    *,
    round(num_add_to_cart/num_product_view * 100, 2) as add_to_cart_rate,
    round(num_purchase/num_product_view * 100, 2) as purchase_rate
from product_data;
