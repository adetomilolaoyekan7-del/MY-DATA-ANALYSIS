use project;

-- sales channel by revenue
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


    
    -- month by revenue for the year 2019
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
    
    order by month_number
    
    limit 1;
    
    -- customer segmentation according to spending habit
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

 -- SELECT
-- `Unit Price`
-- `Unit Cost`,
--     `Order Quantity`,
--     `Discount Applied`,

--     `Unit Price` * `Order Quantity`
--         * (1 - `Discount Applied`) AS Revenue,

--     `Unit Cost` * `Order Quantity` AS Total_Cost,

--     (`Unit Price` * `Order Quantity`
--         * (1 - `Discount Applied`))
--         -
--     (`Unit Cost` * `Order Quantity`) AS Profit

-- FROM sales_order_usa
-- LIMIT 20;

-- SELECT
--     MIN(`Unit Price`) AS Lowest_Unit_Price,
--     MAX(`Unit Price`) AS Highest_Unit_Price,

--     MIN(`Unit Cost`) AS Lowest_Unit_Cost,
--     MAX(`Unit Cost`) AS Highest_Unit_Cost,

--     AVG(`Unit Price`) AS Average_Unit_Price,
--     AVG(`Unit Cost`) AS Average_Unit_Cost

-- FROM sales_order_usa;

-- SELECT
--     COUNT(*) AS Total_Lines,

--     SUM(
--         (`Unit Price` * `Order Quantity`
--         * (1 - `Discount Applied`))
--         <
--         (`Unit Cost` * `Order Quantity`)
--     ) AS Loss_Making_Lines

-- FROM sales_order_usa;

-- SELECT
--     `Unit Price`,
--     `Unit Cost`,
--     `Order Quantity`,
--     `Discount Applied`,

--     ROUND(
--         `Unit Price` * `Order Quantity`
--         * (1 - `Discount Applied`),
--         2
--     ) AS Revenue,

--     ROUND(
--         `Unit Cost` * `Order Quantity`,
--         2
--     ) AS Total_Cost,

--     ROUND(
--         (`Unit Price` * `Order Quantity`
--         * (1 - `Discount Applied`))
--         -
--         (`Unit Cost` * `Order Quantity`),
--         2
--     ) AS Profit

-- FROM sales_order_usa
-- LIMIT 10; --

-- products causing loss line
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

 