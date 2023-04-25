--CREATE DATABASE PortfolioProject

--SELECT * FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4


--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING  [To view thr required table]

SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Total Cases Vs Total deaths [Percentage of Death over Cases]

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPrecentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location Like '%India%'           --//To see the death percentage in india during 2020-2021
ORDER BY 1,2


--Total Cases Vs Population[Percentage of cases over population] 

SELECT Location,date,population,total_cases,(total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location Like '%India%'           --//To see the Cases percentage in india during 2020-2021
ORDER BY 1,2

--Per Countries with highest infection rate compared to population

SELECT Location,population,MAX(total_cases) AS HighestCases ,MAX(total_cases/population)*100 AS HighestCasesPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location Like '%India%'           --//To see the Cases percentage in india during 2020-2021
GROUP BY Location,population
ORDER BY HighestCasesPercentage Desc

--Countries with highesr Death count per Population

--[ Self Query 1  
--This below query shows the highest death and its percentage with respect to location and total population
  
--SELECT Location,population,MAX(CAST(total_deaths AS INT)) AS HighestDeaths ,MAX(total_deaths/population)*100 AS HighestDeathPercentage
--FROM PortfolioProject.dbo.CovidDeaths
----WHERE location Like '%India%'           --//To see the Cases percentage in india during 2020-2021
--GROUP BY Location,population
--ORDER BY HighestDeathPercentage Desc

--]

--Countries with highesr Death count per Population

SELECT Location,MAX(CAST(total_deaths AS INT)) AS TotaklDeathCount
FROM PortfolioProject.dbo.CovidDeaths
----WHERE location Like '%India%'           --//To see the Cases percentage in india during 2020-2021
WHERE continent is NOT NULL                 --//becuase in location we were getting continenet
GROUP BY Location
ORDER BY TotaklDeathCount Desc


--Break the table by Continent
--Showing The continents with highest death counts

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotaklDeathCount
FROM PortfolioProject.dbo.CovidDeaths
----WHERE location Like '%India%'           --//To see the Cases percentage in india during 2020-2021
WHERE continent is NOT NULL                 --//becuase in location we were getting continenet
GROUP BY continent
ORDER BY TotaklDeathCount Desc


--Global Numbers per date

SELECT date,SUM(new_cases)As TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeath,SUM(CAST(new_deaths as INT))/SUM(new_cases)*100  AS DeathPrecentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location Like '%India%'           --//To see the death percentage in india during 2020-2021
WHERE continent Is not NULL
GROUP BY date
ORDER BY 1,2

--Global Numbers in Total

SELECT SUM(new_cases)As TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeath,SUM(CAST(new_deaths as INT))/SUM(new_cases)*100  AS DeathPrecentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location Like '%India%'           --//To see the death percentage in india during 2020-2021
WHERE continent Is not NULL
ORDER BY 1,2

-------------------------------------------------------------------------------------------------------------------------------------------------

--Total Population Vs Vaccination
SELECT cda.continent,cda.location,cda.date,cda.population, cva.new_vaccinations, 
SUM(CAST(cva.new_vaccinations AS INT))OVER (Partition BY cda.location ORDER BY cda.date) SumminVaccination
FROM PortfolioProject..CovidDeaths cda
JOIN PortfolioProject..CovidVaccinations cva
        ON cda.date=cva.date and cda.location=cva.location
WHERE cda.continent is NOT NULL
ORDER BY 2,3

-------------------------TO see percentage of Summing vaccination over population
                                      --USING CTA --
 ------------------------------------------------
 WITH VaccinationPeeps (continent,location,date,population,New_vaccination,SumminVaccination)
 as
 ( SELECT cda.continent,cda.location,cda.date,cda.population, cva.new_vaccinations, 
SUM(CAST(cva.new_vaccinations AS INT))OVER (Partition BY cda.location ORDER BY cda.date) SumminVaccination
FROM PortfolioProject..CovidDeaths cda
JOIN PortfolioProject..CovidVaccinations cva
        ON cda.date=cva.date and cda.location=cva.location
WHERE cda.continent is NOT NULL
--ORDER BY 2,3
) 

SELECT * ,(SumminVaccination/population)*100
FROM VaccinationPeeps
-------------------------------------------------------
 
                                       --TEMP TABLE--
---------------------------------------------------
DROP TABLE IF EXISTS #temp_totalvacc
CREATE TABLE #temp_totalvacc (
Continent nVARCHAR(255),
Location nVARCHAR(255),
DATE datetime,
population Numeric,
New_vaccination NUMERIC,SumminVaccination NUMERIC)

INSERT INTO #temp_totalvacc
SELECT cda.continent,cda.location,cda.date,cda.population, cva.new_vaccinations, 
SUM(CAST(cva.new_vaccinations AS INT))OVER (Partition BY cda.location ORDER BY cda.date) SumminVaccination
FROM PortfolioProject..CovidDeaths cda
JOIN PortfolioProject..CovidVaccinations cva
        ON cda.date=cva.date and cda.location=cva.location
WHERE cda.continent is NOT NULL
--ORDER BY 2,3
 
SELECT * ,(SumminVaccination/population)*100
FROM #temp_totalvacc
----------------------------------------------------



--make a table into view format--
-------------------------------------
CREATE VIEW PopulationvsVaccination As
SELECT cda.continent,cda.location,cda.date,cda.population, cva.new_vaccinations, 
SUM(CAST(cva.new_vaccinations AS INT))OVER (Partition BY cda.location ORDER BY cda.date) SumminVaccination
FROM PortfolioProject..CovidDeaths cda
JOIN PortfolioProject..CovidVaccinations cva
        ON cda.date=cva.date and cda.location=cva.location
WHERE cda.continent is NOT NULL
--ORDER BY 2,3
-------------------------------------

SELECT * FROM PopulationvsVaccination     --//Select all from the created view table
-------------------------------------

--Total Death count according to the continenet View

CREATE VIEW TEST AS 
(SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotaklDeathCount
FROM PortfolioProject.dbo.CovidDeaths
----WHERE location Like '%India%'           --//To see the Cases percentage in india during 2020-2021
WHERE continent is NOT NULL                 --//becuase in location we were getting continenet
GROUP BY continent
--ORDER BY TotaklDeathCount Desc
)
----------------------------------
 SELECT * FROM TEST
---------------------------------