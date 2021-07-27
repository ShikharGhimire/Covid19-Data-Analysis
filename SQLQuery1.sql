-- Let's select the data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
From [CoronaVirus Portfolio]..coviddeaths$
Order by 1,2

-- Let's look at the total cases vs total deaths
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [CoronaVirus Portfolio]..coviddeaths$
Where Location like '%Nepal%'
order by 1,2

--Let's look at the total cases vs the population
--Showing the percentage of popuation that got covid
Select Location,date,population,total_cases,(total_cases/population)*100 as populationpercentageinfection
From [CoronaVirus Portfolio]..coviddeaths$
Where Location like '%Nepal%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as maxpercentinfection
From [CoronaVirus Portfolio]..coviddeaths$
GROUP BY Location, Population
order by maxpercentinfection desc

--Showing the countries with the highest deathcount per population
Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From [CoronaVirus Portfolio]..coviddeaths$
Where continent is not null
GROUP BY Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From [CoronaVirus Portfolio]..coviddeaths$
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- Showing the continent with the highest death count per person
Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From [CoronaVirus Portfolio]..coviddeaths$
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- Looking at total population vs vaccination

-- Let's use CTE
With PopvsVac (Continent,Location,Date,Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by  dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From [CoronaVirus Portfolio]..coviddeaths$ dea
Join [CoronaVirus Portfolio]..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 as rollingpeoplevaccinatedpercentage
From PopvsVac

--TEMP TABLE
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
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by  dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From [CoronaVirus Portfolio]..coviddeaths$ dea
Join [CoronaVirus Portfolio]..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as rollingpeoplevaccinatedpercentage
From #PercentPopulationVaccinated


-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by  dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From [CoronaVirus Portfolio]..coviddeaths$ dea
Join [CoronaVirus Portfolio]..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


