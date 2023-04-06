-- Filtering out the aggregated continent data and calculating the total cases and total mortalities. 

SELECT 
SUM(new_cases) as total_cases, 
SUM(CAST(new_deaths as int)) as total_deaths, 
(SUM(CAST(new_deaths as int)) / SUM(new_cases)) * 100 as MortalityRate
FROM 
PortfolioProject..CovidDeaths
WHERE 
continent is NULL AND location != 'World' AND location != 'International' AND location != 'European Union' AND location != 'High Income' AND location != 'Lower middle income' AND location != 'Low income' AND location != 'Upper middle income'  
ORDER BY 
1,
2


-- Verifying that the aggregated continent data has been filtered out. 

SELECT 
SUM(new_cases) as total_cases, 
SUM(CAST(new_deaths as int)) as total_deaths, 
(SUM(CAST(new_deaths as int)) / SUM(new_cases)) * 100 as MortalityRate
FROM 
PortfolioProject..CovidDeaths
WHERE 
location = 'World'
ORDER BY 
1,
2


-- Grouping total aggregates by continent. 

SELECT
location,
population,
MAX(total_cases) AS HighestCaseLoad,
MAX((total_cases/population))*100 AS CaseLoadRate
FROM 
PortfolioProject..CovidDeaths
WHERE 
continent is NULL AND location != 'World' AND location != 'International' AND location != 'European Union' AND location != 'High Income' AND location != 'Lower middle income' AND location != 'Low income' AND location != 'Upper middle income'   
GROUP BY
location,
population
ORDER BY
CaseLoadRate DESC
  

-- Grouping totals by country. 

SELECT
location,
population,
MAX(total_cases) AS HighestCaseLoad,
MAX((total_cases/population))*100 AS CaseLoadRate
FROM 
PortfolioProject..CovidDeaths
WHERE 
location != 'World' AND location != 'International' AND location != 'European Union' AND location != 'High Income' AND location != 'Lower middle income' AND location != 'Low income' AND location != 'Upper middle income'   
GROUP BY
location,
population
ORDER BY
CaseLoadRate DESC
  
  
--- Checking for duplicates and confirming the number of countries as well as the total count of daily report entries per country. 
 
SELECT location, COUNT(*) AS TotalEntries
FROM PortfolioProject..CovidDeaths
WHERE 
location != 'World' AND location != 'International' AND location != 'European Union' AND location != 'High Income' AND location != 'Lower middle income' AND location != 'Low income' AND location != 'Upper middle income' AND location != 'Africa' AND location != 'Oceana' AND location != 'Europe' AND location != 'North America' AND location != 'South America' AND location != 'Asia'    
GROUP BY location
HAVING COUNT(*) > 1;


--- Filtering out countries with NULL values in the Total Cases column. These are countries which have not reported their Covid-19 data to the World Health Organisation.

SELECT
location,
population,
MAX(total_cases) AS HighestCaseLoad,
MAX((total_cases/population))*100 AS CaseLoadRate
FROM 
PortfolioProject..CovidDeaths
WHERE 
total_cases IS NOT NULL AND continent is NOT NULL OR location != 'World' AND location != 'International' AND location != 'European Union' AND location != 'High Income' AND location != 'Lower middle income' AND location != 'Low income' AND location != 'Upper middle income' AND location != 'Africa' AND location != 'Oceana' AND location != 'Europe' AND location != 'North America' AND location != 'South America' AND location != 'Asia'    
GROUP BY
location,
population
ORDER BY
CaseLoadRate DESC
  
  
-- All unfiltered daily country reports, logged by date. 
  
SELECT
location,
population,
date,
MAX(total_cases) AS HighestCaseLoad,
MAX((total_cases/population))*100 AS CaseLoadRate
FROM 
PortfolioProject..CovidDeaths
WHERE 
total_cases IS NOT NULL OR location != 'World' AND location != 'International' AND location != 'European Union' AND location != 'High Income' AND location != 'Lower middle income' AND location != 'Low income' AND location != 'Upper middle income' AND location != 'Africa' AND location != 'Oceana' AND location != 'Europe' AND location != 'North America' AND location != 'South America' AND location != 'Asia'    
GROUP BY
location,
population,
date
ORDER BY
CaseLoadRate DESC
  
  
-- Changed date format from DATETIME or TIMESTAMP data type to a year-month-day format.
SELECT
location,
population,
CONVERT(varchar, date, 23) AS date_new,
MAX(total_cases) AS HighestCaseLoad,
MAX((total_cases/population))*100 AS CaseLoadRate
FROM 
PortfolioProject..CovidDeaths
WHERE 
total_cases IS NOT NULL OR location != 'World' AND location != 'International' AND location != 'European Union' AND location != 'High Income' AND location != 'Lower middle income' AND location != 'Low income' AND location != 'Upper middle income' AND location != 'Africa' AND location != 'Oceana' AND location != 'Europe' AND location != 'North America' AND location != 'South America' AND location != 'Asia'    
GROUP BY
location,
population,
date
ORDER BY
CaseLoadRate DESC
