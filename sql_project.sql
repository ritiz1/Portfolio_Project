---Looking at Total Cases vs Total Death 
---Shows likelihood of dying if you are infected by covid in Nepal

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 DeathPercentage
from Portfolio_Project..covid_death
where continent is not null
and location like '%Nepal%'
order by 1,2



--Looking at Total Cases vs Population
Select location, date,Population, total_cases,(total_cases/population)*100 as VictimPercentage
from Portfolio_Project..covid_death
where location like '%Nepal%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select location,Population,max(total_cases) as HighestInfectionCount,(max(total_cases)/population)*100 as MAX_VictimPercentage
from Portfolio_Project..covid_death
Group by location,population
order by MAX_VictimPercentage desc

--Showing Continent with Highest DeathCount per Population
Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..covid_death
where continent  is  not null
Group by continent
order by TotalDeathCount desc



--Global Numbers 
--- THE TOTAL CASES AND TOTAL DEATHS AROUND THE WORLD PER DAY
Select date, sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,(sum(new_deaths)/sum(new_cases))*100 as PercentageOfDeath
from Portfolio_Project..covid_death
where continent is not null
group by date
order by 1,2


--Total Cases and Total Death till date
Select sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,(sum(new_deaths)/sum(new_cases))*100 as PercentageOfDeath
from Portfolio_Project..covid_death
where continent is not null
order by 1,2



---Looking at Total Population vs Vaccinations per day
Select dea.continent,dea.location, dea.date,dea.population,vac.new_people_vaccinated_smoothed
, Sum(cast(vac.new_people_vaccinated_smoothed as int)) over (Partition by dea.location order by dea.location
,dea.Date) as RollingPeopleVaccinated
From Portfolio_Project..covid_death dea
join Portfolio_Project..covid_vaccine vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

---with percantage of total vaccination over population

----- USE CTE
with PopvsVac(continent,location,date,population,new_people_vaccinated_smoothed,RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location, dea.date,dea.population,vac.new_people_vaccinated_smoothed
, Sum(cast(vac.new_people_vaccinated_smoothed as int)) over (Partition by dea.location order by dea.location
,dea.Date) as RollingPeopleVaccinated
From Portfolio_Project..covid_death dea
join Portfolio_Project..covid_vaccine vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *,(RollingPeopleVaccinated/population)*100 as PercentageofVaccination
From PopvsVac


---Temp Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinated_smoothed numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date,dea.population,cast(vac.new_people_vaccinated_smoothed as int)
, Sum(cast(vac.new_people_vaccinated_smoothed as int)) over (Partition by dea.location order by dea.location
,dea.Date) as RollingPeopleVaccinated
From Portfolio_Project..covid_death dea
join Portfolio_Project..covid_vaccine vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3

Select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


---People being vacinnated in context of world per day

with cte(date,sum_vaccinate)
as
(
SELECT dea.date, SUM(CAST(vac.new_people_vaccinated_smoothed AS INT)) AS total_vaccinated
FROM Portfolio_Project..covid_death dea
JOIN Portfolio_Project..covid_vaccine vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.date
---ORDER BY dea.date;
)
select *
from cte
where sum_vaccinate is not null
order by 







