--1
select *
from Portfolio..Deaths
where continent is not null
order by 3,4

--select *
--from Portfolio..Vaccinations
--order by 3,4

-- 2 Select data we are using

Select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..Deaths
order by 1,2

-- 3 Looking at total cases vs total deaths
--shows likelihood of dying from covid

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..Deaths
where location like '%states%'
order by 1,2

-- 4 looking at total cases vs population

Select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from Portfolio..Deaths
where location like '%states%'
order by 1,2

-- 5 Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from Portfolio..Deaths
where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- 6 Showing countries with highest death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..Deaths
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc

-- 7 Showing continent with highest death count per Population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..Deaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- 8 global numbers

Select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Portfolio..Deaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

-- 9 Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..Deaths dea
Join Portfolio..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3


-- 10 use CTE



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, convert(date, dea.Date)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..Deaths dea
Join Portfolio..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac

--Temp Table

drop table #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, convert(date, dea.Date)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..Deaths dea
Join Portfolio..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, convert(date, dea.Date)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..Deaths dea
Join Portfolio..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated
