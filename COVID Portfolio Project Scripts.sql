/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [PortfolioProject].[dbo].[CovidDeaths]


--Showing Country With Highest Death Count per Population

SELECT Location, MAX(Cast(total_Deaths AS int)) As Total_deathsCount
FROM PortfolioProject..CovidDeaths
--Where location Like '%nigeria%'
WHERE continent is not null
Group by location
Order By Total_deathsCount DEsc

--Let's Break Things Down By Continent

SELECT continent, MAX(Cast(total_Deaths AS int)) As Total_deathsCount
FROM PortfolioProject..CovidDeaths
--Where location Like '%nigeria%'
WHERE continent is not null
Group by continent
Order By Total_deathsCount desc


-- Showing The Continents With the highest death count per population

SELECT continent, MAX(Cast(total_Deaths AS int)) As Total_deathsCount
FROM PortfolioProject..CovidDeaths
--Where location Like '%nigeria%'
WHERE continent is not null
Group by continent
Order By Total_deathsCount desc


-- Global Numbers

Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Death, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location Like '%Africa%'
where Continent is not null
--group by date
Order by 1,2


--Looking at Total Population vs Vaccination

select dea.continent, dea.Location, dea.Date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations3 vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
Order by 1,2,3

  -- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.New_Vaccinations )) Over (partition by dea.Location order by dea.location, dea.date)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations3 vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using a CTE

With popvsVac (continent, Location, Date, Population, New_vaccinations, RollingpeopleVacinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.New_Vaccinations )) Over (partition by dea.Location order by dea.location, dea.date) as rollingpeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations3 vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingpeopleVacinated/Population)*100
from popvsVac


--TEMP TABLE
drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population Numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.New_Vaccinations )) Over (partition by dea.Location order by dea.location, dea.date) as rollingpeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations3 vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null

select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to Store Data For Later Visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.New_Vaccinations )) Over (partition by dea.Location order by dea.location, dea.date) as rollingpeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations3 vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select *
from PercentPopulationVaccinated