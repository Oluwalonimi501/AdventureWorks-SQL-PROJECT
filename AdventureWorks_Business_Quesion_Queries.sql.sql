USE adventureworks;

-- QUESTION 1: Which customers have placed sales orders, and what are their order dates and total amounts due?
SELECT
    C.CustomerID,
    P.FirstName,
    P.LastName,
    SOH.SalesOrderID,
    SOH.OrderDate,
    SOH.TotalDue
FROM sales_customer AS C
INNER JOIN sales_salesorderheader AS SOH
    ON C.CustomerID = SOH.CustomerID
LEFT JOIN person_person AS P
    ON C.PersonID = P.BusinessEntityID
ORDER BY C.CustomerID, SOH.OrderDate;

-- QUESTION 2: Which products were included in each sales order, and what quantity, unit price, and line total were recorded?
SELECT
    SOD.SalesOrderID,
    P.ProductID,
    P.Name AS ProductName,
    SOD.OrderQty,
    SOD.UnitPrice,
    SOD.LineTotal
FROM sales_salesorderdetail AS SOD
INNER JOIN production_product AS P
    ON SOD.ProductID = P.ProductID
ORDER BY SOD.SalesOrderID, P.Name;USE adventureworks;

-- QUESTION 3: Which products are in the product catalogue, including products that have not been assigned to a subcategory?
SELECT
    SOD.SalesOrderID,
    P.ProductID,
    P.Name AS ProductName,
    SOD.OrderQty,
    SOD.UnitPrice,
    SOD.LineTotal
FROM sales_salesorderdetail AS SOD
INNER JOIN production_product AS P
    ON SOD.ProductID = P.ProductID
ORDER BY SOD.SalesOrderID, P.Name;

-- QUESTION 4: Which product subcategories exist, including subcategories that currently have no products assigned to them?
SELECT
    P.ProductID,
    P.Name AS ProductName,
    P.ProductNumber,
    P.ProductSubcategoryID,
    PSC.Name AS SubcategoryName
FROM production_product AS P
LEFT JOIN production_productsubcategory AS PSC
    ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
ORDER BY P.ProductID;

-- QUESTION 5: How can the product category and subcategory lists be reconciled to show all records, even where there is no match?
SELECT
    PC.ProductCategoryID,
    PC.Name AS CategoryName,
    PSC.ProductSubcategoryID,
    PSC.Name AS SubcategoryName
FROM production_productcategory AS PC
LEFT JOIN production_productsubcategory AS PSC
    ON PC.ProductCategoryID = PSC.ProductCategoryID
UNION
SELECT
    PC.ProductCategoryID,
    PC.Name AS CategoryName,
    PSC.ProductSubcategoryID,
    PSC.Name AS SubcategoryName
FROM production_productcategory AS PC
RIGHT JOIN production_productsubcategory AS PSC
    ON PC.ProductCategoryID = PSC.ProductCategoryID
ORDER BY ProductCategoryID, ProductSubcategoryID;

-- QUESTION 6: Which vendors supply each product, and what are their standard prices and average lead times?
SELECT
    P.ProductID,
    P.Name AS ProductName,
    COUNT(DISTINCT V.BusinessEntityID) AS TotalVendors,
    MIN(PV.StandardPrice) AS CheapestPrice,
    AVG(PV.StandardPrice) AS AvgPrice,
    AVG(PV.AverageLeadTime) AS AvgLeadTimeDays
FROM production_product AS P
INNER JOIN purchasing_productvendor AS PV
    ON P.ProductID = PV.ProductID
INNER JOIN purchasing_vendor AS V
    ON PV.BusinessEntityID = V.BusinessEntityID
GROUP BY P.ProductID, P.Name
ORDER BY P.ProductID;

-- QUESTION 7: Which employees created purchase orders, which vendors received them, and what was the total due for each order?
SELECT
    POH.PurchaseOrderID,
    POH.OrderDate,
    POH.EmployeeID,
    P.FirstName AS EmployeeFirstName,
    P.LastName AS EmployeeLastName,
    E.JobTitle,
    POH.VendorID,
    V.Name AS VendorName,
    POH.TotalDue
FROM purchasing_purchaseorderheader AS POH
INNER JOIN purchasing_vendor AS V
    ON POH.VendorID = V.BusinessEntityID
LEFT JOIN humanresources_employee AS E
    ON POH.EmployeeID = E.BusinessEntityID
LEFT JOIN person_person AS P
    ON E.BusinessEntityID = P.BusinessEntityID
ORDER BY POH.PurchaseOrderID;

-- QUESTION 8: What are all possible department-and-shift combinations that could be considered when planning employee shift coverage?
SELECT
    D.DepartmentID,
    D.Name AS DepartmentName,
    S.ShiftID,
    S.Name AS ShiftName,
    S.StartTime,
    S.EndTime
FROM humanresources_department AS D
CROSS JOIN humanresources_shift AS S
ORDER BY D.DepartmentID, S.ShiftID;

-- QUESTION 9: Which employees report directly to which managers in the organisation hierarchy?
SELECT
    E.BusinessEntityID AS EmployeeID,
    P.FirstName AS EmployeeFirstName,
    P.LastName AS EmployeeLastName,
    E.JobTitle AS EmployeeJobTitle,
    M.BusinessEntityID AS ManagerID,
    MP.FirstName AS ManagerFirstName,
    MP.LastName AS ManagerLastName,
    M.JobTitle AS ManagerJobTitle
FROM humanresources_employee AS E
LEFT JOIN humanresources_employee AS M
    ON E.OrganizationNode LIKE CONCAT(M.OrganizationNode, '%')
    AND M.OrganizationLevel = E.OrganizationLevel - 1
    AND M.BusinessEntityID <> E.BusinessEntityID
LEFT JOIN person_person AS P
    ON E.BusinessEntityID = P.BusinessEntityID
LEFT JOIN person_person AS MP
    ON M.BusinessEntityID = MP.BusinessEntityID
ORDER BY M.BusinessEntityID, E.BusinessEntityID;

-- QUESTION 10: What sales reasons are associated with each sales order, including orders without recorded sales reasons?
SELECT
    SOH.SalesOrderID,
    SOH.OrderDate,
    SOH.TotalDue,
    SR.SalesReasonID,
    SR.Name AS SalesReasonName,
    SR.ReasonType
FROM sales_salesorderheader AS SOH
LEFT JOIN sales_salesorderheadersalesreason AS SOHSR
    ON SOH.SalesOrderID = SOHSR.SalesOrderID
LEFT JOIN sales_salesreason AS SR
    ON SOHSR.SalesReasonID = SR.SalesReasonID
ORDER BY SOH.SalesOrderID, SR.Name;

-- QUESTION 11: Which products have a list price higher than the average list price of all products?
SELECT
    ProductID,
    Name AS ProductName,
    ProductNumber,
    ListPrice
FROM production_product
WHERE ListPrice > (
    SELECT AVG(ListPrice)
    FROM production_product
)
ORDER BY ListPrice DESC;

-- QUESTION 12: Which customers have placed at least one sales order?
SELECT
    CustomerID,
    PersonID,
    StoreID,
    TerritoryID
FROM sales_customer
WHERE CustomerID IN (
    SELECT CustomerID
    FROM sales_salesorderheader
)
ORDER BY CustomerID;

-- QUESTION 13: Which products have never appeared in any sales order?
SELECT
    ProductID,
    Name AS ProductName,
    ProductNumber,
    ListPrice
FROM production_product AS P
WHERE NOT EXISTS (
    SELECT 1
    FROM sales_salesorderdetail AS SOD
    WHERE SOD.ProductID = P.ProductID
)
ORDER BY ProductID;

-- QUESTION 14: Which salespeople have year-to-date sales greater than the average year-to-date sales of all salespeople?
SELECT
    BusinessEntityID AS SalesPersonID,
    TerritoryID,
    SalesQuota,
    SalesYTD
FROM sales_salesperson
WHERE SalesYTD > (
    SELECT AVG(SalesYTD)
    FROM sales_salesperson
)
ORDER BY SalesYTD DESC;

-- QUESTION 15: Which vendors have received more purchase orders than the average number of purchase orders per vendor?
SELECT
    V.BusinessEntityID AS VendorID,
    V.Name AS VendorName,
    COUNT(POH.PurchaseOrderID) AS TotalPurchaseOrders
FROM purchasing_vendor AS V
JOIN purchasing_purchaseorderheader AS POH
    ON V.BusinessEntityID = POH.VendorID
GROUP BY V.BusinessEntityID, V.Name
HAVING COUNT(POH.PurchaseOrderID) > (
    SELECT AVG(OrderCount)
    FROM (
        SELECT COUNT(*) AS OrderCount
        FROM purchasing_purchaseorderheader
        GROUP BY VendorID
    ) AS VendorCounts
)
ORDER BY TotalPurchaseOrders DESC;