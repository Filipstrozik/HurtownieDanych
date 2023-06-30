CREATE TABLE Client (
    ClientId varchar(50) PRIMARY KEY,
    Email varchar(50) NOT NULL,
    Password varchar(50) NOT NULL,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Phone varchar(20)
);

CREATE TABLE Owner (
    OwnerId int PRIMARY KEY,
    Name varchar(50) NOT NULL,
    Email varchar(50) NOT NULL,
    Phone varchar(20),
    Address varchar(100),
    Description varchar(100)
);

CREATE TABLE ChargingStation (
    ChargingStationId int PRIMARY KEY,
    OwnerId int NOT NULL,
    Name varchar(50) NOT NULL,
    Address varchar(100) NOT NULL,
    Latitude float NOT NULL,
    Longitude float NOT NULL,
    Description varchar(100),
    Active bit NOT NULL,
    CONSTRAINT FK_ChargingStation_Owner FOREIGN KEY (OwnerId) REFERENCES Owner(OwnerId)
);

 
CREATE TABLE Reservation (
    ReservationId int PRIMARY KEY,
    ChargingStationId int NOT NULL,
    ClientId varchar(50) NOT NULL,
    StartDate datetime NOT NULL,
    EndDate datetime NOT NULL,
    Confirmed bit NOT NULL,
    Active bit NOT NULL,
    CONSTRAINT FK_Reservation_ChargingStation FOREIGN KEY (ChargingStationId) REFERENCES ChargingStation(ChargingStationId),
    CONSTRAINT FK_Reservation_Client FOREIGN KEY (ClientId) REFERENCES Client(ClientId)
);

CREATE TABLE Post (
    PostId int PRIMARY KEY,
    ChargingStationId int NOT NULL,
    ClientId varchar(50) NOT NULL,
    Content varchar(max) NOT NULL,
    StartDate datetime NOT NULL,
    Stars int NOT NULL,
    CONSTRAINT FK_Post_ChargingStation FOREIGN KEY (ChargingStationId) REFERENCES ChargingStation(ChargingStationId),
    CONSTRAINT FK_Post_Client FOREIGN KEY (ClientId) REFERENCES Client(ClientId)
);
