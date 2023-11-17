select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project by Alex]..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from [Portfolio Project by Alex]..CovidDeaths$
where location = 'United States' AND continent is not null
order by 1,2

--Looking at Total Cases vs  Population
--Shows what percentage of population got Covid

Select location, date, population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulatinInfected
from [Portfolio Project by Alex]..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Country with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, 
(CONVERT(float, max(total_cases)) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from [Portfolio Project by Alex]..CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Showing Country with Highest Death Count per Population

Select location, MAX(CAST(total_deaths AS bigint)) as TotalDeathCount
from [Portfolio Project by Alex]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(CAST(total_deaths AS bigint)) as TotalDeathCount
from [Portfolio Project by Alex]..CovidDeaths$
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing continent with the highest death count per populaton
Select continent, MAX(CAST(total_deaths AS bigint)) as TotalDeathCount
from [Portfolio Project by Alex]..CovidDeaths$
Where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT 
	date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS BIGINT)) AS total_deaths,
    SUM(CAST(new_deaths AS BIGINT)) / NULLIF(CONVERT(FLOAT, SUM(new_cases)), 0) * 100.0 AS DeathPercentage
FROM [Portfolio Project by Alex]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS BIGINT)) AS total_deaths,
    SUM(CAST(new_deaths AS BIGINT)) / NULLIF(CONVERT(FLOAT, SUM(new_cases)), 0) * 100.0 AS DeathPercentage
FROM [Portfolio Project by Alex]..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

--WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
--FROM [Portfolio Project by Alex]..CovidDeaths$ dea
--JOIN [Portfolio Project by Alex]..CovidVaccinations$ vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null
----ORDER BY 2,3
--)
--select * from PopvsVac

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
        --(SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / CAST(dea.population AS FLOAT)) * 100.0 AS VaccinationPercentage
    FROM
        [Portfolio Project by Alex]..CovidDeaths$ dea
    JOIN
        [Portfolio Project by Alex]..CovidVaccinations$ vac
    ON
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT * , (RollingPeopleVaccinated/Population)*100  
FROM PopvsVac;


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE  TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinatons numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project by Alex]..CovidDeaths$ dea
JOIN[Portfolio Project by Alex]..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT * , (RollingPeopleVaccinated/Population)*100  
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project by Alex]..CovidDeaths$ dea
JOIN[Portfolio Project by Alex]..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated
