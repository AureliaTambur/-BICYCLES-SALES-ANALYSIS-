# BICYCLES-SALES-ANALYSIS

## Table of Contents

 - [Project Overview](#project-overview)
 - [Data Sources](#data-sources)
 - [Recommendations](#recommendations)

### Project Overview
---
In this project we will analyze sales data of bicycles for the past 3 years to examine the company's profitability in order to increase efficiency and profit. 
![Screenshot 2024-01-17 184246](https://github.com/AureliaTambur/-BICYCLES-SALES-ANALYSIS-/assets/156318226/1d0ab474-f966-4dde-9076-bba207ba6671)

![Screenshot 2024-01-17 184415](https://github.com/AureliaTambur/-BICYCLES-SALES-ANALYSIS-/assets/156318226/b0cb33c3-93f6-42d5-8410-c21743455f20)

### Data Sources
Data for analysis was taken from database Adventure-Works 2016. It was founded in May 2011. The company has branches around the world and sells bicycles and related equipment. Its aim to encourage the sport of cycling throughout the world. 

### Tools
- SQL - Data cleaning and Data Analysis
- Excel- Data Visualization

### Data Cleaning/Preparation
In the initial data preparation phase, we performed the following tasks: 
1. Data loading and inspection.
2. Handling missing values.
3. Data cleaning and formatting.

### Exploratory Data Analysis
EDA involved exploring the data to answer key questions, such as:

- Is the revenue or profitability seasonal ?
- Is there an upward or downward trend in the company’s data over the months and years ?
- How discounts affect the company’s profitability ?
- What are the top most and less sold products?

### Data Analysis
Include some interesting code/features worked with:
```sql
SELECT StandardCost
FROM Production Product
WHERE StandardCost = '0'
```
```SQL
SELECT OrderDate
FROM Sales.SalesOrderHeader
```
``` sql
SELECT  Year OrderDate Year,
        SUM (OrderQty) NoOfItems
FROM #Panel_Revenue_Profit
WHERE Year(OrderDate) between '2012' and '2013'
GROUP BY Year(OrderDate)
```
### Results/Findings
1. There is a slight seasonality in sales. Summer season is favorable for cycling, the heighest revenue months being June-July.
   Q3 has the highest revenue. the most profitable month is November.
2. There is an overall upward trend.
   The company started being profitable  from the last quarter of 2013.
   There were a rise of revenue and profit over the years 2011-2013.
   In 2014 , there was a drop in revenue, as compared to previous years.
3. The bigger the discounts, the less profitable month.
   The Less Profitable Month April 2012 has one of the Highest Amount of Discount(cash discount).
   November with the highest profit has less amount of discount (cash discount). 
4. Category ‘Bikes’ is the most sold from all other categories, with the highest revenue, profit and amount of discount.

### Recommendations
Based on the analysis we recpmmend the following actions:
1. **Seasonal Marketing Emphasis**:
Capitalize on the summer season and Q3 by intensifying marketing efforts for cycling-related products. Consider special promotions or targeted campaigns during June and July to leverage the peak in sales.
2. **Analysis of 2014 Revenue Drop**:
Understanding the causes can help in developing strategies to mitigate similar challenges in the future. This could involve analyzing market trends, customer feedback, or changes in the competitive landscape.
3. **Optimizing Discounts**:
Since higher discounts seem to correlate with lower profitability, consider optimizing discount structures to maintain profitability while still attracting customers. This may involve targeted promotions or loyalty programs rather than broad-based discounts.
4. **Diversification or Focus on 'Bikes' Category**:
Explore opportunities for product innovation, marketing campaigns, or partnerships that can enhance the performance of this key category.

### Limitations
There are missing months for 2011: 1,2,3,4 months and for 2014:7-12 months. So, 2011 and 2014 don't contain all the data about the months and Total Revenue and Profit of this years can't be compared with 2012 and 2013 that contain all the data.The column UnitPriceDiscount contains values with '0', that means that discount was not applied for these products. There are 200 records with '0' StandardCost, these values should be further investigated. 





