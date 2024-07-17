SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths in Poland

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercantage
FROM CovidDeaths
WHERE location like 'Poland'
AND continent is NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population in Poland

SELECT Location, date, total_cases, population, (total_cases/population) * 100 as SickPopulationPercantage
FROM CovidDeaths
WHERE location like 'Poland'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as SickPopulationPercantage
FROM CovidDeaths
GROUP BY Location, population
ORDER BY 4 DESC

-- showing countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is  NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


-- showing continets with the highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is  NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT  date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercantage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations,  RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT Continent, Location, Population, SUM(CONVERT(int,New_Vaccinations)) as Vaccinated,  MAX(RollingPeopleVaccinated/Population) * 100 as PercantegeOfVaccinated
FROM PopvsVac
GROUP BY Continent, Location, Population


-- TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT Continent, Location, Population, SUM(CONVERT(int,New_Vaccinations)) as Vaccinated,  MAX(RollingPeopleVaccinated/Population) * 100 as PercantegeOfVaccinated
FROM #PercentPopulationVaccinated
GROUP BY Continent, Location, Population

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is NOT NULL


SELECT *
FROM PercentPopulationVaccinated