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




CREATE TABLE STROZIK.DIM_TIME
(
	Id INT PRIMARY KEY,
	"Year" INT NOT NULL,
	"Quarter" INT NOT NULL,
	"Month" INT NOT NULL,
	"Month In Words" NVARCHAR(10) NOT NULL,
	"Day" INT NOT NULL,
	"Day In Words" NVARCHAR(10) NOT NULL
);

CREATE TABLE STROZIK.DIM_PLACE
(
	Id INT PRIMARY KEY,
	Country NVARCHAR(50) NOT NULL,
	Region NVARCHAR(35) NULL,
	Latitude DECIMAL(18,6) NULL,
	Longitude DECIMAL(18,6) NULL,
	Airport_Code NVARCHAR(10) NULL,
	Airport_Name NVARCHAR(100) NULL
);

CREATE TABLE STROZIK.DIM_CONDITIONS
(
	Id INT PRIMARY KEY,
	Weather_Condition NVARCHAR(5) NOT NULL,
	Weather_Condition_Name NVARCHAR(30) NOT NULL
);

CREATE TABLE STROZIK.DIM_PLANE
(
	Id INT PRIMARY KEY,
	Make NVARCHAR(50) NULL,
	Model NVARCHAR(50) NULL,
	Amateur_Built NVARCHAR(3) NULL,
	Number_Of_Engines INT NULL,
	Engine_Type NVARCHAR(30),
	Aircraft_Category NVARCHAR(30)
);

CREATE TABLE STROZIK.DIM_ACCIDENT
(
	Accident_Number NVARCHAR(20) PRIMARY KEY,
	Investigation_Type NVARCHAR(20) NULL,
	Injury_Severity NVARCHAR(20) NULL,
	Aircraft_damage NVARCHAR(15) NULL,
	FAR_Description NVARCHAR(200) NULL,
	Schedule NVARCHAR(10) NULL,
	Purpose_of_flight NVARCHAR(30) NULL,
	Air_Carrier NVARCHAR(100) NULL,
	Broad_phase_of_flight NVARCHAR(20) NULL
);

 
CREATE TABLE STROZIK.FACT_ACCIDENTS
(
	Accident_Id NVARCHAR(20) PRIMARY KEY,
	Time_Id INT NOT NULL,
	Publication_Date INT NULL,
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

ALTER TABLE STROZIK.FACT_ACCIDENTS
	ADD CONSTRAINT CONDITIONS_FOREIGN_KEY FOREIGN KEY(Weather_Conditions_Id) REFERENCES STROZIK.DIM_CONDITIONS(Id),
		CONSTRAINT ACCIDENT_FOREIGN_KEY FOREIGN KEY(Accident_Id) REFERENCES STROZIK.DIM_ACCIDENT(Accident_Number),
		CONSTRAINT PLACE_FOREIGN_KEY FOREIGN KEY(Place_Id) REFERENCES STROZIK.DIM_PLACE(Id),
		CONSTRAINT PLANE_FOREIGN_KEY FOREIGN KEY(Plane_Id) REFERENCES STROZIK.DIM_PLANE(Id),
		CONSTRAINT EVENT_DATE_FOREIGN_KEY FOREIGN KEY(Time_Id) REFERENCES STROZIK.DIM_TIME(Id),
		CONSTRAINT PUBLICATION_DATE_FOREIGN_KEY FOREIGN KEY(Publication_Date) REFERENCES STROZIK.DIM_TIME(Id);






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




