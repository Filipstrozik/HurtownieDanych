--zad1
CREATE TABLE Sprzedaz (
    pracID INT,
    prodID INT,
    "Nazwa produktu" VARCHAR(255),
    Rok INT,
    Liczba INT,
	PRIMARY KEY (pracID, prodId, Rok)
);

INSERT INTO [dbo].[Sprzedaz]
SELECT 
    sp.BusinessEntityID,
	prod.ProductID, 
	prod.Name,
	YEAR(soh.OrderDate),
	SUM(sod.OrderQty)
FROM 
    Sales.SalesPerson sp
    JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	JOIN Production.Product prod ON sod.ProductID = prod.ProductID
GROUP BY 
    sp.BusinessEntityID, prod.ProductID, prod.Name, YEAR(soh.OrderDate);

SELECT * FROM Sprzedaz;
DROP TABLE Sprzedaz;

--1a


DECLARE @cols NVARCHAR (MAX);
SELECT @cols = COALESCE (@cols + ',[' + CAST(rok AS VARCHAR) + '] INT', 
               '[' + CAST(rok AS VARCHAR) + '] INT')
               FROM (SELECT DISTINCT YEAR(OrderDate) AS rok FROM [Sales].[SalesOrderHeader]) PV
			   ORDER BY rok

DECLARE @query NVARCHAR(MAX)
SET @query = '
CREATE TABLE Sprzedaz (
    pracID INT,
    prodID INT,
    [Nazwa produktu] VARCHAR(255),
	' + @cols + ' 
    PRIMARY KEY (pracID, prodId)
);'

EXEC SP_EXECUTESQL @query;


DECLARE @cols2 NVARCHAR (MAX);
SELECT @cols2 = COALESCE (@cols2 + ',"' + CAST(rok AS VARCHAR) + '"', 
               '"' + CAST(rok AS VARCHAR) + '"')
               FROM (SELECT DISTINCT YEAR(OrderDate) AS rok FROM [Sales].[SalesOrderHeader]) PV
			   ORDER BY rok

DECLARE @queryInsert NVARCHAR(MAX)
SET @queryInsert = '
INSERT INTO Sprzedaz
SELECT PracId, ProdId, [Nazwa produktu], 
FROM (SELECT 
    sp.BusinessEntityID,
    prod.ProductID, 
    prod.Name,
    YEAR(soh.OrderDate) AS rok,
    SUM(sod.OrderQty) As Suma
FROM 
    Sales.SalesPerson sp
    JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product prod ON sod.ProductID = prod.ProductID
GROUP BY 
    sp.BusinessEntityID, prod.ProductID, prod.Name, YEAR(soh.OrderDate)) AS X
PIVOT (
	MIN(X.Suma)
	FOR X.rok IN ('+ @cols2 +')
)AS Y'

EXEC SP_EXECUTESQL @queryInsert;
SELECT * FROM Sprzedaz;


-----wielki test:
DROP TABLE Sprzedaz;
DECLARE @cols NVARCHAR (MAX);
SELECT @cols = COALESCE (@cols + ',[' + CAST(rok AS VARCHAR) + '] INT', 
               '[' + CAST(rok AS VARCHAR) + '] INT')
               FROM (SELECT DISTINCT YEAR(OrderDate) AS rok FROM [Sales].[SalesOrderHeader]) PV
			   ORDER BY rok

DECLARE @query NVARCHAR(MAX)
SET @query = '
CREATE TABLE Sprzedaz (
    pracID INT,
    prodID INT,
    [Nazwa produktu] VARCHAR(255),
	' + @cols + ' 
    PRIMARY KEY (pracID, prodId)
);'

EXEC SP_EXECUTESQL @query;

DECLARE @cols2 NVARCHAR (MAX);
SELECT @cols2 = COALESCE (@cols2 + ',"' + CAST(rok AS VARCHAR) + '"', 
               '"' + CAST(rok AS VARCHAR) + '"')
               FROM (SELECT DISTINCT YEAR(OrderDate) AS rok FROM [Sales].[SalesOrderHeader]) PV
			   ORDER BY rok

DECLARE @queryInsert NVARCHAR(MAX)
SET @queryInsert = '
INSERT INTO Sprzedaz
SELECT BusinessEntityId AS PracId, ProductID AS ProdId, Name AS "Nazwa produktu", 
       COALESCE([2011], 0) AS [2011],
       COALESCE([2012], 0) AS [2012],
       COALESCE([2013], 0) AS [2013],
       COALESCE([2014], 0) AS [2014]
FROM (SELECT 
    sp.BusinessEntityID,
    prod.ProductID, 
    prod.Name,
    YEAR(soh.OrderDate) AS rok,
    SUM(sod.OrderQty) As Suma
FROM 
    Sales.SalesPerson sp
    JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product prod ON sod.ProductID = prod.ProductID
GROUP BY 
    sp.BusinessEntityID, prod.ProductID, prod.Name, YEAR(soh.OrderDate)) AS X
PIVOT (
	MIN(X.Suma)
	FOR X.rok IN ('+ @cols2 +')
)AS Y'

EXEC SP_EXECUTESQL @queryInsert;
SELECT * FROM Sprzedaz;

--1b

SELECT *
FROM (
SELECT *
FROM (
    SELECT 
        sp.BusinessEntityID as PracId,
        YEAR(soh.OrderDate) AS Rok,
		ROW_NUMBER() OVER (
            PARTITION BY sp.BusinessEntityID, YEAR(soh.OrderDate) 
            ORDER BY sod.OrderQty DESC
        ) AS RowNum,
        prod.Name
    FROM 
        Sales.SalesPerson sp
        JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
        JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Production.Product prod ON sod.ProductID = prod.ProductID
) AS SalesData
WHERE RowNum <= 5 ) AS X
PIVOT (
    MAX(Name) FOR RowNum IN ([1], [2], [3], [4], [5])
) AS P
ORDER BY PracId, Rok;


--2a
SELECT YEAR(OrderDate) AS Rok, 
MONTH(OrderDate) AS Miesiąc, 
COUNT(DISTINCT CustomerID) AS LiczbaKlientów
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate), MONTH(OrderDate);

--2b
SELECT 
*
FROM (
    SELECT YEAR(OrderDate) AS "Rok", 
	MONTH(OrderDate) AS "Miesiąc", 
	COUNT(DISTINCT CustomerID) AS LiczbaKlientów
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID, YEAR(OrderDate), MONTH(OrderDate)
) AS SourceTable
PIVOT (
    COUNT(LiczbaKlientów)
    FOR Miesiąc IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS PivotTable
ORDER BY Rok;

SELECT *
FROM (SELECT YEAR(H.OrderDate) "Rok", MONTH(H.OrderDate) "Miesiac",H.CustomerID "Klient"
FROM Sales.SalesOrderHeader H
GROUP BY H.CustomerID, YEAR(H.OrderDate), MONTH(H.OrderDate)) AS klienci
PIVOT(
COUNT(Klient)
FOR Miesiac IN ("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11",
"12")) AS PivotTable
ORDER BY Rok;


--3a
--NULL => 0
SELECT *
FROM (
	SELECT CONCAT(per.FirstName,' ', per.LastName) AS "Imie i nazwisko", 
		YEAR(OrderDate) AS Rok, SalesOrderID "liczba"
	FROM Sales.SalesOrderHeader soh 
	JOIN Person.Person per ON  soh.SalesPersonID = per.BusinessEntityID
) AS SourceTable
PIVOT(
	COUNT(Liczba)
	FOR Rok IN ([2011],[2012],[2013],[2014])
) AS PivotTable;

--3b
SELECT *
FROM (
	SELECT CONCAT(per.FirstName,' ', per.LastName) AS "Imie i nazwisko", 
		YEAR(OrderDate) AS Rok, SalesOrderID "liczba"
	FROM Sales.SalesOrderHeader soh 
	JOIN Person.Person per ON  soh.SalesPersonID = per.BusinessEntityID
) AS SourceTable
PIVOT(
	COUNT(Liczba)
	FOR Rok IN ([2011],[2012],[2013],[2014])
) AS PivotTable
WHERE [2011] != 0 AND [2012] != 0 AND [2013] != 0 AND [2014] != 0;
--lub
SELECT *
FROM (
	SELECT CONCAT(per.FirstName,' ', per.LastName) AS "Imie i nazwisko", 
		YEAR(OrderDate) AS Rok, SalesOrderID "liczba"
	FROM Sales.SalesOrderHeader soh 
	JOIN Person.Person per ON  soh.SalesPersonID = per.BusinessEntityID
	WHERE per.BusinessEntityID IN (
	SELECT P.BusinessEntityID
	FROM Person.Person P
	JOIN HumanResources.Employee E ON P.BusinessEntityID =
	E.BusinessEntityID
	WHERE YEAR(E.HireDate) = 2011)
) AS SourceTable
PIVOT(
	COUNT(Liczba)
	FOR Rok IN ([2011],[2012],[2013],[2014])
) AS PivotTable;


--4
SELECT YEAR(OrderDate) AS Rok, 
       MONTH(OrderDate) AS Miesiac,
       DAY(OrderDate) AS Dzień,
       SUM(TotalDue) AS Suma,
       COUNT(DISTINCT ProductID) AS 'Liczba różnych produktów'
FROM Sales.SalesOrderDetail
INNER JOIN Sales.SalesOrderHeader
    ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate)
ORDER BY Rok, Miesiac, Dzień;

--5
SELECT
	CASE
		WHEN MONTH(H.OrderDate) = 1 THEN 'Styczen'
		WHEN MONTH(H.OrderDate) = 2 THEN 'Luty'
		WHEN MONTH(H.OrderDate) = 3 THEN 'Marzec'
		WHEN MONTH(H.OrderDate) = 4 THEN 'Kwiecien'
		WHEN MONTH(H.OrderDate) = 5 THEN 'Maj'
		WHEN MONTH(H.OrderDate) = 6 THEN 'Czerwiec'
		WHEN MONTH(H.OrderDate) = 7 THEN 'Lipiec'
		WHEN MONTH(H.OrderDate) = 8 THEN 'Sierpien'
		WHEN MONTH(H.OrderDate) = 9 THEN 'Wrzesien'
		WHEN MONTH(H.OrderDate) = 10 THEN 'Pazdziernik'
		WHEN MONTH(H.OrderDate) = 11 THEN 'Listopad'
		WHEN MONTH(H.OrderDate) = 12 THEN 'Grudzien'
	END "Miesiac",
	SUM(H.SubTotal) "Suma kwot",
	COUNT(DISTINCT D.ProductID) "Liczba różnych produktów"
FROM Sales.SalesOrderHeader H JOIN Sales.SalesOrderDetail D ON H.SalesOrderID =D.SalesOrderID
GROUP BY MONTH(H.OrderDate)
ORDER BY MONTH(H.OrderDate) ASC;

--dziala
SELECT 
    YEAR(OrderDate) AS 'Rok',
	CASE 
        WHEN DATEPART(M, OrderDate) = 1 THEN 'Styczeń'
        WHEN DATEPART(M, OrderDate) = 2 THEN 'Luty'
        WHEN DATEPART(M, OrderDate) = 3 THEN 'Marzec'
        WHEN DATEPART(M, OrderDate) = 4 THEN 'Kwiecień'
        WHEN DATEPART(M, OrderDate) = 5 THEN 'Maj'
        WHEN DATEPART(M, OrderDate) = 6 THEN 'Czerwiec'
        WHEN DATEPART(M, OrderDate) = 7 THEN 'Lipiec'
        WHEN DATEPART(M, OrderDate) = 8 THEN 'Sierpień'
        WHEN DATEPART(M, OrderDate) = 9 THEN 'Wrzesień'
        WHEN DATEPART(M, OrderDate) = 10 THEN 'Październik'
        WHEN DATEPART(M, OrderDate) = 11 THEN 'Listopad'
        WHEN DATEPART(M, OrderDate) = 12 THEN 'Grudzień'
    END AS 'Miesiąc',
    CASE 
        WHEN DATEPART(dw, OrderDate) = 1 THEN 'Niedziela'
        WHEN DATEPART(dw, OrderDate) = 2 THEN 'Poniedziałek'
        WHEN DATEPART(dw, OrderDate) = 3 THEN 'Wtorek'
        WHEN DATEPART(dw, OrderDate) = 4 THEN 'Środa'
        WHEN DATEPART(dw, OrderDate) = 5 THEN 'Czwartek'
        WHEN DATEPART(dw, OrderDate) = 6 THEN 'Piątek'
        WHEN DATEPART(dw, OrderDate) = 7 THEN 'Sobota'
    END AS 'Dzień tygodnia',
    SUM(TotalDue) AS 'Suma',
    COUNT(DISTINCT ProductID) AS 'Liczba różnych produktów'
FROM Sales.SalesOrderDetail
INNER JOIN Sales.SalesOrderHeader
    ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
GROUP BY 
    YEAR(OrderDate),
    MONTH(OrderDate),
    CASE 
        WHEN DATEPART(dw, OrderDate) = 1 THEN 'Niedziela'
        WHEN DATEPART(dw, OrderDate) = 2 THEN 'Poniedziałek'
        WHEN DATEPART(dw, OrderDate) = 3 THEN 'Wtorek'
        WHEN DATEPART(dw, OrderDate) = 4 THEN 'Środa'
        WHEN DATEPART(dw, OrderDate) = 5 THEN 'Czwartek'
        WHEN DATEPART(dw, OrderDate) = 6 THEN 'Piątek'
        WHEN DATEPART(dw, OrderDate) = 7 THEN 'Sobota'
    END,
    DAY(OrderDate)
ORDER BY Rok, DATEPART(M, OrderDate), DAY(OrderDate);
--5 poprawne
SELECT 
    YEAR(OrderDate) AS 'Rok',
	MIN(
	CASE 
        WHEN DATEPART(M, OrderDate) = 1 THEN 'Styczeń'
        WHEN DATEPART(M, OrderDate) = 2 THEN 'Luty'
        WHEN DATEPART(M, OrderDate) = 3 THEN 'Marzec'
        WHEN DATEPART(M, OrderDate) = 4 THEN 'Kwiecień'
        WHEN DATEPART(M, OrderDate) = 5 THEN 'Maj'
        WHEN DATEPART(M, OrderDate) = 6 THEN 'Czerwiec'
        WHEN DATEPART(M, OrderDate) = 7 THEN 'Lipiec'
        WHEN DATEPART(M, OrderDate) = 8 THEN 'Sierpień'
        WHEN DATEPART(M, OrderDate) = 9 THEN 'Wrzesień'
        WHEN DATEPART(M, OrderDate) = 10 THEN 'Październik'
        WHEN DATEPART(M, OrderDate) = 11 THEN 'Listopad'
        WHEN DATEPART(M, OrderDate) = 12 THEN 'Grudzień'
    END) AS 'Miesiąc',
    MIN(CASE 
        WHEN DATEPART(dw, OrderDate) = 1 THEN 'Niedziela'
        WHEN DATEPART(dw, OrderDate) = 2 THEN 'Poniedziałek'
        WHEN DATEPART(dw, OrderDate) = 3 THEN 'Wtorek'
        WHEN DATEPART(dw, OrderDate) = 4 THEN 'Środa'
        WHEN DATEPART(dw, OrderDate) = 5 THEN 'Czwartek'
        WHEN DATEPART(dw, OrderDate) = 6 THEN 'Piątek'
        WHEN DATEPART(dw, OrderDate) = 7 THEN 'Sobota'
    END )AS 'Dzień tygodnia',
    SUM(TotalDue) AS 'Suma',
    COUNT(DISTINCT ProductID) AS 'Liczba różnych produktów'
FROM Sales.SalesOrderDetail
INNER JOIN Sales.SalesOrderHeader
    ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
GROUP BY 
    YEAR(OrderDate),
    MONTH(OrderDate),
    DAY(OrderDate)
ORDER BY Rok, MONTH(OrderDate), DAY(OrderDate);


--6a
SELECT
    P.FirstName "Imie",
    p.LastName "Nazwisko",
    [liczba transakcji] "Liczba transakcji",
    [laczna kwota transakcji] "Łączna kwota transakcji",
    CASE
        WHEN [liczba powyzej w roku] >= 2 AND
            [liczba lat] = 4 THEN 'Platynowa'
        WHEN [liczba powyzej sredniej] >= 2 THEN 'Zlota'
        WHEN [liczba transakcji] >= 5 THEN 'Srebrna'
        ELSE 'Brak'
    END AS 'Kolory kart'
FROM (SELECT
    CustomerID,
    SUM([powyzej sredniej w roku]) AS 'liczba powyzej sredniej',
    COUNT(CustomerID) 'liczba lat',
    MIN([powyzej sredniej w roku]) AS 'liczba powyzej w roku'
FROM (SELECT
    CustomerId,
    Rok,
    SUM([powyzej sredniej]) AS 'powyzej sredniej w roku'
FROM (SELECT
    CustomerID,
    YEAR(OrderDate) AS Rok,
    IIF(AVG(TotalDue) OVER () * 1.5 < TotalDue, 1, 0) 'powyzej sredniej'
FROM Sales.SalesOrderHeader) powyzej
GROUP BY CustomerID,
         Rok) rok
GROUP BY CustomerID) calosc
INNER JOIN (SELECT
    CustomerID,
    COUNT(SalesOrderID) AS 'liczba transakcji',
    SUM(TotalDue) AS 'laczna kwota transakcji'
FROM Sales.SalesOrderHeader
GROUP BY CustomerID) transakcje
    ON transakcje.CustomerID = calosc.CustomerID
JOIN Sales.Customer C
    ON C.CustomerID = transakcje.CustomerID
JOIN Person.Person P
    ON C.PersonID = P.BusinessEntityID
WHERE ([liczba powyzej w roku] >= 2
AND [liczba lat] = 4)
OR [liczba powyzej sredniej] >= 2
OR [Liczba transakcji] >= 5;


--
SELECT * FROM
(SELECT YEAR(soh.OrderDate) AS OrderYear, 
       pc.Name AS CategoryName, 
       MAX(p.Name) AS BestSellingItem
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
INNER JOIN Production.ProductSubcategory AS psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS pc
    ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY YEAR(soh.OrderDate), pc.Name) AS X
PIVOT
(
    MAX(BestSellingItem)
    FOR OrderYear IN ([2011], [2012], [2013], [2014])
) AS PivotTable;



SELECT 
    YEAR(soh.OrderDate) AS OrderYear,
    pc.Name AS CategoryName,
    MAX(p.Name) AS BestSellingItem,
    COUNT(*) AS UnitsSold
FROM 
    Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
    INNER JOIN Production.Product AS p
        ON sod.ProductID = p.ProductID
    INNER JOIN Production.ProductSubcategory AS psc
        ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc
        ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY 
    YEAR(soh.OrderDate),
    pc.Name
ORDER BY CategoryName;


--karty

SELECT CardType AS 'Typ Karty', COUNT(*) AS Liczba
FROM Sales.CreditCard cc 
	JOIN Sales.SalesOrderHeader soh
	ON soh.CreditCardID = cc.CreditCardID
GROUP BY cc.CardType

SELECT CardType AS 'Typ Karty', COUNT(*) AS Liczba
FROM Sales.CreditCard cc 
GROUP BY cc.CardType


--lista 3

SELECT 
	COALESCE(Klient, '') AS Klient,
	COALESCE(Rok, '') AS Rok,
    SUM(Kwota) AS Kwota
FROM (
    SELECT 
        CONCAT(per.FirstName, ' ', per.LastName) AS Klient,
        YEAR(soh.OrderDate) AS Rok,
        soh.TotalDue AS Kwota
    FROM 
        Sales.SalesOrderHeader soh
        JOIN Sales.Customer cust ON cust.CustomerID = soh.CustomerID
        JOIN Person.Person per ON per.BusinessEntityID = cust.PersonID
) AS T
GROUP BY 
    ROLLUP(Klient, Rok)
ORDER BY 
    Klient,
    Rok;


--1.1
--prawie dobrze
SELECT 
	ISNULL(CONCAT(per.FirstName,' ',per.LastName), ' ') AS Klient ,
	ISNULL(CONVERT(varchar, YEAR(soh.OrderDate)), ' ') AS Rok,
	SUM([TotalDue]) AS Kwota
FROM 
	Sales.SalesOrderHeader soh
	JOIN Sales.Customer cust ON cust.CustomerID = soh.CustomerID
	JOIN Person.Person per ON per.BusinessEntityID = cust.PersonID
GROUP BY ROLLUP (YEAR(soh.OrderDate), CONCAT([FirstName], ' ' ,[LastName]))
ORDER BY 1;

Select 
	ISNULL(CONCAT(P.FirstName,' ',P.LastName), ' ') "Klient" , ISNULL(CONVERT(varchar, YEAR(H.OrderDate)), ' ') "Rok", SUM(H.TotalDue) "Kwota"
FROM Sales.Customer C Join Sales.SalesOrderHeader H on C.CustomerID = H.CustomerID
 Join Person.Person P on C.PersonID = P.BusinessEntityID
GROUP BY ROLLUP (Year(H.OrderDate), CONCAT(P.FirstName,' ',P.LastName))
Order by 1;



SELECT 
	ISNULL(CONCAT(per.FirstName,' ',per.LastName), ' ') AS Klient,
	ISNULL(CONVERT(varchar, YEAR(soh.OrderDate)), ' ') AS Rok,
	SUM([TotalDue]) AS Kwota
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer cust ON cust.CustomerID = soh.CustomerID 
JOIN Person.Person per ON per.BusinessEntityID = cust.PersonID
GROUP BY CUBE (YEAR([OrderDate]),CONCAT([FirstName], ' ' ,[LastName]))
ORDER BY 1;



--prawie dobrze
SELECT 
	ISNULL(CONCAT(per.FirstName,' ',per.LastName), ' ') AS Klient,
	ISNULL(CONVERT(varchar, YEAR(soh.OrderDate)), ' ') AS Rok,
	SUM([TotalDue]) AS Kwota
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer cust ON cust.CustomerID = soh.CustomerID
JOIN Person.Person per ON per.BusinessEntityID = cust.PersonID
GROUP BY GROUPING SETS 
(
	CONCAT([FirstName], ' ' ,[LastName]),
	YEAR([OrderDate]), 
	(CONCAT([FirstName], ' ' ,[LastName]), YEAR([OrderDate])),
	()
)
ORDER BY 1;


--1.2 
-- !inna kwaota rabatu!
SELECT
pc.Name AS Kategoria,
p.Name,
YEAR([OrderDate]) as Rok,
SUM(UnitPrice * UnitPriceDiscount) AS Kwota
FROM 
Sales.SalesOrderHeader soh 
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
 JOIN Sales.SpecialOffer so ON sod.SpecialOfferID = so.SpecialOfferID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID 
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY GROUPING SETS (
	(pc.Name, p.Name),
	(pc.Name, p.Name, YEAR([OrderDate]))
)
ORDER BY pc.Name, p.Name, YEAR([OrderDate]);


SELECT 
	pc.Name AS Kategoria,
	p.Name AS Produkt,
	YEAR(soh.OrderDate) AS Rok,
    SUM(sod.LineTotal * sod.UnitPriceDiscount) AS Rabat
FROM 
    Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY CUBE ()
ORDER BY 
	pc.Name,
	p.Name,
    YEAR(soh.OrderDate);


SELECT 
	pc.Name AS Kategoria,
	p.Name AS Produkt,
	ISNULL(CONVERT(varchar,YEAR(soh.OrderDate)),'') AS Rok,
    CAST(SUM(sod.LineTotal * sod.UnitPriceDiscount) AS DECIMAL(10,2)) AS Kwota
FROM 
    Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY ROLLUP (
	pc.Name,
	p.Name,
	YEAR(soh.OrderDate)
);

--zad2
SELECT 
  DISTINCT C.Name Kategoria, 
  YEAR(H.OrderDate) Rok, 
  ROUND(
    SUM(H.TotalDue) OVER(
      PARTITION by C.Name, 
      Year(H.OrderDate)
    ) * 100 / Sum(H.TotalDue) OVER(PARTITION by C.Name), 
    2
  ) Procent 
FROM 
  Production.Product P 
  JOIN Sales.SalesOrderDetail D on P.ProductID = D.ProductID 
  JOIN Production.ProductSubcategory S on P.ProductSubcategoryID = S.ProductSubcategoryID 
  JOIN Production.ProductCategory C on S.ProductCategoryID = C.ProductCategoryID 
  JOIN Sales.SalesOrderHeader H on D.SalesOrderID = H.SalesOrderID 
WHERE 
  C.Name IN ('Accessories', 'Bikes', 'Clothing', 'Components')
ORDER BY 
  Kategoria, Rok;



SELECT
  Kategoria,
  [2011], [2012], [2013], [2014]
FROM
  (
    SELECT
      C.Name AS Kategoria,
      YEAR(H.OrderDate) AS Rok,
      ROUND(
        SUM(H.TotalDue) OVER(
          PARTITION BY C.Name, YEAR(H.OrderDate)
        ) * 100 / SUM(H.TotalDue) OVER(PARTITION BY C.Name),
        2
      ) AS Procent
    FROM 
      Production.Product P 
      JOIN Sales.SalesOrderDetail D on P.ProductID = D.ProductID 
      JOIN Production.ProductSubcategory S on P.ProductSubcategoryID = S.ProductSubcategoryID 
      JOIN Production.ProductCategory C on S.ProductCategoryID = C.ProductCategoryID 
      JOIN Sales.SalesOrderHeader H on D.SalesOrderID = H.SalesOrderID 
    WHERE 
      C.Name IN ('Accessories', 'Bikes', 'Clothing', 'Components')
  ) AS src
PIVOT (
  MAX(Procent)
  FOR Rok IN ([2011], [2012], [2013], [2014])
) AS piv
ORDER BY Kategoria;








WITH CTE_BikeSales AS (
	SELECT
		YEAR(soh.OrderDate) AS Rok,
		SUM(sod.LineTotal) OVER (PARTITION BY YEAR(soh.OrderDate)) AS BikeSalesYearly,
		SUM(sod.LineTotal) OVER (PARTITION BY pc.Name) AS BikeSalesTotal,
		pc.Name AS Nazwa,
		sod.LineTotal AS SalesAmount
	FROM 
		Sales.SalesOrderHeader soh
		JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
		JOIN Production.Product p ON sod.ProductID = p.ProductID
		JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
		JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
	WHERE
		pc.Name = 'Bikes'
)
SELECT
	CTE_BikeSales.Rok AS Year,
	CTE_BikeSales.Nazwa AS Nazwa,
	CAST(100.0 * CTE_BikeSales.SalesAmount / CTE_BikeSales.BikeSalesYearly AS DECIMAL(10,2)) AS SalesPercentageInYear,
	CAST(100.0 * CTE_BikeSales.SalesAmount / CTE_BikeSales.BikeSalesTotal AS DECIMAL(10,2)) AS SalesPercentageTotal
FROM
	CTE_BikeSales
ORDER BY
	CTE_BikeSales.Rok, CTE_BikeSales.Nazwa;


--2


WITH customer_order_counts AS (
    SELECT 
        CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
        YEAR(o.OrderDate) AS OrderYear,
        COUNT(o.SalesOrderID) AS OrderCount,
		ROW_NUMBER() OVER (PARTITION BY YEAR(o.OrderDate) ORDER BY COUNT(o.SalesOrderID) DESC) AS OrderRank
    FROM 
        Sales.Customer c
        JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
        JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
    GROUP BY 
        CONCAT(p.FirstName, ' ', p.LastName), 
        YEAR(o.OrderDate)
)
SELECT 
    CustomerName, 
    OrderYear, 
    OrderCount, 
    OrderRank
FROM 
    customer_order_counts
WHERE 
    OrderRank <= 10
ORDER BY 
    OrderYear, 
    OrderRank;


WITH customer_order_counts AS (
    SELECT 
        CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
        YEAR(o.OrderDate) AS OrderYear,
        COUNT(o.SalesOrderID) AS OrderCount,
        ROW_NUMBER() OVER (PARTITION BY YEAR(o.OrderDate) ORDER BY COUNT(o.SalesOrderID) DESC) AS OrderRank
    FROM 
        Sales.Customer c
        JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
        JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
    WHERE 
        YEAR(o.OrderDate) <= YEAR(GETDATE())
    GROUP BY 
        CONCAT(p.FirstName, ' ', p.LastName), 
        YEAR(o.OrderDate)
	HAVING CONCAT(p.FirstName, ' ', p.LastName) = 'Abe Tramel' AND YEAR(o.OrderDate) <= YEAR(GETDATE())
)
SELECT 
    CustomerName, 
    OrderYear, 
    SUM(OrderCount) OVER (PARTITION BY CustomerName ORDER BY OrderYear) AS CumulativeOrderCount, 
    OrderRank
FROM 
    customer_order_counts
WHERE 
    OrderRank <= 10
ORDER BY 
    OrderYear, 
    OrderRank;


    SELECT 
        CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
        YEAR(o.OrderDate) AS OrderYear,
        COUNT(o.SalesOrderID) AS OrderCount
    FROM 
        Sales.Customer c
        JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
        JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
    WHERE 
        YEAR(o.OrderDate) <= YEAR(GETDATE()) 
		AND CONCAT(p.FirstName, ' ', p.LastName) = 'Abe Tramel'
    GROUP BY 
        CONCAT(p.FirstName, ' ', p.LastName), 
        YEAR(o.OrderDate);

SELECT *, DENSE_RANK() OVER(ORDER BY Razem DESC) AS Ranking
FROM (
SELECT 
	CONCAT(P.FirstName, ' ', P.LastName) Klient,
	YEAR(H.OrderDate) Rok,
	COUNT(H.SalesOrderID) OVER (PARTITION BY C.CustomerID) Razem,
	COUNT(H.SalesOrderID) OVER (PARTITION BY C.CustomerID
		ORDER BY YEAR(H.OrderDate) RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) Narastająco
FROM Sales.SalesOrderHeader H JOIN Sales.Customer C ON H.CustomerID = C.CustomerID
 JOIN Person.Person P ON P.BusinessEntityID = C.PersonID
 )
AS zamowienia 
PIVOT (
MAX(Narastająco)
FOR Rok IN ("2011", "2012", "2013", "2014")
) Lata;


SELECT TOP (10) *, 
    DENSE_RANK() OVER (ORDER BY Razem DESC) AS 'Rank'
FROM (
    SELECT 
        CONCAT(P.FirstName, ' ', P.LastName) Klient,
        YEAR(H.OrderDate) Rok,
        COUNT(H.SalesOrderID) OVER (PARTITION BY  C.CustomerID, YEAR(H.OrderDate)) "Zamowienia roczne",
        COUNT(H.SalesOrderID) OVER (PARTITION BY  C.CustomerID ORDER BY YEAR(H.OrderDate)) Razem
    FROM 
        Sales.SalesOrderHeader H 
        JOIN Sales.Customer C ON H.CustomerID = C.CustomerID
        JOIN Person.Person P ON P.BusinessEntityID = C.PersonID
) AS zamowienia 
PIVOT (
    MAX("Zamowienia roczne")
    FOR Rok IN ("2011", "2012", "2013", "2014")
) Lata;

--3

SELECT 
  *, 
  SUM("W miesiącu") OVER (
    PARTITION BY "Imię i nazwisko", 
    Rok 
    ORDER BY 
      Miesiąc ROWS BETWEEN 1 PRECEDING 
      AND CURRENT ROW
  ) "Obecny i poprzedni miesiąc" 
FROM 
  (
    SELECT 
      DISTINCT CONCAT(per.FirstName, ' ', per.LastName) "Imię i nazwisko", 
      YEAR(soh.OrderDate) Rok, 
      MONTH(soh.OrderDate) Miesiąc, 
      COUNT(soh.SalesOrderID) OVER (
        PARTITION BY CONCAT(per.FirstName, ' ', per.LastName), 
        YEAR(soh.OrderDate), 
        MONTH(soh.OrderDate)
      ) "W miesiącu", 
      COUNT(soh.SalesOrderID) OVER (
        PARTITION BY CONCAT(per.FirstName, ' ', per.LastName), 
        YEAR(soh.OrderDate)
      ) "W roku", 
      COUNT(soh.SalesOrderID) OVER (
        PARTITION BY CONCAT(per.FirstName, ' ', per.LastName), 
        YEAR(soh.OrderDate) 
        ORDER BY 
          MONTH(soh.OrderDate) RANGE BETWEEN UNBOUNDED PRECEDING 
          AND CURRENT ROW
      ) "W roku narastająco" 
    FROM 
      Sales.SalesOrderHeader soh 
      JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID 
      JOIN HumanResources.Employee E ON sp.BusinessEntityID = E.BusinessEntityID 
      JOIN Person.Person per ON per.BusinessEntityID = E.BusinessEntityID
  ) AS Sprzedawcy 
ORDER BY 
  [Imię i nazwisko], Rok, Miesiąc;


--4

WITH pokategorie AS (
    SELECT
        pc.Name AS Kategoria,
        ps.Name AS Podkategoria,
        MAX(p.ListPrice) AS MaxPrice
    FROM 
        Production.Product p
        JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY 
        pc.Name,
        ps.Name
)
SELECT
    Kategoria,
    ROUND(SUM(MaxPrice),2) AS 'Suma maks. cen'
FROM 
    pokategorie
GROUP BY Kategoria;




--5

SELECT *, RANK() OVER (ORDER BY "Liczba produktow" DESC) Ranking
FROM(
 SELECT DISTINCT CONCAT(P.FirstName, ' ', P.LastName) "Imie i nazwisko",
 SUM(D.OrderQty) OVER (PARTITION BY H.CustomerID) "Liczba produktow"
 FROM Sales.SalesOrderHeader H JOIN Sales.SalesOrderDetail D
 ON H.SalesOrderID = D.SalesOrderID 
 JOIN Sales.Customer C 
 ON H.CustomerID = C.CustomerID
 JOIN Person.Person P 
 ON C.PersonID= P.BusinessEntityID) AS Klient;

SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Klient,
    SUM(sod.OrderQty) AS 'Liczba zakupionych produktów',
    RANK() OVER (ORDER BY SUM(sod.OrderQty) DESC) AS 'rank',
    DENSE_RANK() OVER (ORDER BY SUM(sod.OrderQty) DESC) AS 'dense rank'
FROM 
    Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY 
    CONCAT(p.FirstName, ' ', p.LastName);


--6 do poprawy
SELECT 
    p.Name AS Product,
    AVG(sod.OrderQty) AS AvgUnitsSold,
    DENSE_RANK() OVER (ORDER BY AVG(sod.OrderQty) DESC) AS Ranking,
    CASE 
        WHEN RANK() OVER (ORDER BY AVG(sod.OrderQty) DESC) <= CEILING(COUNT(*) OVER () * 0.33) THEN 'Best-selling'
        WHEN RANK() OVER (ORDER BY AVG(sod.OrderQty) DESC) <= CEILING(COUNT(*) OVER () * 0.66) THEN 'Average'
        ELSE 'Worst-selling'
    END AS SalesGroup
FROM 
    Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY Ranking;


SELECT 
  "Nazwa produktu", 
  DENSE_RANK() OVER (
    ORDER BY 
      Srednia DESC
  ) Miejsce, 
  NTILE(3) OVER (
    ORDER BY 
      Srednia DESC
  ) Grupa, 
  Srednia 
FROM 
  (
    SELECT 
      DISTINCT P.Name "Nazwa produktu", 
      AVG(D.OrderQty) OVER (PARTITION BY D.ProductID) Srednia 
    FROM 
      Sales.SalesOrderDetail D 
      JOIN Production.Product P ON D.ProductID = P.ProductID
  ) AS ListaProduktow;

SELECT 
  "Nazwa produktu", 
  DENSE_RANK() OVER (
    ORDER BY 
      Srednia DESC
  ) Miejsce, 
  NTILE(3) OVER (
    ORDER BY 
      Srednia DESC
  ) Grupa, 
  Srednia 
FROM 
  (
    SELECT 
      DISTINCT P.Name "Nazwa produktu", 
      AVG(CAST(D.OrderQty AS FLOAT)) OVER (PARTITION BY D.ProductID) Srednia 
    FROM 
      Sales.SalesOrderDetail D 
      JOIN Production.Product P ON D.ProductID = P.ProductID
  ) AS ListaProduktow;


  SELECT 
  "Produkt", 
  DENSE_RANK() OVER (
    ORDER BY 
      Srednia DESC
  ) Miejsce, 
  CASE NTILE(3) OVER (
    ORDER BY 
      Srednia DESC
  ) 
    WHEN 1 THEN 'najlepiej' 
    WHEN 2 THEN 'średnio' 
    WHEN 3 THEN 'najsłabiej' 
  END AS Grupa, 
  Srednia 
FROM 
  (
    SELECT 
      DISTINCT P.Name "Produkt", 
      AVG(CAST(D.OrderQty AS FLOAT)) OVER (PARTITION BY D.ProductID) Srednia 
    FROM 
      Sales.SalesOrderDetail D 
      JOIN Production.Product P ON D.ProductID = P.ProductID
  ) AS ListaProduktow;


SELECT 
  "Produkt", 
  DENSE_RANK() OVER (
    ORDER BY 
      Srednia DESC
  ) Miejsce, 
  CASE NTILE(3) OVER (
    ORDER BY 
      Srednia DESC
  ) WHEN 1 THEN 'najlepiej' WHEN 2 THEN 'średnio' WHEN 3 THEN 'najsłabiej' END AS Grupa, 
  Srednia 
FROM 
  (
    SELECT 
      DISTINCT P.Name "Produkt", 
      AVG(
        CAST(D.OrderQty AS FLOAT)
      ) OVER (PARTITION BY D.ProductID) Srednia 
    FROM 
      Sales.SalesOrderDetail D 
      JOIN Production.Product P ON D.ProductID = P.ProductID
  ) AS ListaProduktow;
