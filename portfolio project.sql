 select *
 from CovidDeaths$
 where continent is not null
 order by 3,4

 --select*
 --from CovidVaccinations$
 --order by 3,4

  select location, date, total_cases, new_cases, total_deaths, population
  from CovidDeaths$
  order by 1,2

  --looking at total cases vs total deaths
  --shows likelihood of dying if you catch covid in your country 
   select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
   from CovidDeaths$
   where location = 'india'
   order by 1,2

 --looking at total cases vs population

 select population, total_cases, location, date, (total_cases/population)*100 as covidpercentage
 from CovidDeaths$
 where location = 'india'
 order by 3,4 

 -- looking at countries with highest infection rate compared to population

 select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentpopulationinfected
 from covidDeaths$
 group by location, population
 order by percentpopulationinfected desc

 --total deaths per continent

 select continent, MAX(cast(total_deaths as int)) as totaldeathcount
 from coviddeaths$
 where continent is not null
 group by continent
 order by totaldeathcount desc


 -- looking at total population vs vaccination

  select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplegettingvaccine
  from CovidDeaths$ dea
  join CovidVaccinations$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3


with popvsvac(continent, location, date, population, new_vaccinations, peoplegettingvaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplegettingvaccine
  from CovidDeaths$ dea
  join CovidVaccinations$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
)
select *, (peoplegettingvaccinated/population)*100
from popvsvac

-- finding percent of people vaccinated usin temp tables

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peoplegettingvaccine numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplegettingvaccine
  from CovidDeaths$ dea
  join CovidVaccinations$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null


select*, (peoplegettingvaccine/population)*100
from #percentpopulationvaccinated



-- create view

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as peoplegettingvaccine
  from CovidDeaths$ dea
  join CovidVaccinations$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null

select *
from percentpopulationvaccinated

