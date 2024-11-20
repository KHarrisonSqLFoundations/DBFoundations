--*************************************************************************--
-- Title: Assignment06
-- Author: Kenneth_Harrison
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-11-16,Kenneth_Harrison,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Kenneth_Harrison')
	 Begin 
	  Alter Database [Assignment06DB_Kenneth_Harrison] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Kenneth_Harrison;
	 End
	Create Database Assignment06DB_Kenneth_Harrison;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Kenneth_Harrison;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Go
Create View vCategories
	With Schemabinding
	As
	Select CategoryID, CategoryName
	From dbo.Categories;
Go

Select * From vCategories;

Go
Create View vProducts
	With Schemabinding
	AS
	Select ProductID, ProductName, CategoryID, UnitPrice
	From dbo.Products
Go

Select * From vProducts

Select * from Employees

go
Create View vEmployees
	With Schemabinding
	As
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From dbo.Employees
go

Select * from vEmployees

Select * From Inventories;
go

Create View vInventories
	With Schemabinding
	AS
	Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
	From dbo.Inventories;
go

Select * From vInventories


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Products to Public;
Grant Select on vProducts to Public;

Deny Select On Categories to Public;
Grant Select on vCategories to Public;

Deny Select On Employees to Public;
Grant Select on vEmployees to Public;

Deny Select on Inventories to Public;
Grant Select on vInventories to Public;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Select * From vCategories;
Select * From vProducts;

-- To select data and join tables

--Select CategoryName, ProductName, UnitPrice
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID=p.CategoryID
--Go

-- To Order Results

	--Select Top 10000
--		c.CategoryName
--		,p.ProductName
--		,p.UnitPrice
--		From vCategories as c
--		Join vProducts as p
--		On c.CategoryID=p.CategoryID
--		Order By 1,2
----Go

-- Final Code to create view with select statement below to display

go
Create View vProductsByCategories
As
	Select Top 10000
		c.CategoryName
		,p.ProductName
		,p.UnitPrice
		From vCategories as c
		Join vProducts as p
		On c.CategoryID=p.CategoryID
		Order By 1,2

go

-- To display view

Select * From vProductsByCategories;


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--Select * From vProducts
--Select * From vInventories

-- To select data and join tables

--Select 
	--p.ProductName
	--,i.InventoryDate
	--,i.Count
--	From vProducts as p
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--go

-- To Order results

--Select Top 100000
	--p.ProductName
	--,i.InventoryDate
	--,i.Count
--	From vProducts as p
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--  Order by 2, 1, 3
--go

-- To create view Final Code 
Go
Create View vInventoriesByProductsByDates
As
Select Top 100000
	ProductName
	,InventoryDate
	,Count
	From vProducts as p
	Join vInventories as i
	On p.ProductID = i.ProductID
	Order by 2, 1, 3
go

-- To Display results

Select * From vInventoriesByProductsByDates
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Select * From vEmployees;
Select * From vInventories;

-- To select and define data and join tables

--Select
--	InventoryDate
--	,EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	From vEmployees as e
--	Join vInventories as i
--	On e.EmployeeID = i.EmployeeID
--go

-- To Group by Inventory Date

--Select Top 100000
--	InventoryDate,
--	EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	From vEmployees as e
--	Join vInventories as i
--	On e.EmployeeID = i.EmployeeID
--  Group by Group By i.InventoryDate, e.EmployeeFirstName + ' ' + e.EmployeeLastName
--go

-- To Create View and display results  - Final code with select statment below

go
Create View vInventoriesByEmployeesByDates
AS
	Select Top 100000
		InventoryDate,
		EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
		From vEmployees as e
		Join vInventories as i
		On e.EmployeeID = i.EmployeeID
		Group By i.InventoryDate, e.EmployeeFirstName + ' ' + e.EmployeeLastName
	  Order by 1,2
go

Select * From vInventoriesByEmployeesByDates

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!


Select * From vCategories;
Select * From vProducts;
Select * From vInventories;

-- To Select date and join tables

--Select
--	c.CategoryName
--  ,p.ProductName
--  ,i.InventoryDate
--  ,i.Count
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--Go

-- To Order by Category, Product, Date, and Count

--Select Top 100000
--	c.CategoryName
--  ,p.ProductName
--  ,i.InventoryDate
--  ,i.Count
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--  Order By 1, 2, 3, 4
--Go

-- To create view and display results and order by Category, Product, Date and Count

go
Create View vInventoriesByProductsByCategories
As
	Select Top 100000
		 c.CategoryName
		,p.ProductName
		,i.InventoryDate
		,i.Count
		From vCategories as c
		Join vProducts as p
		On c.CategoryID = p.CategoryID
		Join vInventories as i
		On p.ProductID = i.ProductID
	  Order By 1, 2, 3, 4
go

Select * From vInventoriesByProductsByCategories


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Select * From vEmployees;

-- To select and define data and join tables

--Select
--	 c.CategoryName
--	,p.ProductName
--	,i.InventoryDate
--	,i.Count
--	,EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--	Join vEmployees as e
--	On i.EmployeeID = e.EmployeeID
--go

 -- To order results on Inventory Date, Category, Product and Employee!

-- Select Top 100000
--	 c.CategoryName
--	,p.ProductName
--	,i.InventoryDate
--	,i.Count
--	,EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--	Join vEmployees as e
--	On i.EmployeeID = e.EmployeeID
--	Order By 3, 1, 2, 5
--go

--  Final Code to create view

go
Create View vInventoriesByProductsByEmployees
As
	Select Top 100000
	 c.CategoryName
	,p.ProductName
	,i.InventoryDate
	,i.Count
	,EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	From vCategories as c
	Join vProducts as p
	On c.CategoryID = p.CategoryID
	Join vInventories as i
	On p.ProductID = i.ProductID
	Join vEmployees as e
	On i.EmployeeID = e.EmployeeID
	Order By 3, 1, 2, 5
go

Select * From vInventoriesByProductsByEmployees


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Select * From vEmployees;

-- To select and define data and join tables

--Select
--	c.CategoryName
--	,p.ProductName
--	,i.InventoryDate
--	,i.Count
--	,EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--	Join vEmployees as e
--	On i.EmployeeID = e.EmployeeID
--go

-- To limit return to Chai and Chang

--Select
--	c.CategoryName
--	,p.ProductName
--	,i.InventoryDate
--	,i.Count
--	,EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--	Join vEmployees as e
--	On i.EmployeeID = e.EmployeeID
--	Where ProductName = 'Chai'
--	Or ProductName = 'Chang'
--go

-- Final Code to create view and display results

go
Create View vInventoriesForChaiAndChangByEmployees
AS
	Select
		CategoryName
		,ProductName
		,InventoryDate
		,Count
		,EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
		From vCategories as c
		Join vProducts as p
		On c.CategoryID = p.CategoryID
		Join vInventories as i
		On p.ProductID = i.ProductID
		Join vEmployees as e
		On i.EmployeeID = e.EmployeeID
		Where ProductName = 'Chai'
		Or ProductName = 'Chang'
go

Select * From vInventoriesForChaiAndChangByEmployees

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Select * From vEmployees;

-- Select data and self join table

--Select
--	ManagerName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	,EmployeeName = em.EmployeeFirstName + ' ' + em.EmployeeLastName
--	From vEmployees as e
--	Join vEmployees as em
--	on e.EmployeeID = em.ManagerID
--go

-- To Group by manager name

--Select
--	ManagerName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	,EmployeeName = em.EmployeeFirstName + ' ' + em.EmployeeLastName
--	From vEmployees as e
--	Join vEmployees as em
--	on e.EmployeeID = em.ManagerID
--	Group By e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	        ,em.EmployeeFirstName + ' ' + em.EmployeeLastName
--go

-- final code to create view and display results ordered by manager's name

Go
Create View vEmployeesByManager
As
	Select
	ManagerName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	,EmployeeName = em.EmployeeFirstName + ' ' + em.EmployeeLastName
	From vEmployees as e
	Join vEmployees as em
	on e.EmployeeID = em.ManagerID
	Group By e.EmployeeFirstName + ' ' + e.EmployeeLastName
	        ,em.EmployeeFirstName + ' ' + em.EmployeeLastName
go

Select * From vEmployeesByManager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.


Select * From vCategories, vProducts, Inventories, vEmployees

-- To Select and define data

--Select
--	c.CategoryID
--	,c.CategoryName
--	,p.ProductID
--	,p.ProductName
--	,p.UnitPrice
--	,i.InventoryID
--	,i.InventoryDate
--	,i.Count
--	,e.EmployeeID
--	,Employee = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	,Manager = em.EmployeeFirstName + ' ' + em.EmployeeLastName
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID= i.ProductID
--	Join vEmployees as e
--	On i.EmployeeID = i.EmployeeID
--	Join vEmployees as em
--	On e.ManagerID = em.EmployeeID
--Go

	
-- to order by  Category, Product, InventoryID, and Employee.

--Select Top 100000
--	c.CategoryID
--	,c.CategoryName
--	,p.ProductID
--	,p.ProductName
--	,p.UnitPrice
--	,i.InventoryID
--	,i.InventoryDate
--	,i.Count
--	,e.EmployeeID
--	,Employee = e.EmployeeFirstName + ' ' + e.EmployeeLastName
--	,Manager = em.EmployeeFirstName + ' ' + em.EmployeeLastName
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID= i.ProductID
--	Join vEmployees as e
--	On i.EmployeeID = i.EmployeeID
--	Join vEmployees as em
--	On e.ManagerID = em.EmployeeID
--	Order By 2, 4, 6, 10
--Go

-- To Create View and display Results

Go
Create View vInventoriesByProductsByCategoriesByEmployees
AS
Select Top 100000
	c.CategoryID
	,c.CategoryName
	,p.ProductID
	,p.ProductName
	,p.UnitPrice
	,i.InventoryID
	,i.InventoryDate
	,i.Count
	,e.EmployeeID
	,Employee = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	,Manager = em.EmployeeFirstName + ' ' + em.EmployeeLastName
	From vCategories as c
	Join vProducts as p
	On c.CategoryID = p.CategoryID
	Join vInventories as i
	On p.ProductID= i.ProductID
	Join vEmployees as e
	On i.EmployeeID = i.EmployeeID
	Join vEmployees as em
	On e.ManagerID = em.EmployeeID
	Order By 2, 4, 6, 10
Go

Select * From vInventoriesByProductsByCategoriesByEmployees
go

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/