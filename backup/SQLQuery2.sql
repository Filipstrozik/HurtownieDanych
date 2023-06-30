--lista 4
CREATE SCHEMA STROZIK;
GO

--2.1
CREATE TABLE STROZIK.DIM_CUSTOMER 
(
	CustomerID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(8),
	City NVARCHAR(30) NOT NULL,
	TerritoryName NVARCHAR(50) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	[Group] NVARCHAR(50) NOT NULL
);
GO

--2.2
CREATE TABLE STROZIK.DIM_PRODUCT
(
	ProduktID INT NOT NULL PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	ListPrice MONEY NOT NULL,
	Color NVARCHAR(15),
	SubCategoryName NVARCHAR(50),
	CategoryName NVARCHAR(50),
	Weight DECIMAL(8,2),
	Size NVARCHAR(5),
	IsPurchased BIT
);
GO

--2.3
CREATE TABLE STROZIK.DIM_SALESPERSON
(
	SalesPersonID INT NOT NULL PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(8),
	Gender NCHAR(1),
	CountryRegionCode NVARCHAR(3),
	[Group] NVARCHAR(50)
);
GO

--2.4
CREATE TABLE STROZIK.FACT_SALES 
(
	ProductID INT NOT NULL,
	CustomerID INT NOT NULL,
    SalesPersonID INT,
	OrderDate DATETIME NOT NULL,
    ShipDate DATETIME NOT NULL,
    OrderQty INT NOT NULL,
	UnitPrice MONEY NOT NULL,
	UnitPriceDiscount MONEY NOT NULL,
	LineTotal NUMERIC(38, 6) NOT NULL
);
GO

--3.1
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER ON
INSERT INTO 
	STROZIK.DIM_CUSTOMER (
    CustomerID,
    FirstName,
    LastName,
    Title,
    City,
    TerritoryName,
    CountryRegionCode,
    [Group]
)
SELECT
	DISTINCT C.CustomerID,
	P.FirstName, 
	P.LastName, 
	P.Title, 
	A.City, 
	T.[Name], 
	T.CountryRegionCode, 
	T.[Group]
FROM Sales.Customer C JOIN Person.Person P on C.PersonId = P.BusinessEntityID
 JOIN Sales.SalesTerritory T on C.TerritoryID = T.TerritoryID
 JOIN Sales.SalesOrderHeader H on C.CustomerID = H.CustomerID
 JOIN Person.Address A on A.AddressID=H.ShipToAddressID;
GO
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER OFF;

SELECT * FROM STROZIK.DIM_CUSTOMER;

SELECT COUNT(*) FROM STROZIK.DIM_CUSTOMER;
SELECT COUNT(*) FROM Sales.Customer;

--dobre
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER ON;

INSERT INTO STROZIK.DIM_CUSTOMER (
    CustomerID,
    FirstName,
    LastName,
    Title,
    City,
    TerritoryName,
    CountryRegionCode,
    [Group]
)
SELECT DISTINCT
    C.CustomerID,
    P.FirstName, 
    P.LastName, 
    P.Title, 
    A.City, 
    T.[Name], 
    T.CountryRegionCode, 
    T.[Group]
FROM 
    Sales.Customer C 
    JOIN Person.Person P ON C.PersonId = P.BusinessEntityID
    JOIN Sales.SalesTerritory T ON C.TerritoryID = T.TerritoryID
    JOIN Sales.SalesOrderHeader H ON C.CustomerID = H.CustomerID
    JOIN Person.Address A ON A.AddressID = H.ShipToAddressID;
    
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER OFF;



SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER OFF;
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER ON;
INSERT INTO 
	STROZIK.DIM_CUSTOMER
SELECT
	C.CustomerID,
	PER.FirstName, 
	PER.LastName, 
	PER.Title, 
	ADR.City, 
	CR.[Name], 
	SP.CountryRegionCode, 
	ST.[Group]
FROM Sales.Customer C 
JOIN Person.Person PER ON C.PersonID = PER.BusinessEntityID
JOIN Person.BusinessEntityAddress BEA ON C.CustomerID = BEA.BusinessEntityID
JOIN Person.[Address] ADR ON BEA.AddressID = ADR.AddressID
JOIN Person.StateProvince SP ON ADR.StateProvinceID = SP.StateProvinceID
JOIN Person.CountryRegion CR ON SP.CountryRegionCode = CR.CountryRegionCode
JOIN Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID
GO




SELECT * FROM [Sales].[vIndividualCustomer] WHERE BusinessEntityID = 11072;

SELECT * FROM Sales.Customer WHERE CustomerID = 11072;

	C.CustomerID,
	PER.FirstName, 
	PER.LastName, 
	PER.Title, 
	ADR.City, 
	CR.[Name], 
	SP.CountryRegionCode, 
	ST.[Group]

SELECT 
	C.CustomerID,
	PER.FirstName, 
	PER.LastName, 
	PER.Title, 
	ADR.*, 
	BEA.*,
	CR.[Name], 
	SP.CountryRegionCode, 
	ST.[Group]
FROM Sales.Customer C 
JOIN Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID
JOIN Person.Person PER ON C.PersonID = PER.BusinessEntityID
JOIN Person.BusinessEntityAddress BEA ON C.CustomerID = BEA.BusinessEntityID
JOIN Person.[Address] ADR ON BEA.AddressID = ADR.AddressID
JOIN Person.StateProvince SP ON ADR.StateProvinceID = SP.StateProvinceID
JOIN Person.CountryRegion CR ON SP.CountryRegionCode = CR.CountryRegionCode
WHERE CustomerID = 11072
ORDER BY C.CustomerID;
GO




SELECT COUNT(*) FROM STROZIK.DIM_CUSTOMER;
GO

SELECT * FROM Sales.Customer;

--3.2
INSERT INTO 
	STROZIK.DIM_PRODUCT
SELECT 
    p.ProductID, 
	p.Name, 
	p.ListPrice, 
	p.Color, 
	sc.Name, 
    c.Name,
	p.Weight, 
	p.Size, 
	~p.MakeFlag
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID;

SELECT * FROM STROZIK.DIM_PRODUCT;

SELECT COUNT(*) FROM STROZIK.DIM_PRODUCT;

SELECT COUNT(*) FROM Production.Product p;

--3.3
INSERT INTO STROZIK.DIM_SALESPERSON
SELECT SP.BusinessEntityID, FirstName, LastName, Title, Gender, CountryRegionCode, [Group]
FROM Sales.SalesPerson SP
JOIN HumanResources.Employee E ON E.BusinessEntityID = SP.BusinessEntityID
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
LEFT JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID;


SELECT * FROM STROZIK.DIM_SALESPERSON;

SELECT * FROM STROZIK.DIM_SALESPERSON_2;

SELECT * FROM Sales.SalesPerson;

SELECT COUNT(*) FROM Sales.SalesPerson;
SELECT COUNT(*) FROM STROZIK.DIM_SALESPERSON;

--3.4
INSERT INTO STROZIK.FACT_SALES
SELECT 
	DISTINCT
	SOD.ProductID,
	SOH.CustomerID,
	SOH.SalesPersonID,
	SOH.OrderDate,
	SOH.ShipDate,
	SOD.OrderQty,
	SOD.UnitPrice,
	SOD.UnitPriceDiscount,
	SOD.LineTotal
FROM Sales.SalesOrderHeader SOH
LEFT JOIN Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID;

SELECT * FROM STROZIK.FACT_SALES;
SELECT COUNT(*) FROM Sales.SalesOrderHeader SOH LEFT JOIN Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID;
SELECT COUNT(*) FROM STROZIK.FACT_SALES;

--4.1

ALTER TABLE STROZIK.DIM_CUSTOMER
ADD CONSTRAINT PK_CustomerID PRIMARY KEY CLUSTERED(CustomerID);

ALTER TABLE STROZIK.DIM_PRODUCT
ADD CONSTRAINT PK_ProductID PRIMARY KEY(ProductID);

ALTER TABLE STROZIK.DIM_SALESPERSON
ADD CONSTRAINT PK_SalesPersonID PRIMARY KEY CLUSTERED(SalesPersonID);

ALTER TABLE STROZIK.FACT_SALES
ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES STROZIK.DIM_PRODUCT(ProductID);

ALTER TABLE STROZIK.FACT_SALES
ADD CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES STROZIK.DIM_CUSTOMER(CustomerID);

ALTER TABLE STROZIK.FACT_SALES
ADD CONSTRAINT FK_SalesPersonID FOREIGN KEY (SalesPersonID) REFERENCES STROZIK.DIM_SALESPERSON(SalesPersonID);

 --dobre
ALTER TABLE STROZIK.FACT_SALES 
ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES STROZIK.DIM_PRODUCT(ProductID),
    CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES STROZIK.DIM_CUSTOMER(CustomerID),
    CONSTRAINT FK_SalesPersonID FOREIGN KEY (SalesPersonID) REFERENCES STROZIK.DIM_SALESPERSON(SalesPersonID);

ALTER TABLE STROZIK.FACT_SALES
DROP CONSTRAINT FK_ProductID, FK_CustomerID, FK_SalesPersonID;




--4.2
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER ON;
INSERT INTO STROZIK.DIM_CUSTOMER (CustomerID, FirstName, LastName, Title, City, TerritoryName, CountryRegionCode, [Group])
VALUES (11001, 'Adam', 'Kowalski', 'Pan', 'Warszawa', 'Mazowsze', 'PL', 'Mazowieckie');

INSERT INTO STROZIK.DIM_CUSTOMER (CustomerID, FirstName, LastName, Title, City, TerritoryName, CountryRegionCode, [Group])
VALUES (30119, 'Ewa', 'Nowak', 'Pani', 'Kraków', 'Małopolska', 'PL', 'Klient');

INSERT INTO STROZIK.DIM_PRODUCT (ProduktID, Name, ListPrice, Color, SubCategoryName, CategoryName, Weight, Size, IsPurchased)
VALUES (1, 'Koszula', 89.99, 'Biały', 'Odzież', 'Moda', 0.2, 'XL', 1);

INSERT INTO STROZIK.DIM_PRODUCT (ProduktID, Name, ListPrice, Color, SubCategoryName, CategoryName, Weight, Size, IsPurchased)
VALUES (1000, 'Koszula', 89.99, 'Biały', 'Odzież', 'Moda', 0.2, 'XL', 1);

INSERT INTO STROZIK.DIM_SALESPERSON (SalesPersonID, FirstName, LastName, Title, Gender, CountryRegionCode, [Group])
VALUES (1, 'Filip', 'Strózik', 'Pan', 'M', 'PL','Dolnysląsk');



--lista5


CREATE TABLE STROZIK.months_names (
  month_number INTEGER,
  month_name VARCHAR(20)
);

INSERT INTO STROZIK.months_names (month_number, month_name)
VALUES (1, 'Styczeń'),
       (2, 'Luty'),
       (3, 'Marzec'),
       (4, 'Kwiecień'),
       (5, 'Maj'),
       (6, 'Czerwiec'),
       (7, 'Lipiec'),
       (8, 'Sierpień'),
       (9, 'Wrzesień'),
       (10, 'Październik'),
       (11, 'Listopad'),
       (12, 'Grudzień');

SELECT * FROM STROZIK.months_names;

CREATE TABLE STROZIK.weekday_names (
  weekday_number INTEGER,
  day_name VARCHAR(20)
);

INSERT INTO STROZIK.weekday_names (weekday_number, day_name)
VALUES (1, 'Poniedziałek'),
       (2, 'Wtorek'),
       (3, 'Środa'),
       (4, 'Czwartek'),
       (5, 'Piątek'),
       (6, 'Sobota'),
       (7, 'Niedziela');

SELECT * FROM STROZIK.weekday_names;


CREATE TABLE STROZIK.DIM_TIME (
	PK_TIME DATETIME PRIMARY KEY,
	Rok INT,
	Kwartal INT,
	Miesiac INT,
	Miesiac_slownie VARCHAR(20),
	Dzien_tyg_slownie VARCHAR(20),
	Dzien_miesiaca INT
);

INSERT INTO STROZIK.DIM_TIME
SELECT DISTINCT
	OrderDate AS PK_TIME,
    YEAR(OrderDate) AS Rok,
    DATEPART(Q, OrderDate) AS Kwartal,
    MONTH(OrderDate) AS Miesiac,
	mn.month_name AS Miesiac_slownie,
	wdn.day_name AS Dzien_tyg_slownie,
    DAY(OrderDate) AS Dzien_miesiaca
FROM STROZIK.FACT_SALES 
	JOIN STROZIK.weekday_names wdn 
	ON DATEPART(DW, OrderDate) = wdn.weekday_number
	JOIN STROZIK.months_names mn
	ON MONTH(OrderDate) = mn.month_number;

SELECT * FROM STROZIK.DIM_TIME;

ALTER TABLE STROZIK.FACT_SALES
ADD CONSTRAINT FK_TIMEID FOREIGN KEY (OrderDate) REFERENCES STROZIK.DIM_TIME(PK_TIME);

ALTER TABLE STROZIK.FACT_SALES
DROP CONSTRAINT FK_ProductID;

ALTER TABLE STROZIK.FACT_SALES
ADD CONSTRAINT FK_ProduktID FOREIGN KEY (ProductID) REFERENCES STROZIK.DIM_PRODUCT(ProductID);


-----------------------------------------------------------------------------------------------lista 6

-- zad 1.
DROP TABLE IF EXISTS STROZIK.FACT_SALES;

DROP TABLE IF EXISTS STROZIK.DIM_PRODUCT;

DROP TABLE IF EXISTS STROZIK.DIM_CUSTOMER;

DROP TABLE IF EXISTS STROZIK.DIM_SALESPERSON;

DROP TABLE IF EXISTS STROZIK.DIM_TIME;

DROP TABLE IF EXISTS STROZIK.months_names;

DROP TABLE IF EXISTS STROZIK.weekday_names;

DROP SCHEMA IF EXISTS STROZIK;


-- zad 2.

UPDATE STROZIK.DIM_PRODUCT
SET Color = 'Unknown'
WHERE Color IS NULL;

SELECT * FROM STROZIK.DIM_PRODUCT;

UPDATE STROZIK.DIM_PRODUCT
SET SubCategoryName = 'Unknown'
WHERE SubCategoryName IS NULL;

SELECT * FROM STROZIK.DIM_PRODUCT;

UPDATE STROZIK.DIM_CUSTOMER
SET CountryRegionCode = '000'
WHERE CountryRegionCode IS NULL;

SELECT * FROM STROZIK.DIM_CUSTOMER;

UPDATE STROZIK.DIM_SALESPERSON
SET CountryRegionCode = '000'
WHERE CountryRegionCode IS NULL;

SELECT * FROM STROZIK.DIM_SALESPERSON;


UPDATE STROZIK.DIM_CUSTOMER
SET [Group] = 'Unknown'
WHERE [Group] IS NULL;

SELECT * FROM STROZIK.DIM_CUSTOMER;

UPDATE STROZIK.DIM_SALESPERSON
SET [Group] = 'Unknown'
WHERE [Group] IS NULL;

SELECT * FROM STROZIK.DIM_SALESPERSON;

--zad3
CREATE TABLE STROZIK.ETL_LOG
(
    LogID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ProcessID UNIQUEIDENTIFIER NOT NULL, 
    ExecDayTime DATETIME NOT NULL, 
    ExecStatus INT NOT NULL
);


-- to co wklejam do ETL'a



CREATE TABLE STROZIK.DIM_CUSTOMER 
(
	CustomerID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(8),
	City NVARCHAR(30) NOT NULL,
	TerritoryName NVARCHAR(50) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	[Group] NVARCHAR(50) NOT NULL
);
GO

--2.2
CREATE TABLE STROZIK.DIM_PRODUCT
(
	ProductID INT NOT NULL PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	ListPrice MONEY NOT NULL,
	Color NVARCHAR(15),
	SubCategoryName NVARCHAR(50),
	CategoryName NVARCHAR(50),
	Weight DECIMAL(8,2),
	Size NVARCHAR(5),
	IsPurchased BIT
);
GO

--2.3
CREATE TABLE STROZIK.DIM_SALESPERSON
(
	SalesPersonID INT NOT NULL PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(8),
	Gender NCHAR(1),
	CountryRegionCode NVARCHAR(3),
	[Group] NVARCHAR(50)
);
GO


--2.4
CREATE TABLE STROZIK.FACT_SALES 
(
	ProductID INT NOT NULL,
	CustomerID INT NOT NULL,
    SalesPersonID INT,
	OrderDate INT NOT NULL,
    ShipDate INT NOT NULL,
    OrderQty INT NOT NULL,
	UnitPrice MONEY NOT NULL,
	UnitPriceDiscount MONEY NOT NULL,
	LineTotal NUMERIC(38, 6) NOT NULL
);
GO

CREATE TABLE STROZIK.DIM_TIME (
	PK_TIME INT PRIMARY KEY,
	Rok INT,
	Kwartal INT,
	Miesiac INT,
	Miesiac_slownie VARCHAR(20),
	Dzien_tyg_slownie VARCHAR(20),
	Dzien_miesiaca INT
);
GO

-- insert data
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER ON
INSERT INTO 
	STROZIK.DIM_CUSTOMER (
    CustomerID,
    FirstName,
    LastName,
    Title,
    City,
    TerritoryName,
    CountryRegionCode,
    [Group]
)
SELECT
	DISTINCT C.CustomerID,
	P.FirstName, 
	P.LastName, 
	P.Title, 
	A.City, 
	T.[Name], 
	T.CountryRegionCode, 
	T.[Group]
FROM Sales.Customer C JOIN Person.Person P on C.PersonId = P.BusinessEntityID
 JOIN Sales.SalesTerritory T on C.TerritoryID = T.TerritoryID
 JOIN Sales.SalesOrderHeader H on C.CustomerID = H.CustomerID
 JOIN Person.Address A on A.AddressID=H.ShipToAddressID;
GO
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER OFF;

INSERT INTO 
	STROZIK.DIM_PRODUCT
SELECT 
    p.ProductID, 
	p.Name, 
	p.ListPrice, 
	p.Color, 
	sc.Name, 
    c.Name,
	p.Weight, 
	p.Size, 
	~p.MakeFlag
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID;

INSERT INTO STROZIK.DIM_SALESPERSON
SELECT SP.BusinessEntityID, FirstName, LastName, Title, Gender, CountryRegionCode, [Group]
FROM Sales.SalesPerson SP
JOIN HumanResources.Employee E ON E.BusinessEntityID = SP.BusinessEntityID
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
LEFT JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID;


INSERT INTO STROZIK.FACT_SALES
SELECT 
	DISTINCT
	SOD.ProductID,
	SOH.CustomerID,
	SOH.SalesPersonID,
	YEAR(SOH.OrderDate) * 10000 + MONTH(SOH.OrderDate) * 100 + DAY(SOH.OrderDate),
	YEAR(SOH.ShipDate) * 10000 + MONTH(SOH.ShipDate) * 100 + DAY(SOH.ShipDate),
	SOD.OrderQty,
	SOD.UnitPrice,
	SOD.UnitPriceDiscount,
	SOD.LineTotal
FROM Sales.SalesOrderHeader SOH
LEFT JOIN Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID;

INSERT INTO STROZIK.DIM_TIME
SELECT DISTINCT
	YEAR(SOH.OrderDate) * 10000 + MONTH(SOH.OrderDate) * 100 + DAY(SOH.OrderDate) AS PK_TIME,
    YEAR(SOH.OrderDate) AS Rok,
    DATEPART(Q, SOH.OrderDate) AS Kwartal,
    MONTH(SOH.OrderDate) AS Miesiac,
	mn.month_name AS Miesiac_slownie,
	wdn.day_name AS Dzien_tyg_slownie,
    DAY(SOH.OrderDate) AS Dzien_miesiaca
FROM Sales.SalesOrderHeader SOH 
	JOIN STROZIK.weekday_names wdn 
	ON DATEPART(DW, OrderDate) = wdn.weekday_number
	JOIN STROZIK.months_names mn
	ON MONTH(OrderDate) = mn.month_number;


-- koniec list 6



SELECT * FROM dbo.sysssislog;


DROP TABLE dbo.sysssislog;


DROP TABLE STROZIK.ETL_LOG;


SET IDENTITY_INSERT ETL_LOG OFF;

WITH ETL_LOGHelper (sourceid, endtime, datacode)  
AS (SELECT DISTINCT sourceid, endtime, datacode
	FROM dbo.sysssislog  syslog LEFT JOIN STROZIK.ETL_LOG etllog on syslog.id = etllog.LogID
	WHERE etllog.ProcessID is null)
INSERT INTO STROZIK.ETL_LOG(ProcessID,ExecDayTime,ExecStatus)
Select * From ETL_LOGHelper;

INSERT INTO STROZIK.ETL_LOG(ProcessID,ExecDayTime,ExecStatus)
SELECT DISTINCT sourceid, endtime, datacode
FROM dbo.sysssislog  syslog LEFT JOIN STROZIK.ETL_LOG etllog on syslog.id = etllog.LogID
	WHERE etllog.ProcessID is null;



SELECT * FROM STROZIK.ETL_LOG;


--- symulacja etl:

DROP TABLE IF EXISTS STROZIK.FACT_SALES;

DROP TABLE IF EXISTS STROZIK.DIM_PRODUCT;

DROP TABLE IF EXISTS STROZIK.DIM_CUSTOMER;

DROP TABLE IF EXISTS STROZIK.DIM_SALESPERSON;

DROP TABLE IF EXISTS STROZIK.DIM_TIME;

DROP TABLE IF EXISTS STROZIK.months_names;

DROP TABLE IF EXISTS STROZIK.weekday_names;

CREATE TABLE STROZIK.DIM_CUSTOMER 
(
	CustomerID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(8),
	City NVARCHAR(30) NOT NULL,
	TerritoryName NVARCHAR(50) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL,
	[Group] NVARCHAR(50) NOT NULL
);

CREATE TABLE STROZIK.DIM_PRODUCT
(
	ProductID INT NOT NULL PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	ListPrice MONEY NOT NULL,
	Color NVARCHAR(15),
	SubCategoryName NVARCHAR(50),
	CategoryName NVARCHAR(50),
	Weight DECIMAL(8,2),
	Size NVARCHAR(5),
	IsPurchased BIT
);

CREATE TABLE STROZIK.DIM_SALESPERSON
(
	SalesPersonID INT NOT NULL PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(8),
	Gender NCHAR(1),
	CountryRegionCode NVARCHAR(3),
	[Group] NVARCHAR(50)
);

CREATE TABLE STROZIK.FACT_SALES 
(
	ProductID INT NOT NULL,
	CustomerID INT NOT NULL,
    SalesPersonID INT,
	OrderDate INT NOT NULL,
    ShipDate INT NOT NULL,
    OrderQty INT NOT NULL,
	UnitPrice MONEY NOT NULL,
	UnitPriceDiscount MONEY NOT NULL,
	LineTotal NUMERIC(38, 6) NOT NULL
);


CREATE TABLE STROZIK.DIM_TIME (
	PK_TIME INT PRIMARY KEY,
	Rok INT,
	Kwartal INT,
	Miesiac INT,
	Miesiac_slownie VARCHAR(20),
	Dzien_tyg_slownie VARCHAR(20),
	Dzien_miesiaca INT
);


CREATE TABLE STROZIK.months_names (
  month_number INTEGER,
  month_name VARCHAR(20)
);

INSERT INTO STROZIK.months_names (month_number, month_name)
VALUES (1, 'Styczeń'),
       (2, 'Luty'),
       (3, 'Marzec'),
       (4, 'Kwiecień'),
       (5, 'Maj'),
       (6, 'Czerwiec'),
       (7, 'Lipiec'),
       (8, 'Sierpień'),
       (9, 'Wrzesień'),
       (10, 'Październik'),
       (11, 'Listopad'),
       (12, 'Grudzień');


CREATE TABLE STROZIK.weekday_names (
  weekday_number INTEGER,
  day_name VARCHAR(20)
);

INSERT INTO STROZIK.weekday_names (weekday_number, day_name)
VALUES (1, 'Poniedziałek'),
       (2, 'Wtorek'),
       (3, 'Środa'),
       (4, 'Czwartek'),
       (5, 'Piątek'),
       (6, 'Sobota'),
       (7, 'Niedziela');
---


-- insert data
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER ON
INSERT INTO 
	STROZIK.DIM_CUSTOMER (
    CustomerID,
    FirstName,
    LastName,
    Title,
    City,
    TerritoryName,
    CountryRegionCode,
    [Group]
)
SELECT
	DISTINCT C.CustomerID,
	P.FirstName, 
	P.LastName, 
	P.Title, 
	A.City, 
	T.[Name], 
	T.CountryRegionCode, 
	T.[Group]
FROM Sales.Customer C JOIN Person.Person P on C.PersonId = P.BusinessEntityID
 JOIN Sales.SalesTerritory T on C.TerritoryID = T.TerritoryID
 JOIN Sales.SalesOrderHeader H on C.CustomerID = H.CustomerID
 JOIN Person.Address A on A.AddressID=H.ShipToAddressID;
GO
SET IDENTITY_INSERT STROZIK.DIM_CUSTOMER OFF;

INSERT INTO 
	STROZIK.DIM_PRODUCT
SELECT 
    p.ProductID, 
	p.Name, 
	p.ListPrice, 
	p.Color, 
	sc.Name, 
    c.Name,
	p.Weight, 
	p.Size, 
	~p.MakeFlag
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID;

INSERT INTO STROZIK.DIM_SALESPERSON
SELECT SP.BusinessEntityID, FirstName, LastName, Title, Gender, CountryRegionCode, [Group]
FROM Sales.SalesPerson SP
JOIN HumanResources.Employee E ON E.BusinessEntityID = SP.BusinessEntityID
JOIN Person.Person P ON E.BusinessEntityID = P.BusinessEntityID
LEFT JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID;


INSERT INTO STROZIK.FACT_SALES
SELECT 
	DISTINCT
	SOD.ProductID,
	SOH.CustomerID,
	SOH.SalesPersonID,
	YEAR(SOH.OrderDate) * 10000 + MONTH(SOH.OrderDate) * 100 + DAY(SOH.OrderDate),
	YEAR(SOH.ShipDate) * 10000 + MONTH(SOH.ShipDate) * 100 + DAY(SOH.ShipDate),
	SOD.OrderQty,
	SOD.UnitPrice,
	SOD.UnitPriceDiscount,
	SOD.LineTotal
FROM Sales.SalesOrderHeader SOH
LEFT JOIN Sales.SalesOrderDetail SOD ON SOD.SalesOrderID = SOH.SalesOrderID;

INSERT INTO STROZIK.DIM_TIME
SELECT DISTINCT
	YEAR(SOH.OrderDate) * 10000 + MONTH(SOH.OrderDate) * 100 + DAY(SOH.OrderDate) AS PK_TIME,
    YEAR(SOH.OrderDate) AS Rok,
    DATEPART(Q, SOH.OrderDate) AS Kwartal,
    MONTH(SOH.OrderDate) AS Miesiac,
	mn.month_name AS Miesiac_slownie,
	wdn.day_name AS Dzien_tyg_slownie,
    DAY(SOH.OrderDate) AS Dzien_miesiaca
FROM Sales.SalesOrderHeader SOH 
	JOIN STROZIK.weekday_names wdn 
	ON DATEPART(DW, OrderDate) = wdn.weekday_number
	JOIN STROZIK.months_names mn
	ON MONTH(OrderDate) = mn.month_number;



ALTER TABLE STROZIK.DIM_CUSTOMER
ADD CONSTRAINT PK_CustomerID PRIMARY KEY CLUSTERED(CustomerID);

ALTER TABLE STROZIK.DIM_PRODUCT
ADD CONSTRAINT PK_ProductID PRIMARY KEY(ProductID);

ALTER TABLE STROZIK.DIM_SALESPERSON
ADD CONSTRAINT PK_SalesPersonID PRIMARY KEY CLUSTERED(SalesPersonID);

ALTER TABLE STROZIK.FACT_SALES
ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES STROZIK.DIM_PRODUCT(ProductID);

ALTER TABLE STROZIK.FACT_SALES
ADD CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES STROZIK.DIM_CUSTOMER(CustomerID);

ALTER TABLE STROZIK.FACT_SALES
ADD CONSTRAINT FK_SalesPersonID FOREIGN KEY (SalesPersonID) REFERENCES STROZIK.DIM_SALESPERSON(SalesPersonID);

 --dobre
ALTER TABLE STROZIK.FACT_SALES 
ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES STROZIK.DIM_PRODUCT(ProductID),
    CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES STROZIK.DIM_CUSTOMER(CustomerID),
    CONSTRAINT FK_SalesPersonID FOREIGN KEY (SalesPersonID) REFERENCES STROZIK.DIM_SALESPERSON(SalesPersonID),
	CONSTRAINT FK_TIMEID FOREIGN KEY (OrderDate) REFERENCES STROZIK.DIM_TIME(PK_TIME);

UPDATE STROZIK.DIM_PRODUCT SET Color='Unknown' WHERE Color IS NULL;
UPDATE STROZIK.DIM_PRODUCT SET SubCategoryName='Unknown' WHERE SubCategoryName IS NULL;
UPDATE STROZIK.DIM_PRODUCT SET CategoryName='Unknown' WHERE CategoryName IS NULL;


UPDATE STROZIK.DIM_CUSTOMER SET FirstName='Unknown' WHERE FirstName IS NULL;
UPDATE STROZIK.DIM_CUSTOMER SET LastName='Unknown' WHERE LastName IS NULL;
UPDATE STROZIK.DIM_CUSTOMER SET Title='Unknown' WHERE Title IS NULL;
UPDATE STROZIK.DIM_CUSTOMER SET City='Unknown' WHERE City IS NULL;
UPDATE STROZIK.DIM_CUSTOMER SET TerritoryName='Unknown' WHERE TerritoryName IS NULL;
UPDATE STROZIK.DIM_CUSTOMER SET [Group]='Unknown' WHERE [Group] IS NULL;
UPDATE STROZIK.DIM_CUSTOMER SET CountryRegionCode='000' WHERE CountryRegionCode IS NULL;


UPDATE STROZIK.DIM_SALESPERSON SET Title='Unknown' WHERE Title IS NULL;
UPDATE STROZIK.DIM_SALESPERSON SET [Group]='Unknown' WHERE [Group] IS NULL;
UPDATE STROZIK.DIM_SALESPERSON SET CountryRegionCode='000' WHERE CountryRegionCode IS NULL;






SELECT * FROM STROZIK.DIM_PRODUCT;
SELECT * FROM STROZIK.DIM_CUSTOMER;
SELECT * FROM STROZIK.DIM_SALESPERSON;