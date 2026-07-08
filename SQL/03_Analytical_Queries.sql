-- ============================================================
-- Project    : PrimeNest Real Estate Analytics
-- File       : 04_Analytical_Queries.sql
-- Author     : Kaustubh Waghmare
-- Description:
-- Collection of business analytical queries used to generate
-- insights from the PrimeNest Real Estate Analytics database.
-- ============================================================

USE PrimeNestDB;

-- ============================================================
-- Query 1
-- Business Objective:
-- Find the total number of properties available in each city.
-- ============================================================

SELECT
    l.City,
    COUNT(p.PropertyID) AS Total_Properties
FROM DimProperty p
INNER JOIN DimLocation l
    ON p.LocationID = l.LocationID
GROUP BY l.City
ORDER BY Total_Properties DESC;




-- ============================================================
-- Query 2
-- Business Objective:
-- Identify the top 5 agents based on total property sales
-- revenue.
-- ============================================================
SELECT
    a.AgentID,
    a.AgentName,
    SUM(f.SalePrice) AS Total_Sales_Revenue
FROM FactPropertyTransactions f
INNER JOIN DimAgent a
    ON f.AgentID = a.AgentID
GROUP BY
    a.AgentID,
    a.AgentName
ORDER BY Total_Sales_Revenue DESC
LIMIT 5;




-- ============================================================
-- Query 3
-- Business Objective:
-- Analyze monthly sales revenue for the year 2025.
-- ============================================================
SELECT
    d.MonthName,
    SUM(f.SalePrice) AS Monthly_Sales_Revenue
FROM FactPropertyTransactions f
INNER JOIN DimDate d
    ON f.TransactionDate = d.Date
WHERE d.Year = 2025
GROUP BY
    d.Month,
    d.MonthName
ORDER BY d.Month;


-- ============================================================
-- Query 4
-- Business Objective:
-- Identify the top five cities generating the highest sales
-- revenue.
-- ============================================================
SELECT
    l.City,
    SUM(f.SalePrice) AS Total_Sales_Revenue
FROM FactPropertyTransactions f
INNER JOIN DimProperty p
    ON f.PropertyID = p.PropertyID
INNER JOIN DimLocation l
    ON p.LocationID = l.LocationID
GROUP BY l.City
ORDER BY Total_Sales_Revenue DESC
LIMIT 5;

-- ============================================================
-- Query 5
-- Business Objective:
-- Find the highest revenue-generating property in each city.
-- ============================================================
SELECT
    City,
    PropertyID,
    Total_Revenue
FROM
(
    SELECT
        l.City,
        p.PropertyID,
        SUM(f.SalePrice) AS Total_Revenue,
        ROW_NUMBER() OVER
        (
            PARTITION BY l.City
            ORDER BY SUM(f.SalePrice) DESC
        ) AS rn
    FROM FactPropertyTransactions f
    INNER JOIN DimProperty p
        ON f.PropertyID = p.PropertyID
    INNER JOIN DimLocation l
        ON p.LocationID = l.LocationID
    GROUP BY
        l.City,
        p.PropertyID
) AS RevenueRank
WHERE rn = 1;


-- ============================================================
-- Query 6
-- Business Objective:
-- Calculate the average selling price for each property type.
-- ============================================================
SELECT
    p.PropertyType,
    AVG(f.SalePrice) AS Average_Selling_Price
FROM FactPropertyTransactions f
INNER JOIN DimProperty p
    ON f.PropertyID = p.PropertyID
GROUP BY p.PropertyType
ORDER BY Average_Selling_Price DESC;

-- ============================================================
-- Query 7
-- Business Objective:
-- Identify customers who purchased more than three properties.
-- ============================================================
SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(f.PropertyID) AS Total_Properties_Purchased
FROM FactPropertyTransactions f
INNER JOIN DimCustomer c
    ON f.CustomerID = c.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName
HAVING COUNT(f.PropertyID) > 3
ORDER BY Total_Properties_Purchased DESC;


-- ============================================================
-- Query 8
-- Business Objective:
-- Find properties that have never been sold.
-- ============================================================
SELECT
    p.PropertyID,
    p.PropertyType,
    p.Status
FROM DimProperty p
LEFT JOIN FactPropertyTransactions f
    ON p.PropertyID = f.PropertyID
WHERE f.PropertyID IS NULL;



-- ============================================================
-- Query 9
-- Business Objective:
-- Calculate month-over-month sales revenue growth.
-- Demonstrates the use of CTEs and LAG().
-- ============================================================
WITH MonthlySales AS
(
    SELECT
        d.Year,
        d.Month,
        d.MonthName,
        SUM(f.SalePrice) AS Monthly_Revenue
    FROM FactPropertyTransactions f
    INNER JOIN DimDate d
        ON f.TransactionDate = d.Date
    GROUP BY
        d.Year,
        d.Month,
        d.MonthName
)

SELECT
    Year,
    MonthName,
    Monthly_Revenue,
    LAG(Monthly_Revenue) OVER
    (
        ORDER BY Year, Month
    ) AS Previous_Month_Revenue,

    Monthly_Revenue -
    LAG(Monthly_Revenue) OVER
    (
        ORDER BY Year, Month
    ) AS Revenue_Growth,

    ROUND(
        (
            (Monthly_Revenue -
            LAG(Monthly_Revenue) OVER (ORDER BY Year, Month))
            /
            LAG(Monthly_Revenue) OVER (ORDER BY Year, Month)
        ) * 100,
        2
    ) AS Growth_Percentage
FROM MonthlySales
ORDER BY Year, Month;



-- ============================================================
-- Query 10
-- Business Objective:
-- Rank the top three performing agents in each city based on
-- transaction count.
-- ============================================================
WITH AgentTransactions AS
(
    SELECT
        l.City,
        a.AgentID,
        a.AgentName,
        COUNT(f.TransactionID) AS Total_Transactions
    FROM FactPropertyTransactions f
    INNER JOIN DimAgent a
        ON f.AgentID = a.AgentID
    INNER JOIN DimProperty p
        ON f.PropertyID = p.PropertyID
    INNER JOIN DimLocation l
        ON p.LocationID = l.LocationID
    GROUP BY
        l.City,
        a.AgentID,
        a.AgentName
)

SELECT
    City,
    AgentID,
    AgentName,
    Total_Transactions,
    DENSE_RANK() OVER
    (
        PARTITION BY City
        ORDER BY Total_Transactions DESC
    ) AS Agent_Rank
FROM AgentTransactions
QUALIFY Agent_Rank <= 3;



-- ============================================================
-- Query 11
-- Business Objective:
-- Retrieve the ten highest-priced properties sold.
-- ============================================================
SELECT
    p.PropertyID,
    p.PropertyType,
    f.SalePrice
FROM FactPropertyTransactions f
INNER JOIN DimProperty p
    ON f.PropertyID = p.PropertyID
ORDER BY f.SalePrice DESC
LIMIT 10;



-- ============================================================
-- Query 12
-- Business Objective:
-- Identify the city generating the highest revenue in each year.
-- ============================================================
WITH CityRevenue AS
(
    SELECT
        d.Year,
        l.City,
        SUM(f.SalePrice) AS Total_Revenue
    FROM FactPropertyTransactions f
    INNER JOIN DimProperty p
        ON f.PropertyID = p.PropertyID
    INNER JOIN DimLocation l
        ON p.LocationID = l.LocationID
    INNER JOIN DimDate d
        ON f.TransactionDate = d.Date
    GROUP BY
        d.Year,
        l.City
),
RankedCities AS
(
    SELECT
        Year,
        City,
        Total_Revenue,
        DENSE_RANK() OVER
        (
            PARTITION BY Year
            ORDER BY Total_Revenue DESC
        ) AS Revenue_Rank
    FROM CityRevenue
)

SELECT
    Year,
    City,
    Total_Revenue
FROM RankedCities
WHERE Revenue_Rank = 1
ORDER BY Year;