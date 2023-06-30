CREATE TABLE [STROZIK].[AviationData](
	[Event_Id] [nvarchar](50) NOT NULL,
	[Investigation_Type] [nvarchar](20) NOT NULL,
	[Accident_Number] [nvarchar](20) NOT NULL,
	[Event_Date] [date] NOT NULL,
	[Location] [nvarchar](100) NULL,
	[Country] [nvarchar](50) NULL,
	[Latitude] [decimal](18, 6) NULL,
	[Longitude] [decimal](18, 6) NULL,
	[Airport_Code] [nvarchar](10) NULL,
	[Airport_Name] [nvarchar](100) NULL,
	[Injury_Severity] [nvarchar](20) NULL,
	[Aircraft_damage] [nvarchar](15) NULL,
	[Aircraft_Category] [nvarchar](30) NULL,
	[Registration_Number] [nvarchar](15) NULL,
	[Make] [nvarchar](50) NULL,
	[Model] [nvarchar](50) NULL,
	[Amateur_Built] [nvarchar](3) NULL,
	[Number_of_Engines] [int] NULL,
	[Engine_Type] [nvarchar](30) NULL,
	[FAR_Description] [nvarchar](200) NULL,
	[Schedule] [nvarchar](10) NULL,
	[Purpose_of_flight] [nvarchar](30) NULL,
	[Air_carrier] [nvarchar](100) NULL,
	[Total_Fatal_Injuries] [int] NULL,
	[Total_Serious_Injuries] [int] NULL,
	[Total_Minor_Injuries] [int] NULL,
	[Total_Uninjured] [int] NULL,
	[Weather_Condition] [nvarchar](5) NULL,
	[Broad_phase_of_flight] [nvarchar](20) NULL,
	[Report_Status] [nvarchar](max) NULL,
	[Publication_Date] [date] NULL
);

CREATE TABLE DIM_TIME
(
	Id INT PRIMARY KEY,
	"Year" INT NOT NULL,
	"Quarter" INT NOT NULL,
	"Month" INT NOT NULL,
	"Month In Words" NVARCHAR(10) NOT NULL,
	"Day" INT NOT NULL,
	"Day In Words" NVARCHAR(10) NOT NULL
);

CREATE TABLE DIM_PLACE
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Country NVARCHAR(50) NULL,
	District NVARCHAR(100) NULL,
	Region_Name NVARCHAR(100) NULL,
	Latitude DECIMAL(18,6) NULL,
	Longitude DECIMAL(18,6) NULL,
	Airport_Code NVARCHAR(10) NULL,
	Airport_Name NVARCHAR(100) NULL
);



CREATE TABLE DIM_CONDITIONS
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Weather_Condition NVARCHAR(5) NULL,
	Weather_Condition_Name NVARCHAR(30) NOT NULL
);

CREATE TABLE DIM_PLANE
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Make NVARCHAR(50) NULL,
	Model NVARCHAR(50) NULL,
	Amateur_Built NVARCHAR(3) NULL,
	Number_Of_Engines INT NULL,
	Engine_Type NVARCHAR(30),
	Aircraft_Category NVARCHAR(30)
);

CREATE TABLE DIM_FLIGHT
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Investigation_Type NVARCHAR(20) NULL,
	Injury_Severity NVARCHAR(20) NULL,
	Aircraft_damage NVARCHAR(15) NULL,
	FAR_Description NVARCHAR(200) NULL,
	Schedule NVARCHAR(10) NULL,
	Purpose_of_flight NVARCHAR(30) NULL,
	Air_Carrier NVARCHAR(100) NULL,
	Broad_phase_of_flight NVARCHAR(20) NULL
);

 
CREATE TABLE FACT_ACCIDENTS
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Flight_Id INT NOT NULL,
	Time_Id INT NOT NULL,
	Place_Id INT NOT NULL,
	Plane_Id INT NOT NULL,
	Weather_Conditions_Id INT NOT NULL,
	Total_Fatal_Injuries INT NULL,
	Total_Serious_Injuries INT NULL,
	Total_Minor_Injuries INT NULL,
	Total_Uninjured INT NULL,
	TotalOfInjured INT NULL,
	Mortality DECIMAL(18,6) NULL
);

ALTER TABLE FACT_ACCIDENTS
	ADD CONSTRAINT CONDITIONS_FOREIGN_KEY FOREIGN KEY(Weather_Conditions_Id) REFERENCES DIM_CONDITIONS(Id),
		CONSTRAINT ACCIDENT_FOREIGN_KEY FOREIGN KEY(Flight_Id) REFERENCES DIM_FLIGHT(Id),
		CONSTRAINT PLACE_FOREIGN_KEY FOREIGN KEY(Place_Id) REFERENCES DIM_PLACE(Id),
		CONSTRAINT PLANE_FOREIGN_KEY FOREIGN KEY(Plane_Id) REFERENCES DIM_PLANE(Id),
		CONSTRAINT EVENT_DATE_FOREIGN_KEY FOREIGN KEY(Time_Id) REFERENCES DIM_TIME(Id);

ALTER TABLE FACT_ACCIDENTS
DROP CONSTRAINT CONDITIONS_FOREIGN_KEY, ACCIDENT_FOREIGN_KEY, PLACE_FOREIGN_KEY, PLANE_FOREIGN_KEY,EVENT_DATE_FOREIGN_KEY;


--inserting...

--DIM_TIME
DECLARE @D INT;
SET @D = (SELECT TOP 1 DATEPART(YYYY, Event_Date) * 10000 + DATEPART(MM, Event_Date) * 100 + DATEPART(DD, Event_Date) FROM STROZIK.AviationData ORDER BY 1);

DECLARE @COUNTER DATE;
SET @COUNTER = CONVERT(date, CAST(@D AS nvarchar));

DECLARE @END INT;
SET @END = (SELECT TOP 1 DATEPART(YYYY, Event_Date) * 10000 + DATEPART(MM, Event_Date) * 100 + DATEPART(DD, Event_Date) FROM STROZIK.AviationData ORDER BY 1 DESC);

WHILE (@D <= @END)
BEGIN
    INSERT INTO DIM_TIME VALUES
    (
        @D,
        YEAR(@COUNTER),
        DATEPART(QQ, @COUNTER),
        MONTH(@COUNTER),
        DATENAME(MONTH, @COUNTER),
        DAY(@COUNTER),
        DATENAME(WEEKDAY, @COUNTER)
    );

    SET @COUNTER = DATEADD(DAY, 1, @COUNTER);
    SET @D = CAST(CONVERT(varchar(8), @COUNTER, 112) AS INT);
END;

SELECT * FROM DIM_TIME;
DELETE FROM DIM_TIME;

--DIM_PLACE

INSERT INTO DIM_PLACE(Country, District, Region_Name, Latitude, Longitude, Airport_Code, Airport_Name)
SELECT DISTINCT 
	Country,
	CASE 
		WHEN CHARINDEX(',', REVERSE(Location)) > 0 
		THEN LEFT(Location, LEN(Location) - CHARINDEX(',', REVERSE(Location))) 
		ELSE NULL 
	END AS District,
	CASE 
		WHEN Location IS NULL THEN NULL 
		ELSE SUBSTRING(Location, LEN(Location) - CHARINDEX(',', REVERSE(Location)) + 3, LEN(Location)) 
	END AS Region_Name,
    Latitude,
	Longitude,
    Airport_Code,
    Airport_Name
FROM STROZIK.AviationData;

SELECT * FROM DIM_PLACE;

SELECT * FROM STROZIK.AviationData;

--PLANE
INSERT INTO DIM_PLANE (
  Make, Model, Amateur_Built, Number_Of_Engines, 
  Engine_Type, Aircraft_Category
) 
SELECT 
  Make, 
  Model, 
  Amateur_Built, 
  Number_Of_Engines, 
  Engine_Type, 
  Aircraft_Category 
FROM 
  (
    SELECT 
      DISTINCT Make, 
      Model, 
      Amateur_Built, 
      Number_Of_Engines, 
      Engine_Type, 
      Aircraft_Category 
    FROM 
      STROZIK.AviationData
  ) A;


SELECT * FROM DIM_PLANE
WHERE Id = 2358 OR Id = 19406;

--FLIGHTINSERT INTO DIM_FLIGHT (Investigation_Type, Injury_Severity, Aircraft_Damage, FAR_Description, Schedule, Purpose_of_Flight, Air_Carrier, Broad_Phase_Of_Flight)
SELECT DISTINCT Investigation_Type, Injury_Severity, Aircraft_damage, FAR_Description, Schedule, Purpose_of_flight, Air_carrier, Broad_phase_of_flight
FROM STROZIK.AviationData;

SELECT * FROM DIM_FLIGHT;

--Weather

INSERT INTO DIM_CONDITIONS (Weather_Condition, Weather_Condition_Name)
SELECT 
  Weather_Condition AS Weather_Condition_Code,
  CASE 
    WHEN Weather_Condition = 'VMC' THEN 'Good conditions'
	WHEN Weather_Condition = 'UNK' OR Weather_Condition = '' OR Weather_Condition IS NULL THEN 'Unknown'
    WHEN Weather_Condition = 'IMC' THEN 'Bad conditions'
  END AS Weather_Condition_Name
FROM 
  (
  SELECT DISTINCT 
    Weather_Condition
  FROM 
    STROZIK.AviationData 
  ) A;


--- FACT ACCIDENTS
INSERT INTO FACT_ACCIDENTS(Flight_Id,Time_Id, Place_Id, Plane_Id, Weather_Conditions_Id, Total_Fatal_Injuries, Total_Serious_Injuries, Total_Minor_Injuries, Total_Uninjured, TotalOfInjured, Mortality)
SELECT
	DIM_FLIGHT.Id AS Flight_Id,
	DIM_TIME.Id AS Time_Id, 
	DIM_PLACE.Id AS Place_Id, 
	DIM_PLANE.Id AS Plane_Id,
	DIM_CONDITIONS.Id AS Weather_Conditions_Id,
	ISNULL(AviationData.Total_Fatal_Injuries, 0) AS Total_Fatal_Injuries,
	ISNULL(AviationData.Total_Serious_Injuries, 0) AS Total_Serious_Injuries,
	ISNULL(AviationData.Total_Minor_Injuries, 0) AS Total_Minor_Injuries,
	ISNULL(AviationData.Total_Uninjured, 0) AS Total_Uninjured,
	ISNULL(AviationData.Total_Fatal_Injuries, 0) + ISNULL(AviationData.Total_Serious_Injuries, 0) + ISNULL(AviationData.Total_Minor_Injuries, 0) AS TotalOfInjured,
	CASE
		WHEN AviationData.Total_Fatal_Injuries IS NULL THEN 0
		WHEN AviationData.Total_Uninjured + AviationData.Total_Serious_Injuries + AviationData.Total_Minor_Injuries = 0 THEN 1
		ELSE AviationData.Total_Fatal_Injuries * 1.0 / (AviationData.Total_Uninjured + AviationData.Total_Serious_Injuries + AviationData.Total_Minor_Injuries + AviationData.Total_Fatal_Injuries)
	END AS Mortality
FROM STROZIK.AviationData
JOIN DIM_FLIGHT ON CONCAT(STROZIK.AviationData.Investigation_Type,
STROZIK.AviationData.Injury_Severity,STROZIK.AviationData.Aircraft_Damage,
STROZIK.AviationData.FAR_Description, STROZIK.AviationData.Schedule,
STROZIK.AviationData.Purpose_Of_Flight, STROZIK.AviationData.Air_Carrier,
STROZIK.AviationData.Broad_Phase_Of_Flight) = CONCAT(DIM_FLIGHT.Investigation_Type,
DIM_FLIGHT.Injury_Severity, DIM_FLIGHT.Aircraft_Damage,
DIM_FLIGHT.FAR_Description, DIM_FLIGHT.Schedule, DIM_FLIGHT.Purpose_Of_Flight,
DIM_FLIGHT.Air_Carrier, DIM_FLIGHT.Broad_Phase_Of_Flight)
JOIN DIM_TIME ON DIM_TIME.Id = DATEPART(YYYY, Event_Date) * 10000 +
DATEPART(MM, Event_Date) * 100 + DATEPART(DD, Event_Date)JOIN DIM_PLANE ON CONCAT(DIM_PLANE.Make, DIM_PLANE.Model,
DIM_PLANE.Amateur_Built, CAST(DIM_PLANE.Number_Of_Engines AS nvarchar(2)),
DIM_PLANE.Engine_Type, DIM_PLANE.Aircraft_Category) = CONCAT(STROZIK.AviationData.Make,
STROZIK.AviationData.Model, STROZIK.AviationData.Amateur_Built, CAST(STROZIK.AviationData.Number_Of_Engines 
AS nvarchar(2)), STROZIK.AviationData.Engine_Type, STROZIK.AviationData.Aircraft_Category)
JOIN DIM_CONDITIONS ON DIM_CONDITIONS.Weather_Condition =
STROZIK.AviationData.Weather_ConditionJOIN DIM_PLACE ON 
CONCAT(
	DIM_PLACE.Country,
	ISNULL(CONCAT_WS(', ', DIM_PLACE.District, DIM_PLACE.Region_Name), ''),
	DIM_PLACE.Latitude,
	DIM_PLACE.Longitude,
	DIM_PLACE.Airport_Code,
	DIM_PLACE.Airport_Name)
= 
CONCAT(
	STROZIK.AviationData.Country,
	STROZIK.AviationData.Location,
	STROZIK.AviationData.Latitude,
	STROZIK.AviationData.Longitude,
	STROZIK.AviationData.Airport_Code,
	STROZIK.AviationData.Airport_Name)ORDER BY Flight_Id;

	--
	CASE 
		WHEN  AviationData.Total_Uninjured IS NULL THEN 1
		WHEN  AviationData.Total_Uninjured = 0 THEN 1
		ELSE ISNULL(AviationData.Total_Fatal_Injuries, 0) + ISNULL(AviationData.Total_Serious_Injuries, 0) + ISNULL(AviationData.Total_Minor_Injuries, 0) * 1.0 / AviationData.Total_Uninjured 
	END AS Injurity



Select Longitude FROM STROZIK.AviationData
WHERE Longitude IS NOT NULL
ORDER BY Longitude DESC;

Select Amateur_Built FROM STROZIK.AviationData
GROUP BY Amateur_Built;

Select Number_of_Engines, COUNT(*) FROM STROZIK.AviationData
GROUP BY Number_of_Engines
ORDER BY Number_of_Engines;

Select Schedule, COUNT(*) FROM STROZIK.AviationData
GROUP BY Schedule
ORDER BY Schedule;


Select Weather_Condition, COUNT(*) FROM STROZIK.AviationData
GROUP BY Weather_Condition
ORDER BY Weather_Condition;

Select Report_Status, COUNT(*) FROM STROZIK.AviationData
GROUP BY Report_Status
ORDER BY Report_Status;

Select Publication_Date, COUNT(*) FROM STROZIK.AviationData
GROUP BY Publication_Date
ORDER BY Publication_Date;

SELECT 
    Report_Status,
    COUNT(*) AS Total_Count,
    ROUND(COUNT(CASE WHEN Report_Status IS NULL THEN 1 END) / COUNT(*) * 100, 2) AS Publication_Date_Null_Percentage,
    ROUND(COUNT(CASE WHEN Publication_Date IS NOT NULL THEN 2 END) / COUNT(*) * 100, 2) AS Column1_Null_Percentage
FROM STROZIK.AviationData
GROUP BY Publication_Date
ORDER BY Publication_Date;

SELECT 
    COUNT(CASE WHEN Purpose_of_flight IS NULL THEN 1 END) AS Rows_With_Null_Count,
    COUNT(*) AS Total_Count,
    ROUND(CAST(COUNT(CASE WHEN Purpose_of_flight IS NULL THEN 1 END) AS FLOAT) / COUNT(*) * 100, 2) AS Rows_With_Null_Percentage
FROM STROZIK.AviationData;

