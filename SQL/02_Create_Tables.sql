USE PrimeNestDB;

-- =====================================
-- Dimension Table: Location
-- =====================================
CREATE TABLE DimLocation (
    LocationID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(50),
    State VARCHAR(50),
    Zone VARCHAR(20)
);

-- =====================================
-- Dimension Table: Property
-- =====================================
CREATE TABLE DimProperty (
    PropertyID VARCHAR(10) PRIMARY KEY,
    PropertyName VARCHAR(100),
    PropertyType VARCHAR(50),
    Bedrooms INT,
    Bathrooms INT,
    AreaSqFt INT,
    ConstructionYear INT,
    Status VARCHAR(30),
    LocationID VARCHAR(10),
    FOREIGN KEY (LocationID)
        REFERENCES DimLocation(LocationID)
);

-- =====================================
-- Dimension Table: Customer
-- =====================================
CREATE TABLE DimCustomer (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(100),
    Gender VARCHAR(10),
    Age INT,
    Occupation VARCHAR(50),
    IncomeGroup VARCHAR(30)
);

-- =====================================
-- Dimension Table: Agent
-- =====================================
CREATE TABLE DimAgent (
    AgentID VARCHAR(10) PRIMARY KEY,
    AgentName VARCHAR(100),
    Branch VARCHAR(50),
    ExperienceYears INT,
    CommissionRate DECIMAL(5,3)
);

-- =====================================
-- Dimension Table: Date
-- =====================================
CREATE TABLE DimDate (
    DateID INT PRIMARY KEY,
    Date DATE,
    Day INT,
    Month INT,
    MonthName VARCHAR(20),
    Quarter INT,
    Year INT,
    Weekday VARCHAR(20)
);

-- =====================================
-- Fact Table: Property Transactions
-- =====================================
CREATE TABLE FactPropertyTransactions (
    TransactionID VARCHAR(10) PRIMARY KEY,
    PropertyID VARCHAR(10),
    CustomerID VARCHAR(10),
    AgentID VARCHAR(10),
    DateID INT,
    TransactionType VARCHAR(20),
    SalePrice DECIMAL(15,2),
    MonthlyRent DECIMAL(15,2),
    Commission DECIMAL(15,2),
    DaysOnMarket INT,

    FOREIGN KEY (PropertyID)
        REFERENCES DimProperty(PropertyID),

    FOREIGN KEY (CustomerID)
        REFERENCES DimCustomer(CustomerID),

    FOREIGN KEY (AgentID)
        REFERENCES DimAgent(AgentID),

    FOREIGN KEY (DateID)
        REFERENCES DimDate(DateID)
);