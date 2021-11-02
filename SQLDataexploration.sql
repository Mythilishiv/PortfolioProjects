select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total cases vs Total deaths 
--shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
and continent is not null
order by 1,2

--looking at Total Cases vs Population
--shows what percentage of population got Covid

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1,2

--looking at countries with Highest Infection Rate compared to Population  

select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


--showing countries with Highest Death count per Population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


-- lets break things down by continent

--showing the continent with highest death count per population  

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers

select sum (new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage 
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

--overall death percentage  

select sum (new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage 
from PortfolioProject..CovidDeaths
where continent is not null 
--group by date 
order by 1,2



--Looking at Total Population vs Vaccinations
--shows percentage of population that has recieved at least one vaccine 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by 
 dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE to perform calculation on partition by in previous query



with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by 
 dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists PercentPopVaccinated
Create Table PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 












