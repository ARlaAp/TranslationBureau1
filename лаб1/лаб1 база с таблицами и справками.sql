
USE master;
GO

CREATE DATABASE SAgencyDB;
GO

USE SAgencyDB;
GO

-- СОЗДАНИЕ СПРАВОЧНЫХ ТАБЛИЦ 

CREATE TABLE ClientTypes (
    TypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(200)
);

CREATE TABLE ObjectTypes (
    TypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(200)
);

CREATE TABLE RiskCategories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryLevel INT NOT NULL UNIQUE CHECK (CategoryLevel BETWEEN 1 AND 5),
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200),
    MinGuardsRequired INT NOT NULL
);

CREATE TABLE ContractStatuses (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusName NVARCHAR(30) NOT NULL UNIQUE,
    Description NVARCHAR(200)
);

CREATE TABLE ShiftStatuses (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusName NVARCHAR(20) NOT NULL UNIQUE,
    Description NVARCHAR(200)
);

CREATE TABLE AlarmReasons (
    ReasonID INT IDENTITY(1,1) PRIMARY KEY,
    ReasonName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(200),
    IsEmergency BIT NOT NULL DEFAULT 0
);

CREATE TABLE CallResults (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    ResultName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(200)
);

CREATE TABLE EmployeeRanks (
    RankID INT IDENTITY(1,1) PRIMARY KEY,
    RankNumber INT NOT NULL UNIQUE CHECK (RankNumber BETWEEN 1 AND 6),
    RankName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200),
    MinSalary DECIMAL(10,2)
);
GO

-- СОЗДАНИЕ ОСНОВНЫХ ТАБЛИЦ 

CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    TypeID INT NOT NULL,
    ClientName NVARCHAR(200) NOT NULL,
    ContactPerson NVARCHAR(150),
    Phone NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100),
    LegalAddress NVARCHAR(300),
    CONSTRAINT FK_Clients_Types FOREIGN KEY (TypeID) REFERENCES ClientTypes(TypeID),
    CONSTRAINT UQ_Clients_Phone UNIQUE (Phone)
);

CREATE TABLE SecuredObjects (
    ObjectID INT IDENTITY(1,1) PRIMARY KEY,
    ObjectName NVARCHAR(200) NOT NULL,
    Address NVARCHAR(300) NOT NULL,
    TypeID INT NOT NULL,
    CategoryID INT NOT NULL,
    ClientID INT NOT NULL,
    CONSTRAINT FK_SecuredObjects_Types FOREIGN KEY (TypeID) REFERENCES ObjectTypes(TypeID),
    CONSTRAINT FK_SecuredObjects_Risks FOREIGN KEY (CategoryID) REFERENCES RiskCategories(CategoryID),
    CONSTRAINT FK_SecuredObjects_Clients FOREIGN KEY (ClientID) REFERENCES Clients(ClientID) ON DELETE CASCADE
);

CREATE TABLE SecurityEmployees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    RankID INT NOT NULL,
    HasWeaponPermit BIT NOT NULL DEFAULT 0,
    ContactPhone NVARCHAR(20) NOT NULL,
    HasMedicalClearance BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_SecurityEmployees_Ranks FOREIGN KEY (RankID) REFERENCES EmployeeRanks(RankID),
    CONSTRAINT UQ_SecurityEmployees_Phone UNIQUE (ContactPhone)
);

CREATE TABLE Contracts (
    ContractID INT IDENTITY(1,1) PRIMARY KEY,
    ContractNumber NVARCHAR(50) NOT NULL UNIQUE,
    ClientID INT NOT NULL,
    ObjectID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    MonthlyCost DECIMAL(10,2) NOT NULL CHECK (MonthlyCost > 0),
    StatusID INT NOT NULL,
    CONSTRAINT FK_Contracts_Clients FOREIGN KEY (ClientID) REFERENCES Clients(ClientID) ON DELETE NO ACTION,
    CONSTRAINT FK_Contracts_SecuredObjects FOREIGN KEY (ObjectID) REFERENCES SecuredObjects(ObjectID) ON DELETE CASCADE,
    CONSTRAINT FK_Contracts_Statuses FOREIGN KEY (StatusID) REFERENCES ContractStatuses(StatusID),
    CONSTRAINT CHK_Dates CHECK (EndDate > StartDate)
);

CREATE TABLE DutySchedule (
    ScheduleID INT IDENTITY(1,1) PRIMARY KEY,
    ObjectID INT NOT NULL,
    EmployeeID INT NOT NULL,
    DutyDate DATE NOT NULL,
    ShiftStartTime TIME NOT NULL,
    ShiftEndTime TIME NOT NULL,
    StatusID INT NOT NULL,
    CONSTRAINT FK_DutySchedule_SecuredObjects FOREIGN KEY (ObjectID) REFERENCES SecuredObjects(ObjectID) ON DELETE CASCADE,
    CONSTRAINT FK_DutySchedule_Employees FOREIGN KEY (EmployeeID) REFERENCES SecurityEmployees(EmployeeID) ON DELETE CASCADE,
    CONSTRAINT FK_DutySchedule_Statuses FOREIGN KEY (StatusID) REFERENCES ShiftStatuses(StatusID),
    CONSTRAINT CHK_ShiftTime CHECK (ShiftEndTime > ShiftStartTime)
);

CREATE TABLE AlarmCalls (
    CallID INT IDENTITY(1,1) PRIMARY KEY,
    CallDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    ObjectID INT NOT NULL,
    ReasonID INT NOT NULL,
    ResponseDurationMinutes INT,
    ResultID INT NOT NULL,
    CONSTRAINT FK_AlarmCalls_SecuredObjects FOREIGN KEY (ObjectID) REFERENCES SecuredObjects(ObjectID) ON DELETE CASCADE,
    CONSTRAINT FK_AlarmCalls_Reasons FOREIGN KEY (ReasonID) REFERENCES AlarmReasons(ReasonID),
    CONSTRAINT FK_AlarmCalls_Results FOREIGN KEY (ResultID) REFERENCES CallResults(ResultID)
);
GO