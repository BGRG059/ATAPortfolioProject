
-- Link to data: OfficeSupplies @ www.artofvisualization.com/pages/tableau

SELECT	*
FROM	[dbo].['P1-OfficeSupplies$']

-- Displays total units sold by reps in a descending order
SELECT		rep, sum(units) TotUnitsSold
FROM		[dbo].['P1-OfficeSupplies$']
GROUP BY	rep
ORDER BY	TotUnitsSold desc

-- Displays total units sold by reps. Here reps are grouped according to their region.
SELECT		region, rep, sum(units) TotUnitsSold
FROM		[dbo].['P1-OfficeSupplies$']
GROUP BY	rep, region
ORDER BY	region, TotUnitsSold desc

-- Calculating total revenue
SELECT		sum(Round(Units*"UNIT PRICE",0)) TotalSales
FROM		[dbo].['P1-OfficeSupplies$']
GROUP BY	rep, region

-- Displays total revenue per  reps with highest on top. Here reps are grouped according to their region.
-- Problem to solve:
--      Applying Concat('$ ', Sum(Round(Units*"UNIT PRICE",0))) 
--      to display $ in front of tot sales figures doesn't allow tot sales column to be displayed in desc/asc order.
SELECT		region, rep, Sum(Round(Units*"UNIT PRICE",0)) AS TotalSales
FROM		[dbo].['P1-OfficeSupplies$']
GROUP BY	rep, region
ORDER BY	region, TotalSales desc
