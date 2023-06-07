-- Updated Queries for Tableu Covid Dashboard

-- 1.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- 2.

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
where continent is null and location not in ('World', 'European Union', 'International', 'High Income', 'Upper middle income', 'Lower middle income', 'Low income')
group by location
order by TotalDeathCount desc

-- 3. 
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
where location not in ('High Income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by Location, population
order by PercentPopulationInfected desc

-- 4.
Select Location, population, date, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
where location not in ('High Income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location, population, date
order by PercentPopulationInfected desc

----------------------------------------------------------------------------------------------------------------------------------------

-- SQL Exploration Exercise

SELECT * FROM CovidPortfolioProject..CovidDeaths 
ORDER BY 3,4

-- Remove our row with dummy data that was used to import float variables correctly and not as varchar

-- DELETE FROM CovidPortfolioProject..CovidDeaths WHERE iso_code='EXAMPLE'; 

-- Check if dummy row was deleted

SELECT * FROM CovidPortfolioProject..CovidDeaths 
ORDER BY 3,4

-- It was

-- Now we do the same for our Covid Vaccines
-- Remove our row with dummy data that was used to import float variables correctly and not as varchar

DELETE FROM CovidPortfolioProject..CovidVaccinations WHERE iso_code='EXAMPLE'; 

-- Check that its gone

SELECT * FROM CovidPortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select Data for the project

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidPortfolioProject..CovidDeaths 
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Exploring likelihood of dying after contracting Covid in Tunisia
SELECT location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 AS DeathPercentage
FROM CovidPortfolioProject..CovidDeaths 
WHERE location LIKE '%Tunisia%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Exploring percentages of population that contracted covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageContracted
FROM CovidPortfolioProject..CovidDeaths 
WHERE location LIKE '%Tunisia%'
ORDER BY 1,2

-- Looking at countries with highest level of contraction compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestPercentageContracted
FROM CovidPortfolioProject..CovidDeaths 
GROUP BY location, population
ORDER BY HighestPercentageContracted desc

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Showing continent with highest death count per population 
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths 
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- showing numbers across the globe across time
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(NULLIF(new_cases,0)))*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- showing numbers across the globe in totality up to today
SELECT  SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(NULLIF(new_cases,0)))*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinationsToDate
From CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 AS PopulationPercentageVaccinated
From PopvsVac

-- Temp table

Drop table if Exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
) 

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
-- WHERE dea.continent is not null 

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentagePopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated