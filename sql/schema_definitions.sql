CREATE DATABASE Banking_Domain;
GO

USE Banking_Domain;
GO

CREATE TABLE dbo.FactTransaction
(
    TransactionKey INT PRIMARY KEY,
    DateKey INT,
    CustomerKey INT,
    AccountKey INT,
    BranchKey INT,
    TransactionID VARCHAR(20),
    TransactionType VARCHAR(50),
    TransactionChannel VARCHAR(50),
    TransactionAmount DECIMAL(18,2),
    BalanceAfterTransaction DECIMAL(18,2),
    TransactionStatus VARCHAR(30)
);

CREATE TABLE dbo.DimAccount
(
    AccountKey INT PRIMARY KEY,
    AccountID VARCHAR(20),
    CustomerKey INT,
    AccountType VARCHAR(50),
    AccountStatus VARCHAR(30),
    OpenDate DATE,
    CreditLimit DECIMAL(18,2),
    InterestRate DECIMAL(10,2)
);

CREATE TABLE dbo.DimBranch
(
    BranchKey INT PRIMARY KEY,
    BranchID VARCHAR(20),
    BranchName VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    Region VARCHAR(30),
    BranchType VARCHAR(30)
);


CREATE TABLE dbo.DimCustomer
(
    CustomerKey INT PRIMARY KEY,
    CustomerID VARCHAR(20),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    City VARCHAR(50),
    State VARCHAR(50),
    Occupation VARCHAR(50),
    CustomerSegment VARCHAR(30),
    AnnualIncome DECIMAL(18,2),
    CustomerSince DATE
);

CREATE TABLE dbo.DimDate
(
    DateKey INT PRIMARY KEY,
    [Date] DATE,
    [Day] INT,
    [Month] INT,
    MonthName VARCHAR(20),
    Quarter VARCHAR(10),
    [Year] INT,
    WeekNumber INT,
    DayName VARCHAR(20),
    IsWeekend VARCHAR(10)
);

select count(*) from dbo.FactTransaction
select count(*) from dbo.DimAccount
select count(*) from dbo.DimBranch
select count(*) from dbo.DimCustomer
select count(*) from dbo.DimDate


