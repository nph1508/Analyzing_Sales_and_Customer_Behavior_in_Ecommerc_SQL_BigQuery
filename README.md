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
test nhé
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
## Query 3: Revenue by traffic source by week, by month in June 2017
## Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
## Query 05: Average number of transactions per user that made a purchase in July 2017
## Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
## Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
## "Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase. 
### Add_to_cart_rate = number product  add to cart/number product view. Purchase_rate = number product purchase/number product view. The output should be calculated in product level."
