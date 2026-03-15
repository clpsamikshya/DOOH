CREATE DATABASE Samikshya_Dooh;
GO

USE Samikshya_Dooh
GO

-- Create Schemas
CREATE SCHEMA core;
GO

CREATE SCHEMA inv;
GO


-- =========================
-- Tenant Table
-- =========================
CREATE TABLE core.Tenant(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(50) NOT NULL,
    Location NVARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    IsActive BIT DEFAULT 1,
    IsDeleted BIT DEFAULT 0
);


-- =========================
-- User Table
-- =========================
CREATE TABLE core.[User](
    Id INT PRIMARY KEY IDENTITY(101,1),
    UserName NVARCHAR(50) NOT NULL UNIQUE,
    [Password] VARBINARY(256) NOT NULL,
    Email NVARCHAR(70) NOT NULL UNIQUE,
    TenantId INT,
    IsActive BIT DEFAULT 1,
    IsDeleted BIT DEFAULT 0,

    FOREIGN KEY (TenantId) REFERENCES core.Tenant(Id)
);


-- =========================
-- UserInfo Table
-- =========================
CREATE TABLE core.UserInfo(
    UserId INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    MiddleName NVARCHAR(50),
    LastName NVARCHAR(50),
    Dob DATE,
    Gender INT,
    ContactNo NVARCHAR(20),
    CreatedBy INT NOT NULL,
    IsDeleted BIT DEFAULT 0,

    FOREIGN KEY (UserId) REFERENCES core.[User](Id)
);


-- =========================
-- Screen Table
-- =========================
CREATE TABLE inv.Screen(
    Id INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Address VARCHAR(50) NOT NULL,
    TenantId INT,
    IsActive BIT DEFAULT 1,
    CostPerContact DECIMAL(18,2),
    IsDeleted BIT DEFAULT 0,

    FOREIGN KEY (TenantId) REFERENCES core.Tenant(Id)
);


-- =========================
-- Insert Tenant Data
-- =========================
INSERT INTO core.Tenant (Name, Location, Country, IsActive)
VALUES
('NepalTech', 'Kathmandu', 'Nepal', 1),
('GlobalSoft', 'Delhi', 'India', 0),
('AsiaSolutions', 'Bangkok', 'Thailand', 0),
('EuroSystems', 'Berlin', 'Germany', 1),
('OceanicApps', 'Sydney', 'Australia', 0);


-- =========================
-- Insert User Data
-- =========================
INSERT INTO core.[User] (UserName, [Password], Email, TenantId, IsActive)
VALUES
('samikshya', 0x1234, 'samikshya@temp.com', 1, 1),
('ram', 0x1234, 'ram@temp.com', 1, 0),
('xyz', 0x1234, 'xyz@temp.com', 2, 0),
('abc', 0x1234, 'abc@temp.com', 2, 1);


-- =========================
-- Insert UserInfo Data
-- =========================
INSERT INTO core.UserInfo (UserId, FirstName, LastName, Dob, Gender, ContactNo, CreatedBy)
VALUES
(101, 'Samikshya', 'Khatiwada', '2000-05-10', 1, '9800000001', 101),
(102, 'Ram', 'Sharma', '1998-08-15', 1, '9800000002', 101),
(103, 'XYZ', 'ABC', '1995-03-12', 1, '9800000003', 101),
(104, 'ABC', 'XYZ', '1997-11-20', 2, '9800000004', 101);


-- =========================
-- Insert Screen Data
-- =========================
INSERT INTO inv.Screen (Id, Name, Address, TenantId, IsActive, CostPerContact)
VALUES
(1,'Screen A','Kathmandu',1,1,200.00),
(2,'Screen B','Kathmandu',1,0,520.50),
(3,'Screen C','Delhi',2,1,610.75),
(4,'Screen D','Bangkok',3,0,520.00),
(5,'Screen E','Berlin',4,1,200.00);


-- =========================
-- Sample Select Queries
-- =========================

SELECT * FROM core.Tenant;
SELECT * FROM core.[User];
SELECT * FROM core.UserInfo;
SELECT * FROM inv.Screen;