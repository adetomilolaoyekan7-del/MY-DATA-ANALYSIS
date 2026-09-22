# USA STORE SALES ANALYSIS 
 A SQL and POWER BI based analysis of retail sales data to uncover sales performance, product trends,
 customer behavior, region based analysis and sale performance and profitability insights.
  
  --- 
  
**Project Overview**

 This project focuses on analyzing a USA store sales dataset using SQL to clean and extract meaningful insights, performing 
exploratory data analysis, and using SQL queries to examine sales trends, product performance, revenue, and profitability.
Through the use of MYSQL functions like the aggregate functions, filtering, and data manipulation techniques this project demonstrates
how raw sales data can be transformed into meaningful insights while also using  Power BI to illustrate beautiful stories in a way that tells the audience exactly what that bunch of datasets says.
 
The goal is to strengthen my SQL skills so I can use it to create and extract meaningful and sharp KPI ideas that tell the stories the mere numbers in the dataset cannot while gaining insights into retail sales performance and business operations.

**Project Objective**

* Analyze overall sales performance
* Examine sales by category/region
* Calculate revenue, cost, and profit
* Identify trends in customer purchases
* Practice data cleaning and transformation using MYSQL

**Tools and Technologies**

 *  MySQL Workbench
 *  Power BI
 *  GitHub
 *  CSV Dataset

**Data Cleaning and Preparation**

 * Correcting column data types
 * Converting date values
 * Handling inconsistent data
 * Renaming columns where neccesary
 * Checking for missing/duplicate records
 * Preparing the dataset for analysis

**SQL ANALYSIS**

--- 
_SQL_

This part of the code was used to generate the sales channel by revenue using simple aggregate function in SQL

``` 
select `sales channel`, `unit price`*`order quantity` * (1- `discount applied`) 
as revenue from sales_order_usa;
```

 I changed the data type of the DATE in the dataset to the format accepted by SQL so that my result can be consistent by using the STR_TO_DATE function.
 
```  
UPDATE sales_order_usa
SET ProcuredDate = STR_TO_DATE(ProcuredDate, '%d/%m/%Y'),
    OrderDate = STR_TO_DATE(OrderDate, '%d/%m/%Y'),
    ShipDate = STR_TO_DATE(ShipDate, '%d/%m/%Y'),
    DeliveryDate = STR_TO_DATE(DeliveryDate, '%d/%m/%Y');
    
    ALTER TABLE sales_order_usa
MODIFY ProcuredDate DATE,
MODIFY OrderDate DATE,
MODIFY ShipDate DATE,
MODIFY DeliveryDate DATE;
```
This is to arrange the revenue in orders by month for the year 2019 using the GROUP BY  and WHERE function

``` 
SELECT
    MONTH(OrderDate) AS Month_Number,
    MONTHNAME(OrderDate) AS Month_Name,

    SUM(
        `Unit Price` * `Order Quantity`
        * (1 - `Discount Applied`)
    ) AS Total_Revenue

FROM sales_order_usa

WHERE YEAR(OrderDate) = 2019

GROUP BY
    MONTH(OrderDate),
    MONTHNAME(OrderDate)
    
    order by month_number;
 ```
 I used the JOIN, AGGREGATE FUNCTIONS, GROUP BY, ORDER and WHERE function SQL to determine the revenue and profit by region
  
``` 
SELECT
    Region_usa.Region,

    SUM(
        sales_order_usa.`Unit Price` * sales_order_usa.`Order Quantity`
        * (1 - sales_order_usa.`Discount Applied`)
    ) AS Total_Revenue,

    SUM(
        (sales_order_usa.`Unit Price` * sales_order_usa.`Order Quantity`
        * (1 - sales_order_usa.`Discount Applied`))
        -
        (sales_order_usa.`Unit Cost` * sales_order_usa.`Order Quantity`)
    ) AS Total_Profit

FROM sales_order_usa 

JOIN store_sales_usa 
    ON sales_order_usa._StoreID = store_sales_usa._StoreID

JOIN region_usa 
    ON store_sales_usa.StateCode = region_usa.StateCode

GROUP BY region_usa.Region

ORDER BY Total_Revenue DESC;

SELECT
    product_usa.`Product Name`,
    SUM(
        (`Unit Price` * `Order Quantity`
        * (1 - `Discount Applied`))
        -
        (`Unit Cost` * `Order Quantity`)
    ) AS Total_Profit

FROM sales_order_usa 

JOIN product_usa 
    ON sales_order_usa._ProductID = product_usa._ProductID

GROUP BY
    product_usa._ProductID,
    product_usa.`Product Name`

ORDER BY Total_Profit ASC;
```

The code generates the top three stores by the revenue in ascending orders

``` 
WITH StoreRevenue AS (

    SELECT
        store_sales_usa._StoreID,
        store_sales_usa.`City Name`,
        region_usa.Region,

        SUM(
            sales_order_usa.`Unit Price` * sales_order_usa.`Order Quantity`
            * (1 - sales_order_usa.`Discount Applied`)
        ) AS Total_Revenue
    FROM sales_order_usa 

    JOIN store_sales_usa 
        ON sales_order_usa._StoreID = store_sales_usa._StoreID

    JOIN region_usa 
        ON store_sales_usa.StateCode = region_usa.StateCode

    GROUP BY
        store_sales_usa._StoreID,
        store_sales_usa.`City Name`,
        region_usa.Region
),

RankedStores AS (

    SELECT
        *,
        RANK() OVER (
            PARTITION BY Region
            ORDER BY Total_Revenue DESC
        ) AS Store_Rank

    FROM StoreRevenue
)

SELECT
    Region,
    Store_Rank,
    `City Name`,
    Total_Revenue

FROM RankedStores

WHERE Store_Rank <= 3

ORDER BY Region, Store_Rank;
```
---

***KEY INSIGHTS***

* Online sales channel generated more revenue than the rest of the sales channel.
* January had the highest revenue generating over $130 million.
* The high spending tier contributes 41.77 percent of the spending and incomes generated followed by the medium tier at 33.8 percent
* There is a very high negative profit indicating that the total cost of the goods exceeds the revenue earned after discounts.

 ***Conclusions***
 
 The profitability analysis revealed that the business recorded a total revenue of $4.05 million and a negative total profit of $5.41 million, with a profit margin of -74.87% indicating that the retail store is going through a serious loss condition that needs to corrected.

A Plausible cause could be because the product price and cost comparison indicates that some products may have unit costs exceeding their selling prices. This suggests that pricing relative to product costs may be a contributing factor to negative profitability.

---
***A screenshot of my Dashboard using POWER BI for visualizations***
## OVERVIEW

This page gives a brief summary of the major insights derived from the dataset

<img width="983" height="542" alt="Screenshot 2026-09-19 231852" src="https://github.com/user-attachments/assets/b16597b8-2fb2-4d2c-937b-d46ba556dc6e" />

## SALES

This page dives deeper into the insights on sales like the total orders taken, the rate at which the customers spend and the total products sold etc.

<img width="981" height="538" alt="Screenshot 2026-09-19 232122" src="https://github.com/user-attachments/assets/ba777ca5-e9dc-4e01-abf4-5a14e7e04535" />

## PROFITABILITY

While performing my analysis I discovered a huge loss in the sales and I represented it as the orange color to indicate attention in that area.

<img width="982" height="546" alt="Screenshot 2026-09-19 232315" src="https://github.com/user-attachments/assets/f975493e-26ad-471e-8aad-7e941ec13385" />

## REGION AND STORE

 This is a deeper dive into sales and profits or loss across regions and a drill down across states to geta better understanding of where most revenues or losses come per region

 <img width="957" height="543" alt="Screenshot 2026-09-19 232530" src="https://github.com/user-attachments/assets/0ad86737-534d-4175-8cb0-7c9e7a853957" />

## SALES TEAM/REPRESENTATIVE

 A visual representation of which sales rep across regions, states and countries generated more revenue or carried more losses and a comparison of revenues by orders taken by each sales representative

 
<img width="969" height="540" alt="Screenshot 2026-09-19 232712" src="https://github.com/user-attachments/assets/29cf932b-15f1-4900-9877-762d22812a20" />








   


