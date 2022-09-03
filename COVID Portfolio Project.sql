SELECT* 
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null


--SELECT* 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4 


--Select the Data that we are going to be using 

SELECT
location, 
date,
total_cases,
new_cases, 
total_deaths, 
population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looing at Tootal Cases vs Total Deaths 
-- Shows the likelihood of dying if you contract covid in your United States 

SELECT
location, 
date,
total_cases, 
total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Location = 'United States'
ORDER BY 1, 2

-- Looking at the total cases vs the population 
-- Shows what percentaege of population got covid 

SELECT
location, 
date,
population,
total_cases,  
(total_cases/population)*100 AS InfectionRatePercentage  
FROM PortfolioProject..CovidDeaths
WHERE Location = 'United States'
ORDER BY 1, 2

-- Looking atat Countries with Highest Inefection Rate compared to Population 

SELECT
location, 
population, 
MAX(total_cases) AS HighestInfectionCount,  
MAX((total_cases/population))*100 AS InfectionRatePercentage  
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'United States'
GROUP BY location, population
ORDER BY InfectionRatePercentage desc

-- Showing the Countries with the highest death count per population 

SELECT
location, 
MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'United States'
WHERE Continent is not null 
GROUP BY location
ORDER BY TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT 

-- Showing the continents with the Highest death count per population 

SELECT
continent, 
MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'United States'
WHERE Continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS 

SELECT 
date,
SUM(new_cases) AS total_cases,
SUM(cast(new_deaths as int)) AS total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'United States'
WHERE continent is not null 
GROUP BY date 
ORDER BY 1, 2

-- TOTAL GLOBAL NUMBERS 

SELECT
SUM(new_cases) AS total_cases,
SUM(cast(new_deaths as int)) AS total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'United States'
WHERE continent is not null 
--GROUP BY date 
ORDER BY 1, 2

-- Looking at total population vs vaccination 

SELECT 
dea.continent,
dea.location,
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
-- (RollingVaccinations/population)100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2, 3
	

	-- USE CTE 
With PopvsVac (Continent, location, Date, Population, New_Vaccinaitons, RollingVacination) 
as 
(
SELECT 
dea.continent,
dea.location,
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
-- (RollingVaccinations/population)100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2, 3
)
SELECT *, (RollingVacination/Population)*100
FROM PopvsVac

-- TEMP TABLE 

DROP table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent Nvarchar(255), 
Location Nvarchar(255), 
Date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingVaccinations numeric 
)

Insert into #PercentPopulationVaccinated 
SELECT 
dea.continent,
dea.location,
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
-- (RollingVaccinations/population)100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null 
-- ORDER BY 2, 3

SELECT *, (RollingVaccinations/Population)*100
FROM #PercentPopulationVaccinated 


-- Creating View to store data for later vizulizations 

Create View PercentPopulationVaccinated AS

SELECT 
dea.continent,
dea.location,
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
-- (RollingVaccinations/population)100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2, 3
