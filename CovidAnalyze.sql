select *
from CovidAnalyze..CovidDeaths
--where continent is not null
order by 3,4;

--select *
--from CovidAnalyze..CovidVaccinations
--order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from CovidAnalyze..CovidDeaths
where continent is not null
order by 1,2;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
from CovidAnalyze..CovidDeaths
where location like '%oland%'
order by 1,2;

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidAnalyze..CovidDeaths
where location like '%oland%' and total_cases is not null
order by 1,2;

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from CovidAnalyze..CovidDeaths
--where location like '%oland%' and total_cases is not null
group by location, population
order by PercentPopulationInfected desc;

select location, population, max(total_cases) as HighestInfectionCount, max(total_deaths) as HighestDeathCount, max(total_deaths/population)*100 as PercentPopulationDied
from CovidAnalyze..CovidDeaths
group by location, population
order by PercentPopulationDied desc;

select location, max(total_deaths) as TotalDeathCount
from CovidAnalyze..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- cast datatype according to example above max(cast(total_deaths as int)) as HighestDeathCount

select location, max(total_deaths) as TotalDeathCount
from CovidAnalyze..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc;


select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(new_deaths)/nullif(sum(new_cases), 0) * 100 as DeathPercentage
from CovidAnalyze..CovidDeaths
where continent is not null
group by date
order by 1,2;

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(new_deaths)/nullif(sum(new_cases), 0) * 100 as DeathPercentage
from CovidAnalyze..CovidDeaths
where continent is not null
--group by date
order by 1,2;

with PopVsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from CovidAnalyze..CovidDeaths dea
	join CovidAnalyze..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
from PopVsVacc;



--try to do it as a temp table
--also in above example, delete date and continent (select it without those columns)
--try to prepare own CTE with specific data which You are intereted in, HOMEWORK TODAY or TOMORROW 



drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidAnalyze..CovidDeaths dea
join CovidAnalyze..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
from #PercentPopulationVaccinated;


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidAnalyze..CovidDeaths dea
join CovidAnalyze..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

drop view PercentPopulationVaccinated

select *
from PercentPopulationVaccinated