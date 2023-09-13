/****** Quick view about data  ******/
SELECT top 100 *
  FROM [PortfolioProject].[dbo].['covid death$']
  order by 3,4

  SELECT top 100 *
  FROM [PortfolioProject].[dbo].['covid vaccination$']
  order by 3,4

  -- View data using for analysis--

  SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].['covid death$']
  where continent is not null
  order by 1,2

  -- Total Cases vs Total Death
  SELECT location, date, total_cases, total_deaths, 
  (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
  FROM [PortfolioProject].[dbo].['covid death$']
  where location like '%Vietnam%' and   continent is not null
  order by 1,2

  -- Total Cases vs Total Population
  SELECT location, date, total_cases, population, 
  (cast(total_cases as float)/cast(population as float))*100 as CovidCasePercentage
  FROM [PortfolioProject].[dbo].['covid death$']
  where location like '%Vietnam%' and continent is not null
  order by 1,2

    -- Which country have highest infection rate (CovidCasePercentage)
  SELECT location, population, max(cast(total_cases as float)) as CovidCaseCount, 
  max((cast(total_cases as float)/cast(population as float))*100) as CovidCasePercentage
  FROM [PortfolioProject].[dbo].['covid death$']
  where year(date) <= 2021 and continent is not null
  group by location, population
  order by CovidCasePercentage DESC


     -- Which country have highest death rate 
  SELECT location, population, max(cast (total_deaths as float))as DeathCount, 
  max((cast(total_deaths as float)/cast(population as float))*100) as DeathPercentage
  FROM [PortfolioProject].[dbo].['covid death$']
  where year(date) <= 2021 and continent is not null
  group by location, population
  order by DeathCount DESC

  --Join 2 tables
select  d.location, d.date, d.continent, d.total_cases, d.new_cases, d.population, v.total_tests, v.people_vaccinated, v.new_vaccinations,
sum(cast (total_cases as float)) OVER (partition by d.location order by d.date) as RollingTotalCases
from [PortfolioProject].[dbo].['covid death$'] as d
full join
[PortfolioProject].[dbo].['covid vaccination$'] as v
on d.date=v.date and d.location = v.location
where d.continent is not null
order by d.location, d.date

-- 1. For column PercentCalculation, cannot use total_cases/RollingTotalCases so option 1 is write it down again or use CTE in option 2
select  d.location, d.date, d.continent, d.total_cases, d.new_cases, d.population, v.total_tests, v.people_vaccinated, v.new_vaccinations,
sum(cast (total_cases as float)) OVER (partition by d.location order by d.date) as RollingTotalCases,
(sum(cast (total_cases as float)) OVER (partition by d.location order by d.date)/population*100) as PercentCalculation
from [PortfolioProject].[dbo].['covid death$'] as d
full join
[PortfolioProject].[dbo].['covid vaccination$'] as v
on d.date=v.date and d.location = v.location
where d.continent is not null
order by d.location, d.date
--2. Create CTE
with CTE_table (location, date, continent, total_cases, new_cases, population, total_tests, people_vaccinated, new_vaccinations, RollingTotalCases)
as
(select  d.location, d.date, d.continent, d.total_cases, d.new_cases, d.population, v.total_tests, v.people_vaccinated, v.new_vaccinations,
sum(cast (total_cases as float)) OVER (partition by d.location order by d.date) as RollingTotalCases
from [PortfolioProject].[dbo].['covid death$'] as d
full join
[PortfolioProject].[dbo].['covid vaccination$'] as v
on d.date=v.date and d.location = v.location
where d.continent is not null
)
select 
*,
RollingTotalCases/population*100
from CTE_table
order by location, date
--3. Create temp table
create table temp_table (location nvarchar(200), date datetime, continent nvarchar(200), total_cases float, new_cases float, population float, total_tests float, people_vaccinated float, new_vaccinations float, RollingTotalCases float)
insert into temp_table
select  d.location, d.date, d.continent, d.total_cases, d.new_cases, d.population, v.total_tests, v.people_vaccinated, v.new_vaccinations,
sum(cast (total_cases as float)) OVER (partition by d.location order by d.date) as RollingTotalCases
from [PortfolioProject].[dbo].['covid death$'] as d
full join
[PortfolioProject].[dbo].['covid vaccination$'] as v
on d.date=v.date and d.location = v.location
where d.continent is not null

select 
*,
RollingTotalCases/population*100
from temp_table
order by location, date

--Create view 
create view data_final as
select  d.location, d.date, d.continent, d.total_cases, d.new_cases, d.population, v.total_tests, v.people_vaccinated, v.new_vaccinations,
sum(cast (total_cases as float)) OVER (partition by d.location order by d.date) as RollingTotalCases
from [PortfolioProject].[dbo].['covid death$'] as d
full join
[PortfolioProject].[dbo].['covid vaccination$'] as v
on d.date=v.date and d.location = v.location
where d.continent is not null