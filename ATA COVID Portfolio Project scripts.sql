--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3, 4

select * from PortfolioProject..CovidDeaths


-- Select Data that we are going to be using
SELECT * --location, date, total_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases Vs Total Deaths
--Shows liklihood of drying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) AS "death percentage"
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%kingdom%'
ORDER BY 1, 2

--looks at total cases vs population
--shows what percent of population contracted population
SELECT location, date, total_cases, population, round((total_cases/population)*100,2) AS "covid percentage"
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%kingdom%'
ORDER BY 1, 2


-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Shows countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--------------------------------------------------------------------------------------------------------------------------------
---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////----
--------------------------------------------------------------------------------------------------------------------------------
-- looking at total population vs vaccinations
-- when converting new_vaccinations to integers use BIGINT insted of INT
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--------------------------------------------------------------------------------------------------------------------------------
---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////----
--------------------------------------------------------------------------------------------------------------------------------

--USING CTE....what is CTE??

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--------------------------------------------
-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated --deletes the temp table if any alternations are made when running the query multiple times
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--------------------------------------------------------------------------------------------------------------------------------
---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////----
--------------------------------------------------------------------------------------------------------------------------------

--- CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON  dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated