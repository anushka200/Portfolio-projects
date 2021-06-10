select *
from Portfolioproject..coviddeaths
where continent is not null
order by 3,4

--select *
--from Portfolioproject..covidvaccinations
--order by 3,4

--Analysing total cases vs total deaths 
--shows likelihood of dying if you contract covid in your country 
select location , date,total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolioproject..coviddeaths
where location = 'India'
order by 1,2

--Analysing total cases  vs population 
--shows what % of populatiion got covid 
select location , date,total_cases, population, (total_cases/population)*100 as death_percentage
from Portfolioproject..coviddeaths
where location = 'India'
order by 1,2

-- looking at countries with highest infection rate compared to population
select location ,population,MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_of_population
from Portfolioproject..coviddeaths
group by population, location
order by percent_of_population desc

--countries with highest death count per population 
select continent  ,MAX(cast(total_deaths as int)) as highest_death_count
from Portfolioproject..coviddeaths
where continent is not  null
group by continent
order by highest_death_count desc

--global numbers 
select  SUM(new_cases) as totalcases,SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases )*100 as death_percentage
from Portfolioproject..coviddeaths
--where location = 'India'
where continent is not null
--group by date
order by 1,2

--joining both tables and looking at total populations vs vaccinations
With popvsvac (continent, location, date , population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location , dea.date) as rollingPeopleVaccinated
from Portfolioproject..coviddeaths dea--(a liitle alias for both tables)
join Portfolioproject..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/ population)*100
from popvsvac

--temp table 
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location , dea.date) as rollingPeopleVaccinated
from Portfolioproject..coviddeaths dea--(a liitle alias for both tables)
join Portfolioproject..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingPeopleVaccinated/ population)*100
from #percentpopulationvaccinated



--creating view to store data for visualization'

CREATE VIEW percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location , dea.date) as rollingPeopleVaccinated
from Portfolioproject..coviddeaths dea--(a liitle alias for both tables)
join Portfolioproject..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated




