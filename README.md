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
```   -- sales channel by revenue 
select `sales channel`, `unit price`*`order quantity` * (1- `discount applied`) 
as revenue from sales_order_usa;

-- date data type 
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


    
   Month by revenue for the year 2019 
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
    
    -- customer segmentation according to spending habit --
WITH CustomerRevenue AS (
    
    SELECT
        customer_usa._CustomerID,
        customer_usa.customer_names,

        SUM(
            sales_order_usa.`unit price` * sales_order_usa.`Order Quantity`
            * (1 - sales_order_usa.`Discount Applied`)
        ) AS Total_Revenue

    FROM customer_usa 

    JOIN sales_order_usa 
        ON customer_usa._CustomerID = sales_order_usa._CustomerID

    GROUP BY
        customer_usa._CustomerID,
        customer_usa.customer_names
),

CustomerTiers AS (

    SELECT
        _CustomerID,
         customer_names,
        Total_Revenue,

        NTILE(3) OVER (
            ORDER BY Total_Revenue DESC
        ) AS Tier

    FROM CustomerRevenue
)

SELECT
    CASE
        WHEN Tier = 1 THEN 'High'
        WHEN Tier = 2 THEN 'Medium'
        WHEN Tier = 3 THEN 'Low'
    END AS Spending_Tier,

    COUNT(*) AS Number_of_Customers,

    ROUND(SUM(Total_Revenue), 2) AS Revenue_Contribution

FROM CustomerTiers

GROUP BY Tier

ORDER BY Tier;

-- revenue and profit by region 

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

-- top 3 stores

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
-- PRODUCT BY PROFIT MARGIN -- 
SELECT
    product_usa.Category,

    SUM(
        sales_order_usa.`Unit Price` * sales_order_usa.`Order Quantity`
        * (1 - sales_order_usa.`Discount Applied`)
    ) AS Total_Revenue,

    SUM(
        (sales_order_usa.`Unit Price` * sales_order_usa.`Order Quantity`
        * (1 - sales_order_usa.`Discount Applied`))
        -
        (sales_order_usa.`Unit Cost` * sales_order_usa.`Order Quantity`)
    ) AS Total_Profit,

    (
        SUM(
            (sales_order_usa.`Unit Price` * sales_order_usa.`Order Quantity`
            * (1 - sales_order_usa.`Discount Applied`))
            -
            (sales_order_usa.`Unit Cost` * sales_order_usa.`Order Quantity`)
        )
        /
        NULLIF(
            SUM(
                sales_order_usa.`Unit Price`* sales_order_usa.`Order Quantity`
                * (1 - sales_order_usa.`Discount Applied`)
            ),
            0
        )
    ) * 100 AS Profit_Margin_Percent

FROM sales_order_usa 

JOIN product_usa 
    ON sales_order_usa._ProductID = product_usa._ProductID

GROUP BY product_usa.Category

ORDER BY Profit_Margin_Percent DESC;

-- sales channel with high profit margin

SELECT
    `Sales Channel`,

    SUM(
        `Unit Price` * `Order Quantity`
        * (1 - `Discount Applied`)
    ) AS Total_Revenue,

    SUM(
        (`Unit Price` * `Order Quantity`
        * (1 - `Discount Applied`))
        -
        (`Unit Cost` * `Order Quantity`)
    ) AS Total_Profit,

    ROUND(
        SUM(
            (`Unit Price` * `Order Quantity`
            * (1 - `Discount Applied`))
            -
            (`Unit Cost` * `Order Quantity`)
        )
        /
        NULLIF(
            SUM(
                `Unit Price` * `Order Quantity`
                * (1 - `Discount Applied`)
            ),
            0
        ) * 100,
        2
    ) AS Profit_Margin

FROM sales_order_usa

GROUP BY `Sales Channel`

ORDER BY Profit_Margin DESC;

-- brand performance
SELECT
    product_usa.Brand,

    SUM(
        sales_order_usa.`Unit Price` * sales_order_usa.`Order Quantity`
        * (1 - sales_order_usa.`Discount Applied`)
    ) AS Total_Revenue,

    SUM(
        (sales_order_usa.`Unit Price` * sales_order_usa.`Order Quantity`
        * (1 - sales_order_usa.`Discount Applied`))
        -
        (sales_order_usa.`Unit Cost` * sales_order_usa.`Order Quantity`)
    ) AS Total_Profit,

    COUNT(DISTINCT sales_order_usa.OrderNumber) AS Total_Orders

FROM sales_order_usa 

JOIN product_usa 
    ON sales_order_usa._ProductID = product_usa._ProductID

GROUP BY product_usa.Brand

ORDER BY Total_Revenue DESC;

-- sales rep perfromance

SELECT
    sales_team_usa.`Sales Team`,
    sales_team_usa.Region,

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

JOIN sales_team_usa 
    ON sales_order_usa._SalesTeamID = sales_team_usa._SalesTeamID

GROUP BY
    sales_order_usa._SalesTeamID,
    sales_team_usa.`Sales Team`,
    sales_team_usa.Region

ORDER BY Total_Revenue DESC;
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

<img width="1171" height="547" alt="Screenshot 2026-09-17 154432" src="https://github.com/user-attachments/assets/1beb2161-4b7c-4514-a5e8-06e093eeba88" />

<img width="1198" height="545" alt="Screenshot 2026-09-17 153410" src="https://github.com/user-attachments/assets/29d85cc2-083b-4c1a-a846-23551738b6f3" />

<img width="1191" height="537" alt="Screenshot 2026-09-17 153512" src="https://github.com/user-attachments/assets/4979c4cf-4f3d-4788-8090-b772cfa67b1e" />

<img width="1197" height="530" alt="Screenshot 2026-09-17 153538" src="https://github.com/user-attachments/assets/40ee95be-2328-4079-b8d2-5c444de4747c" />

<img width="1150" height="539" alt="Screenshot 2026-09-17 153606" src="https://github.com/user-attachments/assets/4ec52027-62fa-4c03-b09a-adb0bc97e39a" />





   


