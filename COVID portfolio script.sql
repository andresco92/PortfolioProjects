SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking Total Cases vs Total Deaths
-- Shows the likelihood id dying if you contract covid in your country

SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%colombi%'
ORDER BY 1,2 

-- Looking at total cases vs Population
-- Shows what percentage of population got Covid19

SELECT location, date, total_cases, population,(total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%colombi%'
ORDER BY 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, max(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%colombi%'
GROUP BY location, Population
ORDER BY  PercentofPopulationInfected DESC




-- Showing the countries with highest death count per population

SELECT location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%colombi%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  TotalDeathCount DESC



-- LET'S BREAK THINGS DWON BY CONTINENT



--Showing the continets with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%colombi%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT   SUM(new_cases) AS total_Cases, sum(CAST(new_deaths AS INT)) total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%colombi%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

-- Looking at total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION  BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION  BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
)

SELECT *, (RollingPeopleVaccinated/Population)* 100
FROM  PopvsVac

 -- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
  Continent nvarchar (255),
  Location nvarchar (255),
  Date datetime,
  Population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric 
)

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION  BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/Population)* 100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later situations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION  BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *
FROM PercentPopulationVaccinated