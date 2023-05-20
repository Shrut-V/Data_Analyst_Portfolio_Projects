--Covid Death Dataset
Select *
From PortfolioProject..['Covid Deaths$']
order by 3,4

--Select *
--From PortfolioProject..['covid Vaccinations$']
--order by 3,4

--
Select location, date, total_cases, new_cases,total_deaths, population 
From PortfolioProject..['Covid Deaths$']
order by 1,2

--Percentage of people who are infected are death
Select location,date,total_deaths, total_cases, population, (cast(total_deaths as int) /total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
where location like '%India%'
order by 1,2

-- total case vs Population
Select location,date, total_cases, population, (total_cases /population)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
where location like '%India%'
order by 1,2

--List of countries with highest infected rate
Select location, population, Max (total_cases) as HighestCount,  Max((total_cases /population)*100) as HighestInfectedPercentage
From PortfolioProject..['Covid Deaths$']
--where location like '%India%'
Group by location, population
order by HighestInfectedPercentage desc

--Highest death per population
Select location,  Max (cast (total_deaths as int)) as HighestDeathCount
From PortfolioProject..['Covid Deaths$']
where continent is not null
Group by location,continent
order by HighestDeathCount desc

--Highest death per population by continent
Select continent, Max (cast (total_deaths as int)) as HighestDeathCount
From PortfolioProject..['Covid Deaths$']
where continent is not null
Group by continent
order by HighestDeathCount desc

-- Global Number

Select date, SUM(new_cases), SUM(new_deaths), (SUM(new_deaths) /SUM(new_cases)*100) as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--where location like '%India%'
where continent is not null
Group by date




--Just Total number of cases and death

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int)) /SUM(new_cases)*100) as DeathPercentage
From PortfolioProject..['Covid Deaths$']
--where location like '%India%'
where continent is not null
Group by date
order by 1,2

--Covid Vaccination 

Select *
From PortfolioProject..['covid Vaccinations$']
order by 3,4

--Join two tables

Select *
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['covid Vaccinations$'] vac
  On dea.location = vac.location
  and dea.date = vac.date

-- Look for total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['covid Vaccinations$'] vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  --rolling count for location
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingCount
From PortfolioProject..['Covid Deaths$'] dea
 Join PortfolioProject..['covid Vaccinations$'] vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  --Using CTE
  With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingCount)
  as
 (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingCount
From PortfolioProject..['Covid Deaths$'] dea
 Join PortfolioProject..['covid Vaccinations$'] vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
)
Select *, (RollingCount/Population)*100
From PopVsVac

-- Temp Table
Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population float,
new_vaccinations numeric,
RollingCount numeric
)
Insert INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingCount
From PortfolioProject..['Covid Deaths$'] dea
 Join PortfolioProject..['covid Vaccinations$'] vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

Select *, (RollingCount /Population)*100
From #PercentPopulationVaccinated
 
 --Create View
 Create View PercentVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingCount
From PortfolioProject..['Covid Deaths$'] dea
 Join PortfolioProject..['covid Vaccinations$'] vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3