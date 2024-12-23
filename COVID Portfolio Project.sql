/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

select *
from PortfolioProject..Covidvaccination
where continent is not null
order by 3,4 


--select data that i will be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--looking at total cases vs total deaths
--showing the likelyhood of dying if you contract covid in ur country	


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%States%'	
and continent is not null
order by 1,2


--looking at total cases vs the population
--shows what percentage of population got covid


select location,date,population,total_cases, (total_cases/population)*100 as PopulationinfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%States%'
order by 1,2



--looking at coutries with the highest infection rate compared or vs population 

select location,population,max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as PopulationinfectedPercentage
from PortfolioProject..CovidDeaths
--where location like 'M%'
group by location,population
order by PopulationinfectedPercentage desc


--showing coutries with the highest death rate/count per population

select location,max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc


--let's break things down by continent 

select continent,max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc


-- if i want more accurante num i'll go with continent is null let's see

--select location,max(cast(total_deaths as int))as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is null 
--group by location
--order by TotalDeathCount desc


--global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int) ) as total_deaths ,(sum(cast(new_deaths as int) )/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%States%'	
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations /( the num of pple who got vaccinated)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


with popvsvac(continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated )
as
(
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100 i can't do that coz its just an alias so i need to use a 'cte' to make it work, make sure u have the same num of column in both tables povsvac and the others
--i can do also ' sum(convert(int,vac.new_vaccinations)) in place of 'cast'
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by  2, 3
)

select*,(RollingPeopleVaccinated/population)*100
from popvsvac


-- Using Temp Table to perform Calculation on Partition By in previous query --TEMP TABLE same as cte

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location=vac.location 
and dea.date=vac.date
--where dea.continent is not null
--order by  2, 3

select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualisation

create view PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by  2, 3






