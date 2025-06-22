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
WITH user_data AS ( -- chuẩn bị dữ liệu tháng, lấy các giá trị
  SELECT
    FORMAT_date('%Y%m', PARSE_date('%Y%m%d', date)) AS month,
    fullVisitorId,
    totals.pageviews AS pageviews,
    totals.transactions,
    product.productRevenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST(hits) AS hits
  UNNEST(hits.product) AS product
  WHERE _table_suffix between '0601' and '0731'
)

SELECT 
  month,
  SUM(CASE WHEN transactions >= 1 AND productRevenue IS NOT NULL THEN pageviews ELSE 0 END) /
    COUNT(DISTINCT CASE WHEN transactions >= 1 AND productRevenue IS NOT NULL THEN fullVisitorId ELSE NULL END)
      AS avg_pageviews_purchase,      --Tổng số người mua hàng/số người duy nhất
  SUM(CASE WHEN transactions IS NULL AND productRevenue IS NULL THEN pageviews ELSE 0 END) / 
    COUNT(DISTINCT CASE WHEN transactions IS NULL AND productRevenue IS NULL THEN fullVisitorId ELSE NULL END)
      AS avg_pageviews_non_purchase   --Tổng số người không mua hàng/số người duy nhất
FROM user_data
GROUP BY month
ORDER BY month;

--thay vì dùng case when, mình có thể tách ra thành các CTE để dễ kiểm soát câu lệnh hơn
--để hạn chế lỗi logic, lệch số mà k biết lệch ở đâu thì mình nên break nhỏ từng phần theo đặc tính của nó
--ở đây là purchaser và non_purchaser, rồi check xem outcome của từng phần có hợp lý k

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

--câu 4 này lưu ý là mình nên dùng full join/left join, bởi vì trong câu này, phạm vi chỉ từ tháng 6-7, nên chắc chắc sẽ có pur và nonpur của cả 2 tháng
--mình inner join thì vô tình nó sẽ ra đúng. nhưng nếu đề bài là 1 khoảng thời gian dài hơn, 2-3 năm chẳng hạn, thì có tháng chỉ có nonpur mà k có pur
--thì khi đó inner join nó sẽ làm mình bị mất data, thay vì hiện số của nonpur và pur thì nó để trống

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
WITH session_data AS ( -- Lấy thông tin doanh thu, chỉ tính người mua hàng
  SELECT
    FORMAT_DATE('%Y%m',parse_date('%Y%m%d', `date`)) as month,
    fullVisitorId,
    SUM(totals.visits) AS total_visits,
    SUM(product.productRevenue) AS total_revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
  UNNEST(hits) AS hits,
  UNNEST(hits.product) AS product
  WHERE totals.transactions IS NOT NULL                         -- Chỉ lấy người dùng có giao dịch
    AND product.productRevenue IS NOT NULL                        -- Chỉ tính những người có revenue
  GROUP BY month, fullVisitorId
)

-- Tính trung bình số tiền chi tiêu trên mỗi phiên
SELECT 
  month, 
  SUM(total_revenue) / (1000000* SUM(total_visits)) AS avg_revenue_by_user_per_visit
FROM session_data
GROUP BY month;

--mình có thể ghi ngắn gọn như thế này
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
WITH ProductActions AS ( --Lấy dữ liệu trong tháng 1 → tháng 3 năm 2017
    SELECT
        FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
        hits.eCommerceAction.action_type AS action_type,
        product.productRevenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) AS product
    WHERE _table_suffix between '0101' and '0331'
)

SELECT 
    month,
    COUNTIF(action_type = '2') AS num_product_view,  -- Số lần xem sản phẩm
    COUNTIF(action_type = '3') AS num_addtocart,  -- Số lần thêm vào giỏ hàng
    COUNTIF(action_type = '6' and productRevenue IS NOT NULL) AS num_purchase,  -- Số lần mua hàng, tính người có revenue
    ROUND(COUNTIF(action_type = '3') * 100 / COUNTIF(action_type = '2'), 2) AS add_to_cart_rate,
    ROUND(COUNTIF(action_type = '6' and productRevenue IS NOT NULL) * 100 / COUNTIF(action_type = '2'), 2)AS purchase_rate
FROM ProductActions
GROUP BY month
ORDER BY month;

--nên tách ra nhìu bước để dễ đọc, hơn là viết gộp như trên

--Cách 1:dùng CTE
with
product_view as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '2'
  GROUP BY 1
),

add_to_cart as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '3'
  GROUP BY 1
),

purchase as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '6'
  and product.productRevenue is not null   --phải thêm điều kiện này để đảm bảo có revenue
  group by 1
)

select
    pv.*,
    num_addtocart,
    num_purchase,
    round(num_addtocart*100/num_product_view,2) as add_to_cart_rate,
    round(num_purchase*100/num_product_view,2) as purchase_rate
from product_view pv
left join add_to_cart a on pv.month = a.month
left join purchase p on pv.month = p.month
order by pv.month;

--bài này k nên inner join, vì nếu như bảng purchase k có data thì sẽ k mapping đc vs bảng productview, từ đó kết quả sẽ k có luôn, mình nên dùng left join
--lấy số product_view làm gốc, nên mình sẽ left join ra 2 bảng còn lại

--Cách 2: bài này mình có thể dùng count(case when) hoặc sum(case when)

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

