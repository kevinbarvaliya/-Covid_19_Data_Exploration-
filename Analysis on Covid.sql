--Selecting the Database to perform analysis
use CovidProject;

-- selecting data that we will uss
Select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent is not null
order by 1,2;


--cheking Total casec VS Total Deaths 
--Death ratio among the people who got covid

select location,date, total_cases, total_deaths , total_deaths/total_cases*100 as Death_ratio
from CovidDeaths
where location = 'Canada'
order by 1,2;


--cheking Total casec VS Populatio
--What Percentage of people got covid

select location, date, total_cases, population , total_cases/population*100 as Infaction_ratio
from CovidDeaths
where location = 'Canada'
order by 1,2;


--Wich Countryies has highest infaction rate

select location, population, max(total_deaths) as max_cases, max(total_cases)/population*100as Infaction_ratio
from CovidDeaths
where continent is not null
group by location,population
order by 4 desc;

--Which Countryies has highest death rate

select location, max(cast(total_deaths as int)) as total_death_count 
from CovidDeaths
where continent is not null
group by location
order by 2 desc;


--Which Continent has highest death rate

select continent, max(cast(total_deaths as int)) as total_death_count 
from CovidDeaths
where continent is not null
group by continent
order by 2 desc;


--Global numbers
--Each day total number of cases and new cases

select date, sum(totalCase)as TotalCases, sum(newCase) as NewCases
from (select date, max(total_cases) as totalCase, max(new_cases)as newCase
	  from CovidDeaths
      where new_cases != 0
      group by date,location) as t
group by date
order by date;


--Total Population VS Total Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent, d.location, d.date, population, new_vaccinations, 
		sum(cast(new_vaccinations as int)) over(partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v on d.date=v.date and d.location = v.location
where d.continent is not null
order by 2,3;  



-- Using W caluseith to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, population, new_vaccinations, 
		sum(cast(new_vaccinations as int)) over(partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v on d.date=v.date and d.location = v.location
where d.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
select d.continent, d.location, d.date, population, new_vaccinations, 
		sum(cast(new_vaccinations as int)) over(partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v on d.date=v.date and d.location = v.location
where d.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated




