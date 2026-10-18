/*
Create database and schema

why? 
Create a data warehouse after checking if it already exists or not. If it exists, then it is dropped and recreated.
Furthermore, we set up 3 schemas that act like containers. They have been named bronze, silver, and gold.
*/


USE master;
go

--drop if exists
IF EXISTS (SELECT 1 from sys.databases where name = 'DataWarehouse')
BEGIN
  ALTER Database DataWarehouse SET single_user with rollback immediate;
  DROP DATABASE DataWarehouse;
end;
go

--create datawarehouse
create database DataWarehouse;
go

use DataWarehouse;
go

-- create schema
create schema bronze;
go
create schema silver;
go
create schema gold;
go
