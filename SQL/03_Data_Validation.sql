use PrimeNestDB;

-----------------------------------------------
--Validating Row Counts
-----------------------------------------------

select count(*) as TotalRows From DimLocation;
select count(*) as TotalRows From DimDate;
select count(*) as TotalRows from DimCustomer;
select count(*) as TotalRows from DimAgent;
select count(*) as TotalRows from DimProperty;
select count(*) as TotalRows from FactPropertyTransactions;

-----------------------------------------------
--Checking for NULL Values
-----------------------------------------------

select *
from dimproperty
where PropertyID IS NULL;

select * 
from factpropertytransactions
where PropertyID is NULL
	or CustomerID is NULL
    or AgentID is NULL
    or DateID is NULL;

-----------------------------------------------
--          Checking Duplicate Primary Key
-----------------------------------------------

-----------------------------------------------
--DimProperty
-----------------------------------------------

use primenestdb;

select propertyID, COUNT(*)
from dimproperty
group by PropertyID
having count(*)>1;

-----------------------------------------------
--DimCustomer   
-----------------------------------------------
use primenestdb;

select CustomerID, count(*)
from DimCustomer
Group by CustomerID
Having count(*) > 1;

-----------------------------------------------
--DimAgent  
-----------------------------------------------
use primenestdb;

select AgentID, count(*)
from dimagent
Group by AgentID
Having count(*) > 1;

-----------------------------------------------
--          Validate Foreign Keys
-----------------------------------------------

-----------------------------------------------
--Property
-----------------------------------------------
select 
count(*) as MissingProperty
from factpropertytransactions f
left join dimproperty p on f.PropertyID = p.PropertyID
where p.PropertyID is NULL;

-----------------------------------------------
--Customer
-----------------------------------------------
select 
count(*) as MissingCustomer
from factpropertytransactions f
left join dimcustomer c
ON f.CustomerID = c.CustomerID
where c.CustomerID is NULL;

-----------------------------------------------
--Agent
-----------------------------------------------
select 
count(*) as MissingAgent

from factpropertytransactions f 
left join dimagent a on a.AgentID = f.AgentID
where a.AgentID is NULL;

-----------------------------------------------
--Date
-----------------------------------------------
Select
count(*) as MissingDate
from factpropertytransactions f
left join dimdate d on d.DateID = f.DateID
where d.DateID is NULL;

-----------------------------------------------
-- Checking Sale Range
-----------------------------------------------
select
min(salePrice) as MinimumPrice,
max(SalePrice) as MaximumPrice,
avg(SalePrice) as AveragePrice

from factpropertytransactions;

-----------------------------------------------
-- Transaction Status Distribution
-----------------------------------------------
select TransactionType,
count(*) as TotalTransactions
from factpropertytransactions
group by TransactionType;