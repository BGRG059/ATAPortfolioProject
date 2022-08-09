-- link to data: https://github.com/AllThingsDataWithAngelina/DataSource/blob/main/sales_data_sample.csv


-- Inspecting Data
SELECT top 10 *
FROM   [dbo].[FringpongSales$]


-- Checking Unique Values
SELECT	DISTINCT status
FROM	[dbo].[FringpongSales$] -- plot on Tableau
SELECT	DISTINCT year_id
FROM	[dbo].[FringpongSales$]
SELECT	DISTINCT productline
FROM	[dbo].[FringpongSales$] -- plot on Tableau
SELECT	DISTINCT country
FROM	[dbo].[FringpongSales$] -- plot on Tableau
SELECT	DISTINCT dealsize
FROM	[dbo].[FringpongSales$] -- plot on Tableau
SELECT	DISTINCT territory
FROM	[dbo].[FringpongSales$] -- plot on Tableau
SELECT DISTINCT productline
FROM	[dbo].[FringpongSales$]

--				ANALYSIS				--

-- GROUPING PRODUCTS BY PRODUCTLINE
-- which productline sells the most
SELECT		productline, sum(sales) Revenue
FROM		[dbo].[FringpongSales$]
GROUP BY	productline
ORDER BY	Revenue desc

-- checking which year brought the most amount of revenue
SELECT		year_id, sum(sales) Revenue
FROM		[dbo].[FringpongSales$]
GROUP BY	year_id
ORDER BY	2 desc

SELECT		DISTINCT month_id
FROM		[dbo].[FringpongSales$]
WHERE		year_id = 2005

SELECT		dealsize, round(sum(sales), 2) Revenue
FROM		[dbo].[FringpongSales$]
GROUP BY	dealsize
ORDER BY	2 desc

-- best month for sales in a particular year. revenue generated that month.
-- following query shows results for one year at a time. is it possible to see result for all years from the same query??

SELECT		month_id, sum(sales) Revenue, count(ordernumber) Frequency
FROM		[dbo].[FringpongSales$]
WHERE		year_id = 2004 -- change year to see result for other years.
GROUP BY	month_id
ORDER BY	2 desc

-- From the query above, November generates the most revenue for 2003 and 2004. Following query further analyses which product line
---- brought in the most revenue.
SELECT		month_id, productline, sum(sales) Revenue, count(ordernumber) Frequency
FROM		[dbo].[FringpongSales$]
WHERE		year_id = 2004 AND month_id = 11
GROUP BY	month_id, productline
ORDER BY	3 desc

--------------------------------------------------------------------
--------------------------------------------------------------------

--the following query lets us see the structure of the table. Here we have filtered the result to OrderDate column.
USE PortfolioProject
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='FringpongSales$'
AND column_name = 'orderdate';
-----------------------------------------------------------------------------------------------------------------
-- orderdate column is set as a varchar. so we create a new column
-- and set the date type as datetime.
-- creating a new column called orderdate2
ALTER TABLE [dbo].[FringpongSales$]
ADD orderdate2 datetime;
--	populating new column with data from orderdate column
UPDATE  [dbo].[FringpongSales$]
SET		orderdate2 = orderdate
--------------------------------------------------------------------
--------------------------------------------------------------------

-- who is the best customer (using RFM analysis)
-- Review more on CTE.

DROP TABLE IF EXISTS #rfm -- creating a temp table called #rfm
;WITH rfm AS
(
	SELECT
		customername,
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ordernumber) Frequency,
		max(orderdate2) "Last Order Date",
		(SELECT max(orderdate2) FROM [FringpongSales$]) max_order_date,
		datediff(DAY, max(orderdate2),(SELECT max(orderdate2) FROM [FringpongSales$])) Recency
	FROM dbo.[FringpongSales$]
	GROUP BY customername
),
rfm_calc as
(
SELECT r.*, -- ?? ntile creates 4 different data groups based on their value ??
	ntile(4) OVER (ORDER BY recency desc) rfm_recency,
	ntile(4) OVER (ORDER BY frequency) rfm_frequency,
	ntile(4) OVER (ORDER BY MonetaryValue) rfm_monetary
FROM rfm r
)
SELECT 
	c.*, rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary as varchar) rfm_cell_string
into #rfm
FROM rfm_calc c;

----
SELECT customername, rfm_recency, rfm_frequency, rfm_monetary,
	CASE
		WHEN rfm_cell_string IN (111, 112, 121, 122, 123, 132, 211, 114, 141) THEN 'Lost Customers'
		WHEN rfm_cell_string IN (133, 134, 143, 244, 334, 343, 344, 144) THEN 'Slipping Away, Cannot Lose' -- (Big spenders who haven’t purchased lately) slipping away
		WHEN rfm_cell_string IN (311, 411, 331) THEN 'New Customers'
		WHEN rfm_cell_string IN (222, 223, 233, 322) THEN 'Potential Churners'
		WHEN rfm_cell_string IN (323, 333,321, 422, 332, 432, 423, 421) THEN 'Active' --(Customers who buy often & recently, but at low price points)
		WHEN rfm_cell_string IN (433, 434, 443, 444) THEN 'Loyal'
	END rfm_segment
FROM #rfm

SELECT * FROM #rfm

--------------------------------------------------------------
-- what products are most often sold together
-- Need to learn xml path analysis

--SELECT * FROM [dbo].[FringpongSales$]
--SELECT distinct(ordernumber) FROM [dbo].[FringpongSales$]

SELECT DISTINCT ordernumber, 
		stuff(
				(SELECT ',   ' + productcode
				FROM [dbo].[FringpongSales$] p
				WHERE ordernumber IN
					(
					SELECT ordernumber
					FROM (
						SELECT ordernumber, count(*) rn
						FROM [dbo].[FringpongSales$]
						WHERE status = 'shipped'
						GROUP BY ordernumber
						) m
						WHERE rn = 2 --change value to see more than 2 products that were purchased together
					)
					AND p.ordernumber = s.ordernumber
					
					FOR xml path ('')) -- xml displays data in the same row rather than several column (??)
					, 1 , 1 , ''
				) ProductCodes
FROM [dbo].[FringpongSales$] s

ORDER BY 2 desc




