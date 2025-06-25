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
select
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.bounces) as total_no_of_bounces,
    (sum(totals.bounces)/sum(totals.visits))* 100.00 as bounce_rate
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
group by source
order by total_visits desc;

--q3
select --Lấy dữ liệu theo tháng
    'Month' as time_type,
    format_date('%Y%m', date(parse_date('%Y%m%d', date))) as time,
    trafficSource.source as source,
    sum(product.productRevenue) / 1000000 as revenue
from `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
unnest(hits) as hit,
unnest(hit.product) as product
where product.productRevenue is not null
group by time, source

union all -- Gộp lại với nhau

select --Lấy dữ liệu theo tuần
    'Week' as time_type,
    format_date('%Y%W', date(parse_date('%Y%m%d', date))) as time,
    trafficSource.source as source,
    SUM(product.productRevenue) / 1000000 as revenue
from `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
unnest(hits) as hit,
unnest(hit.product) as product
where product.productRevenue is not null
group by time, source

order by time_type, revenue desc;

--q4
with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      (sum(totals.pageviews)/count(distinct fullVisitorId)) as avg_pageviews_purchase,
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
    sum(totals.transactions)/count(distinct fullVisitorId) as Avg_total_transactions_per_user
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
with Customers as ( --xác định khách hàng đã mua sphẩm
  SELECT distinct fullVisitorId
  from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
  unnest(hits) as hits,
  unnest(hits.product) as product
  where product.v2ProductName = "YouTube Men's Vintage Henley"
    and product.productRevenue is not null                       -- Chỉ tính những người có revenue
    and totals.transactions >= 1                                 -- Chỉ lấy người dùng có giao dịch
)

select 
  product.v2ProductName as other_purchased_products, 
  SUM(product.productQuantity) as quantity -- 
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
unnest(hits) as hits,
unnest(hits.product) as product
join Customers using (fullVisitorId)
where product.v2ProductName != "YouTube Men's Vintage Henley" --Lọc danh sách các sản phẩm khác mà những khách hàng đó đã mua
  and product.productRevenue is not null                       -- Chỉ tính những người có revenue
  and totals.transactions >= 1                                  -- Chỉ lấy người dùng có giao dịch
group by product.v2ProductName
order by quantity desc;

--q8
with product_data as(
select
    format_date('%Y%m', parse_date('%Y%m%d',date)) as month,
    count(case when eCommerceAction.action_type = '2' then product.v2ProductName end) as num_product_view,
    count(case when eCommerceAction.action_type = '3' then product.v2ProductName end) as num_add_to_cart,
    count(case when eCommerceAction.action_type = '6' and product.productRevenue is not null then product.v2ProductName end) as num_purchase
from `bigquery-public-data.google_analytics_sample.ga_sessions_*`
,unnest(hits) as hits
,unnest (hits.product) as product
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
