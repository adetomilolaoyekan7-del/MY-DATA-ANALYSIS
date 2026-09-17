# USA STORE SALES ANALYSIS 
 A SQL and POWER BI based analysis of retail sales data to uncover sales performance, product trends,
  customer behavior, region based analysis and sale performance and profitability insights.
  
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

-- sales channel by revenue --
select `sales channel`, `unit price`*`order quantity` * (1- `discount applied`) 
as revenue from sales_order_usa;

-- date data type --
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


    
    -- month by revenue for the year 2019 --
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

-- revenue and profit by region --

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
---



   


