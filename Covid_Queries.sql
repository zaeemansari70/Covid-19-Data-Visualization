

select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 


select * from PortfolioProject..CovidVaccinations 


--looking at total cases vs total deaths
--shows the likelihood of dying if you have covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null and
where location like '%states%'
order by 1,2


--looking at total cases vs Population
--shows what percentage of population got Covid

select location, date, population, total_cases , (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null and
where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population 

select location, population, max(total_cases) , max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc


--showing countries with the highest death count per population

select location , max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--Let' break things down by continent

select continent , max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing the continents with the highest death count

select continent , max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as TotalDeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null 
--where location like '%states%'
--group by date
order by 1,2



--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated(CountrySpecific)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- USE CTE

with PopvsVac(continent, location, date, population, new_vaccinations, PeopleVaccinatedCountrySpecific) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedCountrySpecific
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (PeopleVaccinatedCountrySpecific/population)*100 
from PopvsVac


-- TEMP TABLE

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinatedCountrySpecific numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedCountrySpecific
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *, (PeopleVaccinatedCountrySpecific/population)*100 
from PercentPopulationVaccinated



-- creating View to store data for later visualizations
create view ViewPercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedCountrySpecific
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3



-- Using Views

select *
from ViewPercentPopulationVaccinated