-- Confirming that all rows of data have been uploaded from CovidDeaths spreadsheet.

SELECT
  * 
FROM
  `PortfolioProject.CovidDeaths`
ORDER BY
  3,
  4 
  

-- Confirming that all rows have been loaded to BigQuery from CovidVaccinations spreadsheet.

SELECT
  * 
FROM
  `PortfolioProject.CovidVaccinations`
ORDER BY
  3,
  4 
  
  
-- Selecting the data for further exploration, ordered by Location and Date columns for ease of reference. This renders out a series of daily reports on the total cases and deaths per country. Each country has several rows of data reports, dating back to the first known case in that particular country. 

SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population --
FROM
  `PortfolioProject.CovidDeaths`
WHERE 
continent is not NULL
ORDER BY
  1,
  2 
  

-- To understand the impact of the Covid-19 pandemic in each country, I need to aggregate data for each country. This query calculates the Total Cases vs Total Deaths for each country and creates a new column called Mortality Rate per country. This provided me with a current Mortality Rate for each country. 

SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS MortalityRate
FROM
  `PortfolioProject.CovidDeaths`
WHERE 
continent is not NULL
ORDER BY
  1,
  2 
  

-- Calculating Total cases per the Population and creating a new column called Case Load. This provided me the percentage of each country's population which was infected with Covid-19.  

SELECT
  location,
  date,
  population,
  total_cases,
  (total_cases/population)*100 AS CaseLoad
FROM
  `PortfolioProject.CovidDeaths`
WHERE 
continent is not NULL
ORDER BY
  1,
  2 
  

-- Which countries have the highest case load compared to population? This query calculates the percentage case load for each country and creates a new column called Percentage Cases. This provided me with a current percentage of cases for each country, ordered by the number of cases in descending order. 

SELECT
  location,
  population,
  MAX(total_cases) AS HighestCaseLoad,
  MAX((total_cases/population))*100 AS CaseLoadRate
FROM
  `PortfolioProject.CovidDeaths`
WHERE 
continent is not NULL
GROUP BY
  location,
  population
ORDER BY
  CaseLoadRate DESC
  

-- Which countries have the highest mortality rate compared to population? This query calculates the mortality rate for each country and creates a new column called Total Mortality. This provided me with a mortality rate for each country, in descending order. 

SELECT
  location,
  MAX(total_deaths) AS TotalMortalities,
FROM
  `PortfolioProject.CovidDeaths`
WHERE 
continent is not NULL
GROUP BY
  location
ORDER BY
  TotalMortalities DESC
  

-- Now observing an issue with the data where there are inaccurate categories in the Location column such as World, South America, Europe, Africa. These are aggregating data from several countries and thus would skew the comparisons with country data. 

-- And certain entries in the Continent column are NULL values. To filter out entries where the Location is a continent, I filtered out data with the IS NOT NULL operator.

SELECT
  *
FROM
  `PortfolioProject.CovidDeaths`
WHERE
  continent is not NULL
ORDER BY
  3,
  4
  

-- Which continents have the highest mortality rate compared to population? This query calculates the mortality rate for each continent. This provided me with a mortality rate for each continent, in descending order. 

SELECT
  location,
  MAX(total_deaths) AS TotalMortalities,
FROM
  `PortfolioProject.CovidDeaths`
WHERE 
continent is NULL AND location != 'World' AND location != 'International' AND location != 'European Union'
GROUP BY
  location
ORDER BY
  TotalMortalities DESC
  
  -- To understand the Global impact of the Covid-19 pandemic to date, we need to add up all of the new cases and new deaths per day over the entire period of the dataset. 

SELECT
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  SUM(new_deaths)/SUM(new_cases)*100 AS MortalityRate
FROM
  `PortfolioProject.CovidDeaths`
WHERE 
continent is not NULL
ORDER BY
  1,
  2 
  
-- For further analysis, we need to JOIN the Covid.Deaths and Covid.Vaccines tables together. We'll join these two tables on Location and Date. 
-- I also created aliases 'dea' and 'vac' for each database, for ease of reference. 

SELECT 
*
FROM
  `PortfolioProject.CovidDeaths` dea
JOIN
  `PortfolioProject.CovidVaccinations` vac
ON
dea.location = vac.location
AND
dea.date = vac.date


-- Now, using the data from both databases, I am able to review the Total number of vaccinations per Population. 

SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations
FROM
  `PortfolioProject.CovidDeaths` dea
JOIN
  `PortfolioProject.CovidVaccinations` vac
ON
dea.location = vac.location
AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY
1,
2,
3


-- To be able to view a rolling count of the new vaccinations per day, I used PARTITION BY.

SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_daily_vaccinations
FROM
  `PortfolioProject.CovidDeaths` dea
JOIN
  `PortfolioProject.CovidVaccinations` vac
ON
dea.location = vac.location
AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY
2,
3


---- To calculate the total vaccination rate per country, I need to use the 'total_daily_vaccinations' value, however it is not possible to create an reference a new column in the same query. I used a Temporary Table to resolve this.  

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime, 
population numeric,
new_vaccinations numeric,
total_daily_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_daily_vaccinations
FROM
  `PortfolioProject.CovidDeaths` dea
JOIN
  `PortfolioProject.CovidVaccinations` vac
ON
dea.date = vac.date
AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
)


SELECT *, (total_daily_vaccinations/population)*100
FROM #PercentPopulationVaccinated


-- And finally, I'll create a view to use for future data visualisations.

CREATE VIEW PercentPopulationVaccinated AS  
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_daily_vaccinations
FROM
  `PortfolioProject.CovidDeaths` dea
JOIN
  `PortfolioProject.CovidVaccinations` vac
ON
dea.date = vac.date
AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT 
* 
FROM 
PercentPopulationVaccinated



  
