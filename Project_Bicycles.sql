---Data Panel: SalesOrderID, OrderDate, SubTotal, StandardCost, OrderQty, LineTotal,UnitPrice,UnitPriceDiscount,ProductName, CategoryName

---***   Integrity data ***
--SalesOrderID-Continuous values
--OrderDate-Categorical values
--ProductID --Continuous
--StandardCost--Continuous
--OrderQty--Categorical
---LineTotal--continuous
--Profit--Continuos
--*UnitPrice-Continuous
--UnitPriceDiscount-categorical
--ProductName--Categorical values
--CategoryName-Categorical values

SELECT OrderDate,SubTotal
FROM Sales.SalesOrderHeader

--Testing the basic variables

--1. Integrity Categorical values
--Check for NULL values
SELECT OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate is null
;
SELECT OrderQty
FROM Sales.SalesOrderDetail
WHERE OrderQty is null
;
SELECT UnitPriceDiscount
FROM Sales.SalesOrderDetail
WHERE UnitPriceDiscount is null
;
SELECT [Name]
FROM Production.ProductCategory
WHERE [Name] is null
;
SELECT [Name]
FROM Production.Product
WHERE [Name] is null

/*Check the values for:Type of information Incorrect or illogical values */
SELECT OrderDate
FROM Sales.SalesOrderHeader
--where OrderDate = 0
;
SELECT OrderQty
FROM Sales.SalesOrderDetail
;
SELECT UnitPriceDiscount
FROM Sales.SalesOrderDetail
--There are lot of 0 values (118035)

SELECT count (UnitPriceDiscount)
FROM Sales.SalesOrderDetail
WHERE UnitPriceDiscount =0
;
SELECT [Name]
FROM Production.ProductCategory
;
SELECT [Name]
FROM Production.Product

/*Feasibility checks : Quantity of values by category*/
--The distribution is logical and reasonable
--All the data are integers
SELECT OrderQty,
	count (*) NoOfTimes
FROM Sales.SalesOrderDetail
GROUP BY OrderQty
ORDER BY OrderQty

SELECT UnitPriceDiscount,
      count(*) NoOfTimes
FROM Sales.SalesOrderDetail
GROUP BY UnitPriceDiscount
ORDER BY UnitPriceDiscount



--2.    Integrity Check of Continuous values
--Check for NULL values
SELECT SalesOrderID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID is null
;
SELECT ProductID
FROM Sales.SalesOrderDetail
WHERE ProductID is null
;
SELECT StandardCost
FROM Production.Product
WHERE StandardCost is NULL
;
SELECT LineTotal
FROM Sales.SalesOrderDetail
WHERE LineTotal is NULL
;
SELECT UnitPrice
FROM Sales.SalesOrderDetail
WHERE UnitPrice is NULL

/* Check the values for:Data error Exceptional or extreme values Matching information type */
select SalesOrderID
from Sales.SalesOrderDetail
;
select ProductID
from Sales.SalesOrderDetail
;
select StandardCost
from Production.Product
where StandardCost = '0'
--There are 200 records with 0 StandardCost

select StandardCost
from #Panel_Revenue_Profit 
where StandardCost = '0'

;
select LineTotal
from Sales.SalesOrderDetail
--There are no negative values and errors 

select UnitPrice
from Sales.SalesOrderDetail
where UnitPrice =0
--There are no negative , '0' values and errors 

--Feasibility

select top 10  StandardCost
from Production.Product
order by StandardCost

select top 10  StandardCost
from Production.Product
order by StandardCost desc

;
select top 10 LineTotal
from Sales.SalesOrderDetail
order by LineTotal 

select top 10 LineTotal
from Sales.SalesOrderDetail
order by LineTotal desc

;
select top 10 UnitPrice
from Sales.SalesOrderDetail
order by UnitPrice

select top 10 UnitPrice
from Sales.SalesOrderDetail
order by UnitPrice desc


---Creating a data panel
drop table if exists #Panel_Revenue_Profit
select  d.SalesOrderID, h.OrderDate, d.ProductID, p.StandardCost, d.OrderQty, d.LineTotal,
		d.LineTotal - (p.StandardCost * d.OrderQty) as Profit, 
		d.UnitPrice, d.UnitPriceDiscount as UnitDiscountPercent, d.UnitPrice*UnitPriceDiscount as UnitDiscountAmount,
		c.[Name] as CategoryName, p.[Name] as ProductName
into #Panel_Revenue_Profit
from  Sales.SalesOrderHeader h
 left join Sales.SalesOrderDetail d
 on h.SalesOrderID = d.SalesOrderID
  left join Production.Product p
   on d.ProductID = p.ProductID
   left join Production.ProductSubcategory s
     on p.ProductSubcategoryID = s.ProductSubcategoryID
	   left join Production.ProductCategory c
	     on s.ProductCategoryID = c.ProductCategoryID
	
select *
from #Panel_Revenue_Profit


---Panel Verification
select StandardCost
from #Panel_Revenue_Profit 
where StandardCost = '0'
--There are no '0' values

select ProductID, StandardCost, UnitPrice, UnitDiscountPercent, UnitDiscountAmount, Profit
from #Panel_Revenue_Profit
where Profit<0
order by ProductID

select ProductID
from #Panel_Revenue_Profit
where Profit<0
group by ProductID
order by ProductID
--The total of 121 Products are with negative values

-----1.Is the revenue seasonal?
------Total Monthly Revenue  
select Year (OrderDate) Year, 
	   MONTH(OrderDate) [Month],
	   FORMAT (SUM (LineTotal),'#,###' ) TotalRevenue
from #Panel_Revenue_Profit 
group by Year(OrderDate),MONTH(OrderDate)
order by Year(OrderDate), MONTH(OrderDate)

--Ranking
select Year (OrderDate) Year, 
	   MONTH(OrderDate) [Month],
	  FORMAT (SUM (LineTotal),'#,###' ) TotalRevenue,	  
	  RANK() Over (partition by Year(OrderDate) order by sum (LineTotal) desc ) as MonthYearRank,
      SUM ( OrderQty) NoOfItemsSold
from #Panel_Revenue_Profit 
group by Year(OrderDate),MONTH(OrderDate)
order by MonthYearRank 
--June, July -2012-2013 the Highest Monthly Revenue
--February -2012-2013- the Lowest Monthly Revenue

--Checking the results
select Year (OrderDate) as Year,
       Month(OrderDate) as Month,
	   SUM (SubTotal) as TotalAmount,	
	   RANK() Over (partition by Year(OrderDate) order by sum (SubTotal) desc ) as MonthYearRank
from Sales.SalesOrderHeader
group by Year (OrderDate),Month(OrderDate)
order by MonthYearRank

-------Total Monthly Profit  
select Year (OrderDate) Year, 
		Month( OrderDate) as Month,
		FORMAT( SUM (Profit),'#,###') as TotalProfit
from #Panel_Revenue_Profit 
group by Year (OrderDate), Month (OrderDate)
order by Year , Month
 --There are negative records !!!

 --Ranking
select Year (OrderDate) Year, 
		Month( OrderDate) as Month,
		FORMAT( SUM (Profit),'#,###') as TotalProfit,
		RANK() Over (partition by Year(OrderDate) order by SUM (Profit) desc ) as MonthRank,
		SUM ( OrderQty) NoOfItemsSold
from #Panel_Revenue_Profit 
group by Year (OrderDate), Month (OrderDate)
order by MonthRank
---Most Profitable Month - November
---Less Profitable Months -Apr,May

--Checking the results
select Year (h.OrderDate) as Year,
       Month(h.OrderDate) as Month,
	   SUM (d.LineTotal- p.StandardCost* d.OrderQty) as TotalProfit,	
	    RANK() Over (partition by Year(OrderDate) order by SUM (d.LineTotal- p.StandardCost* d.OrderQty) desc ) as MonthRank
from Production.Product p join Sales.SalesOrderDetail d
on P.ProductID =d.ProductID
join Sales.SalesOrderHeader h
 on d.SalesOrderID = h.SalesOrderID
group by Year (h.OrderDate), Month (h.OrderDate)
order by MonthRank

--------Total Quarterly Revenue, 
--!! For 2011- Quarter 2 is incomplete (there are only two months available:5,6)

;
select Year (OrderDate) Year, 
	 DATEPART(quarter ,OrderDate) Quarter, 
	 FORMAT(SUM (LineTotal),'#,###') TotalRevenue,
	 SUM ( OrderQty) NoOfItemsSold
from #Panel_Revenue_Profit 
group by Year(OrderDate), DATEPART(quarter ,OrderDate)
having DATEPART(quarter ,OrderDate) <> 2 or YEAR (OrderDate) <>2011
order by Year(OrderDate), DATEPART(quarter ,OrderDate)

--Ranking
select Year (OrderDate) Year, 
	   DATEPART(quarter ,OrderDate) Quarter, 
	   FORMAT(SUM (LineTotal),'#,###') TotalRevenue,
	   RANK() Over ( partition by Year(OrderDate) order by SUM (LineTotal) desc ) as QuarterRank,
	   SUM ( OrderQty) NoOfItemsSold
from #Panel_Revenue_Profit 
group by Year(OrderDate), DATEPART(quarter ,OrderDate)
having DATEPART(quarter ,OrderDate) <> 2 or YEAR (OrderDate) <>2011
order by QuarterRank
--Quarter 3 (Jul-Sept) The Highest Revenue Quarter
--Quarter 1 (Jan-Mar) The Lowest Revenue Quarter 2012-2013

--Checking the results
select Year (OrderDate) Year, 
	   DATEPART(quarter ,OrderDate) Quarter, 
	   FORMAT(SUM (SubTotal),'#,###') TotalRevenue,
	   RANK() Over ( partition by Year(OrderDate) order by SUM (SubTotal) desc ) as QuarterRank
from Sales.SalesOrderHeader
group by Year(OrderDate), DATEPART(quarter ,OrderDate)
having DATEPART(quarter ,OrderDate) <> 2 or YEAR (OrderDate) <>2011
order by QuarterRank

------Total Quartely Profit, 2011- Quarter 2 incomplet -nu se include
--where Year (OrderDate) <> 2011 or Month (OrderDate)  not in (5,6)
select Year (OrderDate) Year, 
	   DATEPART(quarter ,OrderDate) Quarter, 
	   FORMAT( SUM (Profit),'#,###') as TotalProfit,
	   SUM ( OrderQty) NoOfItemsSold
from #Panel_Revenue_Profit 
group by Year(OrderDate), DATEPART(quarter ,OrderDate)
having DATEPART(quarter ,OrderDate) <> 2 or YEAR (OrderDate) <>2011
order by Year(OrderDate), DATEPART(quarter ,OrderDate)
 --There is a negative value !!!

 --Ranking
 select Year (OrderDate) Year, 
	    DATEPART(quarter ,OrderDate) Quarter, 
	    FORMAT( SUM (Profit),'#,###') as TotalProfit,
	    RANK() Over (partition by Year(OrderDate) order by SUM (Profit) desc ) as QuarterRank,
	    SUM ( OrderQty) NoOfItemsSold
from #Panel_Revenue_Profit 
where Year (OrderDate) <> 2011 or Month (OrderDate)  not in (5,6)
group by Year(OrderDate), DATEPART(quarter ,OrderDate)
order by QuarterRank
---The Most Profitable Quarter -4 (Oct-Dec)
--The Less Profitable Quarter -2 (Apr-Jul)

--Checking the results
select Year (h.OrderDate) as Year,
       Month(h.OrderDate) as Month,
	   SUM (d.LineTotal- p.StandardCost* d.OrderQty) as TotalProfit,	
	   RANK() Over ( partition by Year(OrderDate) order by SUM (d.LineTotal- p.StandardCost* d.OrderQty) desc ) as MonthRank
from Production.Product p join Sales.SalesOrderDetail d
on P.ProductID =d.ProductID
join Sales.SalesOrderHeader h
 on d.SalesOrderID = h.SalesOrderID
group by Year (h.OrderDate), Month (h.OrderDate)
order by MonthRank

----2. Is there an upward or downward trend in the company's data over the months and years?
---Total Yearly Revenue for 2012 and 2013. !! 2011 and 2014 are incomplete in months  Can not be compared.
select Year (OrderDate) Year, 
	  FORMAT (SUM (LineTotal),'#,###' ) TotalRevenue
from #Panel_Revenue_Profit 
group by Year(OrderDate)
order by Year(OrderDate)

---Total Yearly Revenue  for 2012 and 2013
select Year (OrderDate) Year, 
	  FORMAT (SUM (LineTotal),'#,###' ) TotalRevenue,
	   RANK() Over ( order by SUM (LineTotal) desc ) as YearlyRank
from #Panel_Revenue_Profit 
where Year(OrderDate) between '2012' and '2013'
group by Year(OrderDate)

---Total Yearly Profit   for 2012 and 2013
select Year (OrderDate) Year, 
	  FORMAT (SUM (Profit),'#,###' ) TotalProfit,
	  RANK() Over ( order by SUM (Profit) desc ) as YearlyRank,
	  SUM (OrderQty) as TotalItems
from #Panel_Revenue_Profit 
where Year(OrderDate) between '2012' and '2013'
group by Year(OrderDate)

-------Number Of Transactions 
--2012,2013
select Year (OrderDate) Year,
	   COUNT ( distinct SalesOrderID) NoOfTransactions
from #Panel_Revenue_Profit
where Year(OrderDate) between '2012' and '2013'
group by Year(OrderDate)

--No Of Transactions -3915, 14182
--Checking
select count (SalesOrderID)
from Sales.SalesOrderHeader
where Year(OrderDate) =2012
union
select count (SalesOrderID)
from Sales.SalesOrderHeader
where Year(OrderDate) =2013

-------Number Of Items Ordered
--2012,2013 
select Year (OrderDate) Year,
       SUM ( OrderQty) NoOfItems
from #Panel_Revenue_Profit
where Year(OrderDate) between '2012' and '2013'
group by Year(OrderDate)

--Number Of Items-68579
--Number Of Items-131788
--Checking
select SUM ( OrderQty) NoOfItems
from Sales.SalesOrderDetail d
    left join Sales.SalesOrderHeader h
    on d.SalesOrderID = h.SalesOrderID
where Year(OrderDate) =2012
union
select SUM ( OrderQty) NoOfItems
from Sales.SalesOrderDetail d
    left join Sales.SalesOrderHeader h
    on d.SalesOrderID = h.SalesOrderID
where Year(OrderDate) =2013

--3. How discounts affect the company’s profitability ?
--- Average unit price discounts per month
select Year (OrderDate) Year, 
		Month(OrderDate) as Month, 
		AVG (UnitDiscountPercent) as AvgDiscount, 
		SUM (UnitDiscountAmount) as AmountDiscount,
		RANK() Over (partition by Year(OrderDate) order by SUM (UnitDiscountAmount) desc ) as MonthRank
from #Panel_Revenue_Profit
group by Year (OrderDate), Month (OrderDate)
order by MonthRank 
---The Less Profitable Month –April 2012 has one of the Highest Amount of Discount(cash discount)
----November with the highest profit has less amount of discount (cash discount). 

------Average unit price discounts per Quarter
select Year (OrderDate) Year, 
		DATEPART(quarter ,OrderDate) Quarter, 
		AVG (UnitDiscountPercent) as AvgDiscount, 
		SUM (UnitDiscountAmount) as AmountDiscount,
		RANK() Over (partition by Year(OrderDate) order by SUM (UnitDiscountAmount) desc ) as QuarterRank
from #Panel_Revenue_Profit
where Year (OrderDate) <> 2011 or Month (OrderDate)  not in (5,6)
group by Year(OrderDate), DATEPART(quarter ,OrderDate)
order by QuarterRank
--Quarter 2 that is the less profitable has the highest amount of discount.
---Quarter 4 that is the highest profitable has the less amount of discount.

--4.What are the top most and less sold products?
--The most sold Product Category
select  CategoryName, 
		SUM ( OrderQty) as NoOfItemsSold,
		RANK () over (order by SUM ( OrderQty) desc) SalesRank, 
		FORMAT(SUM (LineTotal) ,'#,###') TotalRevenue,
		RANK () over (order by SUM (LineTotal) desc) RevenueRank,
		FORMAT(SUM (Profit), '#,###') as LineProfit,
		RANK () over (order by SUM (Profit) desc) ProfitRank,
		FORMAT(SUM (UnitDiscountAmount),'#,###') as AmountDiscount,
		RANK () over (order by SUM (UnitDiscountAmount) desc) AmountDiscountRank,
		AVG (UnitDiscountPercent) as AvgDiscount
 from #Panel_Revenue_Profit
 group by CategoryName

 --Category Bikes is the most sold from all categories and has the highest revenue, profit and amount of discount.

 --Checking
 select  c.[Name], 
		SUM ( d.OrderQty) as NoOfItemsSold,
		RANK () over (order by SUM ( d.OrderQty) desc) SalesRank, 
		FORMAT(SUM (d.LineTotal) ,'#,###') TotalAmount,
		RANK () over (order by SUM (d.LineTotal) desc) AmountRank,
		FORMAT(SUM ( d.LineTotal - p.StandardCost * d.OrderQty),'#,###') as Profit,
		RANK () over (order by SUM ( d.LineTotal - p.StandardCost * d.OrderQty) desc) ProfitRank
from Sales.SalesOrderDetail d
  left join Production.Product p
   on d.ProductID = p.ProductID
   left join Production.ProductSubcategory s
     on p.ProductSubcategoryID = s.ProductSubcategoryID
	   left join Production.ProductCategory c
	     on s.ProductCategoryID = c.ProductCategoryID
group by c.[Name]

 --Top 10 sold products from category Bikes
 select top 10 ProductID,
			CategoryName,
			ProductName,
			SUM(OrderQty) as NoOfItemsSold
from #Panel_Revenue_Profit
where CategoryName= 'Bikes'
group by ProductID ,CategoryName, ProductName
order by NoOfItemsSold desc
--The most sold products from category Bikes are Mountain-200 Black and Silver, Road-650 Black and Red

--Top 10 unsold products from category Bikes
 select top 10 ProductID,
			CategoryName,
			ProductName,
			SUM(OrderQty) as NoOfItemsSold
from #Panel_Revenue_Profit
where CategoryName= 'Bikes'
group by ProductID ,CategoryName, ProductName
order by NoOfItemsSold asc
--The most unsold products from category Bikes are Road-450 Red, Mountain-500 Black, Touring-3000 Blue and Yellow, Touring-2000 Blue

--Top 10 sold Products
select top 10 ProductID,
			CategoryName,
			ProductName,
			SUM(OrderQty) as NoOfItemsSold
from #Panel_Revenue_Profit
group by ProductID ,CategoryName, ProductName
order by NoOfItemsSold desc
--The most sold items are from category Clothing and Accessories.

--Checking
select top 10 d.ProductID, c.[Name],p.[Name], sum (d.OrderQty) as NoOfItemsSold
from Sales.SalesOrderDetail d
  left join Production.Product p
   on d.ProductID = p.ProductID
   left join Production.ProductSubcategory s
     on p.ProductSubcategoryID = s.ProductSubcategoryID
	   left join Production.ProductCategory c
	     on s.ProductCategoryID = c.ProductCategoryID
group by d.ProductID ,p.[Name] ,c.[Name]
order by NoOfItemsSold desc

--Top 10 unsold Products
select top 10 ProductID,
			CategoryName,
			ProductName,
			SUM(OrderQty) as NoOfItemsSold
from #Panel_Revenue_Profit
group by ProductID ,CategoryName, ProductName
order by NoOfItemsSold asc
--The most unsold items are from category Components.
--Check
select top 10 d.ProductID,  c.[Name], p.[Name], sum (d.OrderQty) as NoOfItemsSold
from Sales.SalesOrderDetail d
  left join Production.Product p
   on d.ProductID = p.ProductID
   left join Production.ProductSubcategory s
     on p.ProductSubcategoryID = s.ProductSubcategoryID
	   left join Production.ProductCategory c
	     on s.ProductCategoryID = c.ProductCategoryID
group by d.ProductID ,p.[Name] ,c.[Name]
order by NoOfItemsSold asc
