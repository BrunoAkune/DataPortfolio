Select *
From PortfolioProject.. CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject.. CovidVaccination
--order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if getting covid
Select location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 AS Deathpercentage
--(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where Location like '%Canada%'
order by 1,2

-- Looking at Total cases vs Population
-- Show what % of population got Covid
Select location, date, total_cases,population, (total_cases/population) * 100 AS InfectionRate
from PortfolioProject..covidDeaths
Where Location like '%Canada%'
order by 1,2

-- Identify the number of MAX cases
-- Order from High to low
Select location, population, MAX(total_cases) AS Peak
from PortfolioProject..covidDeaths
Group by location, population
order by Peak desc

-- Looking at Countries with Highest Infection rate compared to their population
-- Order from High to low
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) * 100 AS PeakInfectionRate
from PortfolioProject..covidDeaths
Group by location, population
order by PeakInfectionRate desc

-- Looking at Countries with Highest Death rate compared to their population
-- Order from High to low
Select location, MAX(total_deaths) as totalDeathCount
from PortfolioProject..covidDeaths
Where continent is not null
Group by location
order by totalDeathCount desc

-- Showing continents with the highest death count
Select location, MAX(total_deaths) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is null
Group by location
order by totalDeathCount desc

-- Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentGlobal
from PortfolioProject..covidDeaths
where continent is not null
Group by date
order by 1,2


-- Looking Total population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
, (TotalPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (TotalPeopleVaccinated/Population)*100
From PopvsVac

--Use Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (TotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated