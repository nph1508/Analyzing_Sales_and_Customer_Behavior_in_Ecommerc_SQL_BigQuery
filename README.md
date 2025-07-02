# Analyzing Sales & Customer Behavior in Ecommerce | SQL BigQuery
Author: Nguyễn Phương Huy

Date: 2000-15-08

Tools Used: SQL
## 📑 Table of Contents
1. [📌 Background & Overview](#-background--overview)
2. [📂 Dataset Description & Data Structure](#-dataset-description--data-structure)
3. [🔎 Final Conclusion & Recommendations](#-final-conclusion--recommendations)
## 📌 Background & Overview
🎯 Objective
📖 This project uses SQL (BigQuery) to analyze an ecommerce dataset in order to:

✔️ Uncover trends in sales performance across product categories and time periods

✔️ Analyze customer behavior patterns, including frequency and purchase volume

✔️ Identify top-performing products and underperforming segments

✔️ Provide data-driven insights to support inventory, marketing, and sales decisions

💡 Main Business Questions:

What are the best-selling product categories over time?

Which customers contribute most to total revenue?

Are there seasonal patterns in customer purchasing behavior?

How can we segment customers based on their purchase activity?

👤 Who is this project for?

✔️ Data Analysts seeking to practice SQL in a real-world ecommerce context

✔️ Business Analysts / Ecommerce Teams needing insights to optimize operations and marketing

✔️ Decision-Makers who want to understand customer dynamics and product performance

## 📂 Dataset Description & Data Structure
### 📌 Data Source

- **Source:** [Google Analytics Sample Dataset](https://console.cloud.google.com/marketplace/product/bigquery-public-data/google-analytics-sample)  
- **Size:** ~400,000 rows × 15+ columns  
- **Format:** BigQuery table (`.sql`)

### 📊 Data Structure & Relationships**

1️⃣ Tables Used:<details>
  <summary>📋 Click to view </summary>

| Field Name | Data Type | Description |
| --- | --- | --- |
| fullVisitorId | STRING | The unique visitor ID. |
| date | STRING | The date of the session in YYYYMMDD format. |
| totals | RECORD | This section contains aggregate values across the session. |
| totals.bounces | INTEGER | Total bounces (for convenience). For a bounced session, the value is 1, otherwise it is null. |
| totals.hits | INTEGER | Total number of hits within the session. |
| totals.pageviews | INTEGER | Total number of pageviews within the session. |
| totals.visits | INTEGER | The number of sessions (for convenience). This value is 1 for sessions with interaction events. The value is null if there are no interaction events in the session. |
| totals.transactions | INTEGER | Total number of ecommerce transactions within the session. |
| trafficSource.source | STRING | The source of the traffic source. Could be the name of the search engine, the referring hostname, or a value of the utm_source URL parameter. |
| hits | RECORD | This row and nested fields are populated for any and all types of hits. |
| hits.eCommerceAction | RECORD | This section contains all of the ecommerce hits that occurred during the session. This is a repeated field and has an entry for each hit that was collected. |
| hits.eCommerceAction.action_type | STRING | The action type. Click through of product lists = 1, Product detail views = 2, Add product(s) to cart = 3, Remove product(s) from cart = 4, Check out = 5, Completed purchase = 6, Refund of purchase = 7, Checkout options = 8, Unknown = 0.<br>Usually this action type applies to all the products in a hit, with the following exception: when hits.product.isImpression = TRUE, the corresponding product is a product impression that is seen while the product action is taking place (i.e., a "product in list view").<br>Example query to calculate number of products in list views:<br>SELECT<br>COUNT(hits.product.v2ProductName)<br>FROM [foo-160803:123456789.ga_sessions_20170101]<br>WHERE hits.product.isImpression == TRUE<br>Example query to calculate number of products in detailed view:<br>SELECT<br>COUNT(hits.product.v2ProductName),<br>FROM<br>[foo-160803:123456789.ga_sessions_20170101]<br>WHERE<br>hits.ecommerceaction.action_type = '2'<br>AND ( BOOLEAN(hits.product.isImpression) IS NULL OR BOOLEAN(hits.product.isImpression) == FALSE ) |
| hits.product | RECORD | This row and nested fields will be populated for each hit that contains Enhanced Ecommerce PRODUCT data. |
| hits.product.productQuantity | INTEGER | The quantity of the product purchased. |
| hits.product.productRevenue | INTEGER | The revenue of the product, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.product.productSKU | STRING | Product SKU. |
| hits.product.v2ProductName | STRING | Product Name. |

</details>

2️⃣Table Schema: https://support.google.com/analytics/answer/3437719?hl=en

## ⚒️Main Process
### Query 01: Calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
**Purpose:** Aggregates 3 key metrics (visits, pageviews, transactions) by month (Jan–Mar 2017).  
**Goal:** Detect seasonal performance trends and identify which months bring better engagement.
```sql
select 
  format_date('%Y%m',parse_date('%Y%m%d', `date`)) as month,
  count(totals.visits) as visits,
  sum(totals.pageviews) as pageviews,
  sum(totals.transactions) as transactions
from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
where _table_suffix between '0101' and '0331'
group by month
order by month;
```
** ✅ Results:** 
| month   | visits | pageviews | transactions |
|---------|--------|-----------|--------------|
| 201701  | 64,694 | 257,708   | 713          |
| 201702  | 62,192 | 233,373   | 733          |
| 201703  | 69,931 | 259,522   | 993          |

**📝 Observation:** The table shows monthly aggregated metrics. March (201703) demonstrates an improvement across all key indicators—visits, pageviews, and transactions—compared to January and February.
### Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
**Purpose:** Calculates bounce rate = bounces / visits per source.  
**Goal:** Evaluate traffic quality by source and identify underperforming channels.
```sql
select
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.bounces) as total_no_of_bounces,
    round((sum(totals.bounces)/sum(totals.visits))* 100.00,2) as bounce_rate
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
group by source
order by total_visits DESC;
```
** ✅ Results:** 
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

**📝 Observation:** Google and direct traffic are the main sources by volume, while platforms like Reddit and mail.google.com show significantly lower bounce rates.
### Query 3: Revenue by traffic source by week, by month in June 2017
**Purpose:** Shows revenue distribution by traffic source, split by month and week.  
**Goal:** Understand financial contribution and fluctuations per source over time.
```sql
select 
    'month' as time_type,
    format_date('%y%m', date(parse_date('%y%m%d', date))) as time,
    trafficsource.source as source,
    sum(product.productrevenue) / 1000000 as revenue
from `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
unnest(hits) as hit,
unnest(hit.product) as product
where product.productRevenue is not null
group by time, source

union all 

select
    'week' as time_type,
    format_date('%y%w', date(parse_date('%y%m%d', date))) as time,
    trafficsource.source as source,
    sum(product.productRevenue) / 1000000 as revenue
from `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
unnest(hits) as hit,
unnest(hit.product) as product
where product.productRevenue is not null
group by time, source

order by time_type, revenue desc;
```
#### ✅ Results:
| time_type | time | source | revenue |
| --- | --- | --- | --- |
| Month | 201706 | (direct) | 97,333.62 |
| Month | 201706 | google | 18,757.18 |
| Month | 201706 | dfa | 8,862.23 |
| Month | 201706 | mail.google.com | 2,563.13 |
| Month | 201706 | search.myway.com | 105.939998 |
| Week | 201724 | (direct) | 30,908.91 |
| Week | 201725 | (direct) | 27,295.32 |
| Week | 201723 | (direct) | 17,325.68 |
| Week | 201726 | (direct) | 14,914.81 |
| Week | 201724 | google | 9,217.17 |

**📝 Observation:** Direct traffic drives the most revenue both monthly and weekly. Google and DFA are also top-performing sources, but with lower contribution.
### Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
**Purpose:** Compares user engagement across groups based on purchase behavior (June–July 2017).  
**Goal:** Identify browsing behavior and its correlation with conversion.
```sql
with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      round((sum(totals.pageviews)/count(distinct fullVisitorId)),2) as avg_pageviews_purchase,
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
      sum(totals.pageviews)/count(distinct fullVisitorId) as avg_pageviews_non_purchase,
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
** ✅ Results:** 
| month  | avg_pageviews_purchase | avg_pageviews_non_purchase |
| ------ | ---------------------- | -------------------------- |
| 201706 | 94.02                  | 316.87                     |
| 201707 | 124.24                 | 334.06                     |

**📝 Observation:** Surprisingly, non-purchasers have much higher average pageviews per user than purchasers, suggesting browsing-heavy behavior without conversion.
### Query 05: Average number of transactions per user that made a purchase in July 2017
**Purpose:** Measures how many transactions each buyer performs on average.  
**Goal:** Understand user lifetime value and buying depth.
```sql
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    round(
        sum(totals.transactions)/count(distinct fullVisitorId)
        ,3) as Avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,unnest (hits) hits,
    unnest(product) product
where  totals.transactions>=1
and product.productRevenue is not null
group by month;
```
** ✅ Results:** 
| month  | Avg_total_transactions_per_user |
| ------ | ------------------------------- |
| 201707 | 4.164                           |

**📝 Observation:** On average, each purchasing user completed over 4 transactions, indicating strong repeat buying behavior in July.
### Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
**Purpose:** Calculates monetary value per session with transaction.  
**Goal:** Estimate effectiveness of purchase sessions in terms of revenue.
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
** ✅ Results:** 
| month  | avg_revenue_by_user_per_visit |
| ------ | ----------------------------- |
| 201707 | 43.86                         |

**📝 Observation:** Each purchase session generated an average of $43.86 in revenue, which reflects solid value per visit from buyers.
### Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
**Purpose:** Identifies other items frequently purchased with the target product.  
**Goal:** Support cross-sell strategies and product bundling.
```sql
with customers as (
  select distinct fullVisitorId
  from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
  unnest(hits) as hits,
  unnest(hits.product) as product
  where product.v2ProductName = "youtube men's vintage henley"
    and product.productRevenue is not null
    and totals.transactions >= 1
)

select 
  product.v2ProductName as other_purchased_products, 
  sum(product.productQuantity) as quantity
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
unnest(hits) as hits,
unnest(hits.product) as product
join customers using (fullVisitorId)
where product.v2ProductName != "youtube men's vintage henley"
  and product.productRevenue is not null
  and totals.transactions >= 1
group by product.v2ProductName
order by quantity desc;
```
** ✅ Results:** 
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

**📝 Observation:** Customers who bought the YouTube Henley also frequently purchased other branded apparel and accessories, especially Google Sunglasses.
### "Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase. 
#### Add_to_cart_rate = number product  add to cart/number product view. Purchase_rate = number product purchase/number product view. The output should be calculated in product level."
**Purpose:** Calculates add-to-cart and purchase conversion rates at product level across 3 months.  
**Goal:** Evaluate funnel effectiveness and optimize product-level conversion.
```sql
with product_data as(
select
    format_date('%Y%m', parse_date('%Y%m%d',date)) as month,
    count(case when eCommerceAction.action_type = '2' then product.v2ProductName end) as num_product_view,
    count(case when eCommerceAction.action_type = '3' then product.v2ProductName end) as num_add_to_cart,
    count(case when eCommerceAction.action_type = '6' and product.productRevenue is not null then product.v2ProductName end) as num_purchase
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
** ✅ Results:** 
| month  | num_product_view | num_add_to_cart | num_purchase | add_to_cart_rate | purchase_rate |
| ------ | ---------------- | --------------- | ------------ | ---------------- | ------------- |
| 201701 | 25787            | 7342            | 2143         | 28.47            | 8.31          |
| 201702 | 21489            | 7360            | 2060         | 34.25            | 9.59          |
| 201703 | 23549            | 8782            | 2977         | 37.29            | 12.64         |

**📝 Observation:** Conversion rates improve over time, with March showing the highest add-to-cart (37.29%) and purchase (12.64%) rates among the three months.
## 🔎 Final Conclusion & Recommendations

👉🏻 Based on the insights and findings above, we would recommend the **Ecommerce & Marketing Team** to consider the following:

### 📌 Key Takeaways:

✔️ **Replicate successful March strategies** across future campaigns, as this month showed consistent growth in visits, engagement, and conversions.  
✔️ **Improve high-bounce traffic sources** such as YouTube and Facebook by optimizing ad content or landing pages to improve engagement.  
✔️ **Introduce product bundles** that include “YouTube Men's Vintage Henley” and frequently co-purchased items (e.g., Google Sunglasses) to increase average order value.
