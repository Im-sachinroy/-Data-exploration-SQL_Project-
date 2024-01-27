select * from PortfolioProject..CovidDeaths
where continent is not null

--select * from PortfolioProject..CovidVaccinations

select location,date,total_cases,new_cases, total_deaths ,population 
from PortfolioProject..CovidDeaths
order by 1,2

-- total cases vs total deaths

select location,date,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location='India'
order by 1,2

select location,date,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like '%states%'
order by 1,2

--Total cases vs population
--shows what percentage of population got covid

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--where location like '%states%'
order by 1,2

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where total_cases is not null and location='India'
order by 1,2 desc
		

--looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths 
--where location like '%states%'
--where location='India'
group by location,population
order by PercentPopulationInfected  desc


--showing countries with highest death count per population

select location,max(convert(int,total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%states%'
--where location='India'
group by location
order by TotalDeathCount desc

--breaking things by continent

select continent,max(convert(int,total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%states%'
--where location='India'
where continent is not null
group by continent
order by TotalDeathCount desc


--joining two tables
--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

 --Use CTE
 with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
 as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select *, (RollingPeopleVaccinated/population)*100 
 from PopvsVac


--TEMP table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(255),location varchar(255), date date,population int,new_vaccinations bigint,RollingPeopleVaccinated int
)
insert into #PercentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 --where dea.continent is not null
 --order by 2,3
  
  select *, (RollingPeopleVaccinated/population)*100 
 from #PercentPopulationVaccinated
 
