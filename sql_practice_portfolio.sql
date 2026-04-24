/*
===========================================================
SQL PRACTICE PORTFOLIO
Author: Mukhi Ballav

Description:
This file contains SQL queries demonstrating:
- Basic Queries
- Joins
- Aggregations
- Subqueries
- Window Functions
- Business Case Scenarios

===========================================================
*/

-----------------------------------------------------------
-- 1. List all customers
-----------------------------------------------------------
SELECT *
FROM Customer;


-----------------------------------------------------------
-- 2. List first name, last name, and city of customers
-----------------------------------------------------------
SELECT FirstName, LastName, City
FROM Customer;


-----------------------------------------------------------
-- 3. Customers from Sweden
-----------------------------------------------------------
SELECT *
FROM Customer
WHERE Country = 'Sweden';


-----------------------------------------------------------
-- 4. Create SupplierCopy and update city
-- (SQL Server specific: SELECT INTO)
-----------------------------------------------------------
SELECT *
INTO SupplierCopy
FROM Supplier;

UPDATE SupplierCopy
SET City = 'Sydney'
WHERE CompanyName LIKE 'P%';


-----------------------------------------------------------
-- 5. Create ProductCopy and delete expensive products
-----------------------------------------------------------
SELECT *
INTO ProductCopy
FROM Product;

DELETE FROM ProductCopy
WHERE UnitPrice > 50;


-----------------------------------------------------------
-- 6. Number of customers per country
-----------------------------------------------------------
SELECT Country, COUNT(Id) AS Customer_Count
FROM Customer
GROUP BY Country;


-----------------------------------------------------------
-- 7. Customers per country (sorted high to low)
-----------------------------------------------------------
SELECT Country, COUNT(Id) AS Customer_Count
FROM Customer
GROUP BY Country
ORDER BY Customer_Count DESC;


-----------------------------------------------------------
-- 8. Total order amount per customer
-----------------------------------------------------------
SELECT 
    c.Id,
    CONCAT(c.FirstName, ' ', c.LastName) AS Customer_Name,
    SUM(o.TotalAmount) AS Total_Amount
FROM Orders o
INNER JOIN Customer c
    ON c.Id = o.CustomerId
GROUP BY c.Id, CONCAT(c.FirstName, ' ', c.LastName);


-----------------------------------------------------------
-- 9. Countries with more than 10 customers
-----------------------------------------------------------
SELECT Country, COUNT(Id) AS Customer_Count
FROM Customer
GROUP BY Country
HAVING COUNT(Id) > 10;


-----------------------------------------------------------
-- 10. Countries (excluding USA) with >= 9 customers
-----------------------------------------------------------
SELECT Country, COUNT(Id) AS Customer_Count
FROM Customer
WHERE Country <> 'USA'
GROUP BY Country
HAVING COUNT(Id) >= 9
ORDER BY Customer_Count DESC;


-----------------------------------------------------------
-- 11. Customers with 'ill' in name
-----------------------------------------------------------
SELECT *
FROM Customer
WHERE FirstName LIKE '%ill%'
   OR LastName LIKE '%ill%';


-----------------------------------------------------------
-- 12. Customers with avg order between 1000–1200
-----------------------------------------------------------
SELECT TOP 5
    c.Id,
    CONCAT(c.FirstName, ' ', c.LastName) AS Customer_Name,
    AVG(o.TotalAmount) AS Avg_Amount
FROM Customer c
INNER JOIN Orders o
    ON c.Id = o.CustomerId
GROUP BY c.Id, CONCAT(c.FirstName, ' ', c.LastName)
HAVING AVG(o.TotalAmount) BETWEEN 1000 AND 1200;


-----------------------------------------------------------
-- 13. Suppliers from USA, Japan, Germany
-----------------------------------------------------------
SELECT *
FROM Supplier
WHERE Country IN ('USA', 'Japan', 'Germany')
ORDER BY Country ASC, CompanyName DESC;


-----------------------------------------------------------
-- 14. Orders sorted by year and amount
-----------------------------------------------------------
SELECT 
    Id,
    OrderDate,
    YEAR(OrderDate) AS Order_Year,
    CustomerId,
    TotalAmount
FROM Orders
ORDER BY Order_Year ASC, TotalAmount DESC;


-----------------------------------------------------------
-- 15. Delete products > $25 (business scenario)
-----------------------------------------------------------
DELETE FROM ProductCopy
WHERE UnitPrice > 25;


-----------------------------------------------------------
-- 16. Top 10 most expensive products
-----------------------------------------------------------
SELECT TOP 10 *
FROM Product
ORDER BY UnitPrice DESC;


-----------------------------------------------------------
-- 17. Products excluding top 10 expensive ones
-----------------------------------------------------------
SELECT *
FROM Product
ORDER BY UnitPrice DESC
OFFSET 10 ROWS;


-----------------------------------------------------------
-- 18. 10th to 15th most expensive products
-----------------------------------------------------------
SELECT *
FROM Product
ORDER BY UnitPrice DESC
OFFSET 9 ROWS
FETCH NEXT 5 ROWS ONLY;


-----------------------------------------------------------
-- 19. Count of distinct supplier countries
-----------------------------------------------------------
SELECT COUNT(DISTINCT Country) AS Supplier_Countries
FROM Supplier;


-----------------------------------------------------------
-- 20. Monthly sales for 2013
-----------------------------------------------------------
SELECT 
    MONTH(OrderDate) AS Month_Number,
    FORMAT(OrderDate, 'MMMM') AS Month_Name,
    SUM(TotalAmount) AS Total_Sales
FROM Orders
WHERE YEAR(OrderDate) = 2013
GROUP BY MONTH(OrderDate), FORMAT(OrderDate, 'MMMM')
ORDER BY Month_Number;


-----------------------------------------------------------
-- 21. Products starting with 'Ca'
-----------------------------------------------------------
SELECT *
FROM Product
WHERE ProductName LIKE 'Ca%';


-----------------------------------------------------------
-- 22. Pattern-based product names
-----------------------------------------------------------
SELECT *
FROM Product
WHERE ProductName LIKE 'Cha_'
   OR ProductName LIKE 'Chan_';


-----------------------------------------------------------
-- 23. Suppliers with missing fax
-----------------------------------------------------------
SELECT 
    Id,
    CompanyName,
    ContactName,
    City,
    Country,
    Phone,
    CASE 
        WHEN Fax IS NULL OR Fax = '' THEN 'No Fax Number'
        ELSE Fax
    END AS Fax_Status
FROM Supplier;


-----------------------------------------------------------
-- 24. Orders with product details
-----------------------------------------------------------
SELECT 
    o.Id AS OrderId,
    o.OrderDate,
    p.ProductName,
    SUM(oi.Quantity) AS Quantity,
    SUM(p.UnitPrice) AS Price
FROM Orders o
INNER JOIN OrderItem oi
    ON o.Id = oi.OrderId
INNER JOIN Product p
    ON p.Id = oi.ProductId
GROUP BY o.Id, o.OrderDate, p.ProductName;


-----------------------------------------------------------
-- 25. Customers with no orders
-----------------------------------------------------------
SELECT c.*
FROM Customer c
LEFT JOIN Orders o
    ON c.Id = o.CustomerId
WHERE o.Id IS NULL;


-----------------------------------------------------------
-- 26. Customer & supplier country analysis
-----------------------------------------------------------
SELECT c.FirstName, c.LastName, c.Country, s.CompanyName
FROM Customer c
INNER JOIN Supplier s
    ON c.Country = s.Country;


-----------------------------------------------------------
-- 27. Customers from same city & country
-----------------------------------------------------------
SELECT 
    A.FirstName, A.LastName,
    B.FirstName, B.LastName,
    A.City, A.Country
FROM Customer A
INNER JOIN Customer B
    ON A.City = B.City
   AND A.Country = B.Country
WHERE A.Id <> B.Id;


-----------------------------------------------------------
-- 28. Combine customers & suppliers
-----------------------------------------------------------
SELECT 'Customer' AS Type,
       CONCAT(FirstName, ' ', LastName) AS Name,
       City, Country
FROM Customer

UNION ALL

SELECT 'Supplier' AS Type,
       ContactName AS Name,
       City, Country
FROM Supplier;


-----------------------------------------------------------
-- 29. Create OrdersCopy with city
-----------------------------------------------------------
SELECT o.*, c.City
INTO OrdersCopy
FROM Orders o
INNER JOIN Customer c
    ON o.CustomerId = c.Id;


-----------------------------------------------------------
-- 30. Last Paris order vs overall last order
-----------------------------------------------------------
SELECT 
    MAX(CASE WHEN c.City = 'Paris' THEN o.OrderDate END) AS Last_Paris_Order,
    MAX(o.OrderDate) AS Last_Order,
    DATEDIFF(DAY,
        MAX(CASE WHEN c.City = 'Paris' THEN o.OrderDate END),
        MAX(o.OrderDate)
    ) AS Date_Difference
FROM Orders o
JOIN Customer c
    ON o.CustomerId = c.Id;


-----------------------------------------------------------
-- 31. Customer countries without suppliers
-----------------------------------------------------------
SELECT *
FROM Customer
WHERE Country NOT IN (SELECT Country FROM Supplier);


-----------------------------------------------------------
-- 32. Customers from countries with fewest orders
-----------------------------------------------------------
SELECT c.*
FROM Customer c
WHERE c.Country IN (
    SELECT TOP 5 c.Country
    FROM Orders o
    JOIN Customer c
        ON o.CustomerId = c.Id
    GROUP BY c.Country
    ORDER BY COUNT(o.Id) ASC
);


-----------------------------------------------------------
-- 33. Orders with low quantity (<10% avg)
-----------------------------------------------------------
SELECT DISTINCT oi.OrderId
FROM OrderItem oi
JOIN (
    SELECT ProductId, AVG(Quantity) AS Avg_Qty
    FROM OrderItem
    GROUP BY ProductId
) x
    ON oi.ProductId = x.ProductId
WHERE oi.Quantity < x.Avg_Qty * 0.1;


-----------------------------------------------------------
-- 34. Customers with order amount > $7500 (2013)
-----------------------------------------------------------
SELECT 
    c.Id,
    CONCAT(c.FirstName, ' ', c.LastName) AS Customer_Name,
    SUM(oi.UnitPrice * oi.Quantity * (1 - oi.Discount)) AS Total_Amount
FROM Customer c
JOIN Orders o
    ON c.Id = o.CustomerId
JOIN OrderItem oi
    ON oi.OrderId = o.Id
WHERE YEAR(o.OrderDate) = 2013
GROUP BY c.Id, CONCAT(c.FirstName, ' ', c.LastName)
HAVING SUM(oi.UnitPrice * oi.Quantity * (1 - oi.Discount)) > 7500;


-----------------------------------------------------------
-- 35. Top 2 customers per country (by spending)
-----------------------------------------------------------
SELECT *
FROM (
    SELECT 
        c.Id,
        c.FirstName,
        c.LastName,
        c.Country,
        SUM(oi.UnitPrice * oi.Quantity * (1 - oi.Discount)) AS Total_Amount,
        DENSE_RANK() OVER (
            PARTITION BY c.Country
            ORDER BY SUM(oi.UnitPrice * oi.Quantity * (1 - oi.Discount)) DESC
        ) AS Rank_Num
    FROM Customer c
    JOIN Orders o
        ON c.Id = o.CustomerId
    JOIN OrderItem oi
        ON oi.OrderId = o.Id
    GROUP BY c.Id, c.FirstName, c.LastName, c.Country
) x
WHERE Rank_Num <= 2;
