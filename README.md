# SQL_E-Commerce_Dataset
## DATASET
Table Schema: https://support.google.com/analytics/answer/3437719?hl=en
| Field Name                            | Data Type | Description |
|--------------------------------------|-----------|-------------|
| fullVisitorId                        | STRING    | The unique visitor ID. |
| date                                 | STRING    | The date of the session in YYYYMMDD format. |
| totals                               | RECORD    | This section contains aggregate values across the session. |
| totals.bounces                       | INTEGER   | Total bounces (for convenience). For a bounced session, the value is 1, otherwise it is null. |
| totals.hits                          | INTEGER   | Total number of hits within the session. |
| totals.pageviews                     | INTEGER   | Total number of pageviews within the session. |
| totals.visits                        | INTEGER   | The number of sessions (for convenience). This value is 1 for sessions with interaction events. The value is null if there are no interaction events in the session. |
| totals.transactions                  | INTEGER   | Total number of ecommerce transactions within the session. |
| trafficSource.source                 | STRING    | The source of the traffic source. Could be the name of the search engine, the referring hostname, or a value of the `utm_source` URL parameter. |
| hits                                 | RECORD    | This row and nested fields are populated for any and all types of hits. |
| hits.eCommerceAction                 | RECORD    | This section contains all of the ecommerce hits that occurred during the session. This is a repeated field and has an entry for each hit that was collected. |
| hits.eCommerceAction.action_type     | STRING    | The action type. Click through of product lists = 1, Product detail views = 2, Add product(s) to cart = 3, Remove product(s) from cart = 4, Check out = 5, Completed purchase = 6, Refund of purchase = 7, Checkout options = 8, Unknown = 0. Usually this action type applies to all the products in a hit, with the following exception: when hits.product.isImpression = TRUE, the corresponding product is a product impression that is seen while the product action is taking place (i.e., a "product in list view"). Example query to calculate number of products in list views:SELECT COUNT(hits.product.v2ProductName) FROM [foo-160803:123456789.ga_sessions_20170101] WHERE hits.product.isImpression == TRUE Example query to calculate number of products in detailed view: SELECT COUNT(hits.product.v2ProductName), FROM [foo-160803:123456789.ga_sessions_20170101] WHERE hits.ecommerceaction.action_type ='2' AND ( BOOLEAN(hits.product.isImpression) IS NULL OR BOOLEAN(hits.product.isImpression) == FALSE ) |
| hits.product                         | RECORD    | This row and nested fields will be populated for each hit that contains Enhanced Ecommerce PRODUCT data. |
| hits.product.productQuantity         | INTEGER   | The quantity of the product purchased. |
| hits.product.productRevenue          | INTEGER   | The revenue of the product, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.product.productSKU              | STRING    | Product SKU. |
| hits.product.v2ProductName           | STRING    | Product Name. |
## Query 01: Calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
```sql
select 
  format_date('%Y%m',parse_date('%Y%m%d', `date`)) as month, -- Chuyển đổi thành dạng YYYYMM
  count(totals.visits) as visits,
  sum(totals.pageviews) as pageviews,
  sum(totals.transactions) as transactions
from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
where _table_suffix between '0101' and '0331'
group by month
order by month;
```
### ✅ Results:
| month   | visits | pageviews | transactions |
|---------|--------|-----------|--------------|
| 201701  | 64,694 | 257,708   | 713          |
| 201702  | 62,192 | 233,373   | 733          |
| 201703  | 69,931 | 259,522   | 993          |

**📝 Observation:** The table shows monthly aggregated metrics. March (201703) demonstrates an improvement across all key indicators—visits, pageviews, and transactions—compared to January and February.
## Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
```sql
select
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.Bounces) as total_no_of_bounces,
    round((sum(totals.Bounces)/sum(totals.visits))* 100.00,2) as bounce_rate
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
group by source
order by total_visits DESC;
```
### ✅ Results:
| source | total_visits | total_no_of_bounces | bounce_rate |
| ------ | ------------ | ------------------- | ----------- |
| google | 38400 | 19798 | 51.56 |
| (direct) | 19891 | 8606 | 43.27 |
| youtube.com | 6351 | 4238 | 66.73 |
| analytics.google.com | 1972 | 1064 | 53.96 |
| Partners | 1788 | 936 | 52.35 |
| m.facebook.com | 669 | 430 | 64.28 |
| google.com | 368 | 183 | 49.73 |
| dfa | 302 | 124 | 41.06 |
| sites.google.com | 230 | 97 | 42.17 |
| facebook.com | 191 | 102 | 53.4 |
| reddit.com | 189 | 54 | 28.57 |
| qiita.com | 146 | 72 | 49.32 |
| baidu | 140 | 84 | 60 |
| quora.com | 140 | 70 | 50 |
| bing | 111 | 54 | 48.65 |
| mail.google.com | 101 | 25 | 24.75 |
| yahoo | 100 | 41 | 41 |
| blog.golang.org | 65 | 19 | 29.23 |
| l.facebook.com | 51 | 45 | 88.24 |
| groups.google.com | 50 | 22 | 44 |
| t.co | 38 | 27 | 71.05 |
| google.co.jp | 36 | 25 | 69.44 |
| m.youtube.com | 34 | 22 | 64.71 |
| dealspotr.com | 26 | 12 | 46.15 |
| productforums.google.com | 25 | 21 | 84 |
| ask | 24 | 16 | 66.67 |
| support.google.com | 24 | 16 | 66.67 |
| int.search.tb.ask.com | 23 | 17 | 73.91 |
| optimize.google.com | 21 | 10 | 47.62 |
| docs.google.com | 20 | 8 | 40 |
| lm.facebook.com | 18 | 9 | 50 |
| l.messenger.com | 17 | 6 | 35.29 |
| adwords.google.com | 16 | 7 | 43.75 |
| duckduckgo.com | 16 | 14 | 87.5 |
| google.co.uk | 15 | 7 | 46.67 |
| sashihara.jp | 14 | 8 | 57.14 |
| lunametrics.com | 13 | 8 | 61.54 |
| search.mysearch.com | 12 | 11 | 91.67 |
| tw.search.yahoo.com | 10 | 8 | 80 |
| outlook.live.com | 10 | 7 | 70 |
| phandroid.com | 9 | 7 | 77.78 |
| plus.google.com | 8 | 2 | 25 |
| connect.googleforwork.com | 8 | 5 | 62.5 |
| m.yz.sm.cn | 7 | 5 | 71.43 |
| search.xfinity.com | 6 | 6 | 100 |
| google.co.in | 6 | 3 | 50 |
| google.ru | 5 | 1 | 20 |
| online-metrics.com | 5 | 2 | 40 |
| hangouts.google.com | 5 | 1 | 20 |
| s0.2mdn.net | 5 | 3 | 60 |
| m.sogou.com | 4 | 3 | 75 |
| in.search.yahoo.com | 4 | 2 | 50 |
| googleads.g.doubleclick.net | 4 | 1 | 25 |
| away.vk.com | 4 | 3 | 75 |
| getpocket.com | 3 |  |  |
| m.baidu.com | 3 | 2 | 66.67 |
| siliconvalley.about.com | 3 | 2 | 66.67 |
| wap.sogou.com | 2 | 2 | 100 |
| calendar.google.com | 2 | 1 | 50 |
| google.it | 2 | 1 | 50 |
| google.co.th | 2 | 1 | 50 |
| msn.com | 2 | 1 | 50 |
| github.com | 2 | 2 | 100 |
| centrum.cz | 2 | 2 | 100 |
| myactivity.google.com | 2 | 1 | 50 |
| plus.url.google.com | 2 |  |  |
| google.cl | 2 | 1 | 50 |
| uk.search.yahoo.com | 2 | 1 | 50 |
| search.1and1.com | 2 | 2 | 100 |
| moodle.aurora.edu | 2 | 2 | 100 |
| au.search.yahoo.com | 2 | 2 | 100 |
| m.sp.sm.cn | 2 | 2 | 100 |
| amp.reddit.com | 2 | 1 | 50 |
| earth.google.com | 1 |  |  |
| google.es | 1 | 1 | 100 |
| google.ca | 1 |  |  |
| google.nl | 1 |  |  |
| aol | 1 |  |  |
| kik.com | 1 | 1 | 100 |
| kidrex.org | 1 | 1 | 100 |
| malaysia.search.yahoo.com | 1 | 1 | 100 |
| newclasses.nyu.edu | 1 |  |  |
| gophergala.com | 1 | 1 | 100 |
| es.search.yahoo.com | 1 | 1 | 100 |
| ph.search.yahoo.com | 1 |  |  |
| web.mail.comcast.net | 1 | 1 | 100 |
| images.google.com.au | 1 | 1 | 100 |
| it.pinterest.com | 1 | 1 | 100 |
| web.facebook.com | 1 | 1 | 100 |
| google.bg | 1 | 1 | 100 |
| news.ycombinator.com | 1 | 1 | 100 |
| search.tb.ask.com | 1 |  |  |
| online.fullsail.edu | 1 | 1 | 100 |
| arstechnica.com | 1 |  |  |
| mx.search.yahoo.com | 1 | 1 | 100 |
| google.com.br | 1 |  |  |
| suche.t-online.de | 1 | 1 | 100 |

**📝 Observation:** Google and direct traffic are the main sources by volume, while platforms like Reddit and mail.google.com show significantly lower bounce rates.
## Query 3: Revenue by traffic source by week, by month in June 2017
```sql
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
```
### ✅ Results:
| time_type | time | source | revenue |
| --- | --- | --- | --- |
| Month | 201706 | (direct) | 97,333.62 |
| Month | 201706 | google | 18,757.18 |
| Month | 201706 | dfa | 8,862.23 |
| Month | 201706 | mail.google.com | 2,563.13 |
| Month | 201706 | search.myway.com | 105.939998 |
| Month | 201706 | groups.google.com | 101.96 |
| Month | 201706 | chat.google.com | 74.03 |
| Month | 201706 | dealspotr.com | 72.95 |
| Month | 201706 | mail.aol.com | 64.849998 |
| Month | 201706 | phandroid.com | 52.95 |
| Month | 201706 | sites.google.com | 39.17 |
| Month | 201706 | google.com | 23.99 |
| Month | 201706 | yahoo | 20.39 |
| Month | 201706 | youtube.com | 16.99 |
| Month | 201706 | bing | 13.98 |
| Month | 201706 | l.facebook.com | 12.48 |
| Week | 201724 | (direct) | 30,908.91 |
| Week | 201725 | (direct) | 27,295.32 |
| Week | 201723 | (direct) | 17,325.68 |
| Week | 201726 | (direct) | 14,914.81 |
| Week | 201724 | google | 9,217.17 |
| Week | 201722 | (direct) | 6,888.90 |
| Week | 201726 | google | 5,330.57 |
| Week | 201726 | dfa | 3,704.74 |
| Week | 201724 | mail.google.com | 2,486.86 |
| Week | 201724 | dfa | 2,341.56 |
| Week | 201722 | google | 2,119.39 |
| Week | 201722 | dfa | 1,670.65 |
| Week | 201723 | dfa | 1,145.28 |
| Week | 201723 | google | 1,083.95 |
| Week | 201725 | google | 1,006.10 |
| Week | 201723 | search.myway.com | 105.939998 |
| Week | 201725 | mail.google.com | 76.27 |
| Week | 201723 | chat.google.com | 74.03 |
| Week | 201724 | dealspotr.com | 72.95 |
| Week | 201725 | mail.aol.com | 64.849998 |
| Week | 201726 | groups.google.com | 63.37 |
| Week | 201725 | phandroid.com | 52.95 |
| Week | 201725 | groups.google.com | 38.59 |
| Week | 201725 | sites.google.com | 25.19 |
| Week | 201725 | google.com | 23.99 |
| Week | 201726 | yahoo | 20.39 |
| Week | 201723 | youtube.com | 16.99 |
| Week | 201722 | sites.google.com | 13.98 |
| Week | 201724 | bing | 13.98 |
| Week | 201724 | l.facebook.com | 12.48 |

**📝 Observation:** Direct traffic drives the most revenue both monthly and weekly. Google and DFA are also top-performing sources, but with lower contribution.
## Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
```sql
with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      round((sum(totals.pageviews)/count(distinct fullvisitorid)),2) as avg_pageviews_purchase,
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
    round(avg_pageviews_non_purchase,2) as avg_pageviews_non_purchase
from purchaser_data pd
full join non_purchaser_data using(month)
order by pd.month; 
```
### ✅ Results:
| month | avg_pageviews_purchase | avg_pageviews_non_purchase |
| --- | --- | --- |
| 201706 | 94.02 | 316.87 |
| 201707 | 124.24 | 334.06 |

**📝 Observation:** Surprisingly, non-purchasers have much higher average pageviews per user than purchasers, suggesting browsing-heavy behavior without conversion.
## Query 05: Average number of transactions per user that made a purchase in July 2017
```sql
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    round(
        sum(totals.transactions)/count(distinct fullvisitorid)
        ,3) as Avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,unnest (hits) hits,
    unnest(product) product
where  totals.transactions>=1
and product.productRevenue is not null
group by month;
```
### ✅ Results:
| month | Avg_total_transactions_per_user |
| ----- | ------------------------------- |
| 201707 | 4.164|

**📝 Observation:** On average, each purchasing user completed over 4 transactions, indicating strong repeat buying behavior in July.
## Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
```sql
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    round(
      ((sum(product.productRevenue)/sum(totals.visits))/power(10,6))
      ,2) as avg_revenue_by_user_per_visit
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,unnest(hits) hits
  ,unnest(product) product
where product.productRevenue is not null
  and totals.transactions>=1
group by month;
```
### ✅ Results:
| month | avg_revenue_by_user_per_visit |
| ----- | ----------------------------- |
| 201707 | 43.86|

**📝 Observation:** Each purchase session generated an average of $43.86 in revenue, which reflects solid value per visit from buyers.
## Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
```sql
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
```
### ✅ Results:
| other_purchased_products | quantity |
| --- | --- |
| Google Sunglasses | 20 |
| Google Women's Vintage Hero Tee Black | 7 |
| SPF-15 Slim & Slender Lip Balm | 6 |
| Google Women's Short Sleeve Hero Tee Red Heather | 4 |
| YouTube Men's Fleece Hoodie Black | 3 |
| Google Men's Short Sleeve Badge Tee Charcoal | 3 |
| Crunch Noise Dog Toy | 2 |
| Android Wool Heather Cap Heather/Black | 2 |
| YouTube Twill Cap | 2 |
| Recycled Mouse Pad | 2 |
| Red Shine 15 oz Mug | 2 |
| Google Doodle Decal | 2 |
| Google Men's Short Sleeve Hero Tee Charcoal | 2 |
| Android Women's Fleece Hoodie | 2 |
| 22 oz YouTube Bottle Infuser | 2 |
| Android Men's Vintage Henley | 2 |
| Android Men's Short Sleeve Hero Tee Heather | 1 |
| YouTube Women's Short Sleeve Tri-blend Badge Tee Charcoal | 1 |
| YouTube Hard Cover Journal | 1 |
| Android BTTF Moonshot Graphic Tee | 1 |
| Google Men's Airflow 1/4 Zip Pullover Black | 1 |
| YouTube Men's Long & Lean Tee Charcoal | 1 |
| Google Women's Long Sleeve Tee Lavender | 1 |
| 8 pc Android Sticker Sheet | 1 |
| Google Men's Performance 1/4 Zip Pullover Heather/Black | 1 |
| Google Men's Vintage Badge Tee Black | 1 |
| YouTube Custom Decals | 1 |
| Four Color Retractable Pen | 1 |
| Google Laptop and Cell Phone Stickers | 1 |
| Google Men's Long & Lean Tee Charcoal | 1 |
| Google Twill Cap | 1 |
| Google Men's Long & Lean Tee Grey | 1 |
| Google Men's Bike Short Sleeve Tee Charcoal | 1 |
| Google 5-Panel Cap | 1 |
| Google Toddler Short Sleeve T-shirt Grey | 1 |
| Android Sticker Sheet Ultra Removable | 1 |
| Google Men's Long Sleeve Raglan Ocean Blue | 1 |
| Google Men's Pullover Hoodie Grey | 1 |
| YouTube Men's Short Sleeve Hero Tee White | 1 |
| Android Men's Short Sleeve Hero Tee White | 1 |
| Android Men's Pep Rally Short Sleeve Tee Navy | 1 |
| YouTube Men's Short Sleeve Hero Tee Black | 1 |
| YouTube Women's Short Sleeve Hero Tee Charcoal | 1 |
| Google Men's Performance Full Zip Jacket Black | 1 |
| 26 oz Double Wall Insulated Bottle | 1 |
| Google Men's 100% Cotton Short Sleeve Hero Tee Red | 1 |
| Android Men's Vintage Tank | 1 |
| Google Men's Vintage Badge Tee White | 1 |
| Google Men's  Zip Hoodie | 1 |
| Google Slim Utility Travel Bag | 1 |

**📝 Observation:** Customers who bought the YouTube Henley also frequently purchased other branded apparel and accessories, especially Google Sunglasses.
## "Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase. 
### Add_to_cart_rate = number product  add to cart/number product view. Purchase_rate = number product purchase/number product view. The output should be calculated in product level."
```sql
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
```
### ✅ Results:
| month  | num_product_view | num_add_to_cart | num_purchase | add_to_cart_rate | purchase_rate |
| ------ | ---------------- | --------------- | ------------ | ---------------- | ------------- |
| 201701 | 25787            | 7342            | 2143         | 28.47            | 8.31          |
| 201702 | 21489            | 7360            | 2060         | 34.25            | 9.59          |
| 201703 | 23549            | 8782            | 2977         | 37.29            | 12.64         |

**📝 Observation:** Conversion rates improve over time, with March showing the highest add-to-cart (37.29%) and purchase (12.64%) rates among the three months.
