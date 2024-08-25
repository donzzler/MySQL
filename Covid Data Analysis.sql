CREATE TABLE covid_deaths (
    AFG varchar(10),
    continent varchar(20),
    location varchar (50),
    dates date,
    population bigint,
    total_cases int,
    new_cases int,
    new_cases_smoothed float,
    total_deaths int,
    new_deaths int,
    new_deaths_smoothed float,
    total_cases_per_million float,
    new_cases_per_million float,
    new_cases_smoothed_per_million float,
    total_deaths_per_million float,
    new_deaths_per_million float,
    new_deaths_smoothed_per_million float,
    reproduction_rate float,
    icu_patients int,
    icu_patients_per_million float,
    hosp_patients int,
    hosp_patients_per_million float,
    weekly_icu_admissions float,
    weekly_icu_admissions_per_million float,
    weekly_hosp_admissions float,
    weekly_hosp_admissions_per_million float
);

CREATE TABLE covid_vaccinations (
    AFG	varchar(10), 
    continent varchar(20), 
    location varchar(50), 
    dates date,	
    total_tests bigint, 
    new_tests int, 
    total_tests_per_thousand float,  
    new_tests_per_thousand float, 
    new_tests_smoothed float, 
    new_tests_smoothed_per_thousand float, 
    positive_rate float,
    tests_per_case float, 
    tests_units varchar(20),
    total_vaccinations bigint, 
    people_vaccinated bigint, 
    people_fully_vaccinated bigint, 
    total_boosters bigint,	
    new_vaccinations int, 
    new_vaccinations_smoothed float, 
    total_vaccinations_per_hundred float, 
    people_vaccinated_per_hundred float, 
    people_fully_vaccinated_per_hundred float, 
    total_boosters_per_hundred float, 
    new_vaccinations_smoothed_per_million float, 
    new_people_vaccinated_smoothed float, 
    new_people_vaccinated_smoothed_per_hundred float,
    stringency_index float, 
    population_density float, 
    median_age float, 
    aged_65_older float, 
    aged_70_older float, 
    gdp_per_capita float, 
    extreme_poverty	float, 
    cardiovasc_death_rate float, 
    diabetes_prevalence float, 
    female_smokers float, 
    male_smokers float, 
    handwashing_facilities float, 
    hospital_beds_per_thousand float, 
    life_expectancy float, 
    human_development_index float, 
    excess_mortality_cumulative_absolute float, 
    excess_mortality_cumulative float, 
    excess_mortality float, 
    excess_mortality_cumulative_per_million float
);

SELECT location, dates, total_cases, new_cases,
        total_deaths, population
FROM covid_deaths
WHERE continent NOT LIKE ""
ORDER BY 1,2;

-- total cases vs total deaths
SELECT location, dates, total_cases, total_deaths,
        (total_deaths/total_cases)*100 AS death_pct
FROM covid_deaths
WHERE location LIKE "%Canada%"
ORDER BY 1,2;

-- % of countries population that got covid
SELECT location, dates, population, total_cases,
        (total_cases/population)*100 AS covid_pct
FROM covid_deaths
WHERE location LIKE "%Canada%"
ORDER BY 1,2;

-- Highest % of population infected
SELECT location, population, 
        MAX(total_cases) AS total_infected,
        MAX((total_cases/population))*100 AS infected_pct
FROM covid_deaths
WHERE continent NOT LIKE ""
GROUP BY location, population
ORDER BY infected_pct DESC;

-- Countries with highest death count and % of population
SELECT location, MAX(total_deaths) AS death_count,
        (MAX(total_deaths)/population)*100 AS pct_of_population
FROM covid_deaths
WHERE continent NOT LIKE ""
GROUP BY location, population
ORDER BY pct_of_population DESC;

-- CONTINENTAL NUMBERS

-- total cases vs total deaths
SELECT location, dates, total_cases, total_deaths,
        (total_deaths/total_cases)*100 AS death_pct
FROM covid_deaths
WHERE continent LIKE "Asia" AND location LIKE "Japan"
ORDER BY 1,2;

-- % of population that got covid
SELECT location, dates, population, total_cases,
        (total_cases/population)*100 AS covid_pct
FROM covid_deaths
WHERE continent LIKE "%North%" AND location LIKE "Canada"
ORDER BY 1,2;

-- Highest % of population infected
SELECT location, population, 
        MAX(total_cases) AS total_infected,
        MAX((total_cases/population))*100 AS infected_pct
FROM covid_deaths
WHERE continent LIKE "Europe" AND
        location NOT LIKE "%income%" AND
        location NOT LIKE "World" AND
        location NOT LIKE "International"
GROUP BY location, population
ORDER BY infected_pct DESC;

-- Break down by continent (death count/% of population)
SELECT location, MAX(total_deaths) AS death_count,
        (MAX(total_deaths)/population)*100 AS pct_of_population
FROM covid_deaths
WHERE continent LIKE "%South%" AND 
        location NOT LIKE "%income%" AND
        location NOT LIKE "World" AND
        location NOT LIKE "International"
GROUP BY location, population
ORDER BY pct_of_population DESC;

-- GLOBAL NUMBERS

-- total cases vs total deaths
SELECT SUM(new_cases) AS total_cases, 
        SUM(new_deaths) AS total_deaths,
        SUM(new_deaths)/SUM(new_cases)*100 AS death_pct
FROM covid_deaths
WHERE continent NOT LIKE ""
ORDER BY 1,2;

-- VACCINATION DATA

-- total vaccination vs population
SELECT dea.continent, dea.location, dea.dates, dea.population,
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
        ORDER BY dea.location, dea.dates) AS rolling_vaccinations   
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.dates = vac.dates
WHERE dea.continent != ""
ORDER BY 2,3;

-- CTE
WITH vaxvspop (continent, location, dates, population, 
    new_vaccinations, rolling_vaccinations)
AS (
    SELECT dea.continent, dea.location, dea.dates, dea.population,
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
        ORDER BY dea.location, dea.dates) AS rolling_vaccinations
    
    FROM covid_deaths dea
    JOIN covid_vaccinations vac
        ON dea.location = vac.location
        AND dea.dates = vac.dates
    WHERE dea.continent != ""
    )
SELECT *, (rolling_vaccinations/population)*100 AS vaccination_pct 
FROM vaxvspop;

-- TEMP TABLE

-- CREATING A VIEW

CREATE VIEW pct_population_vaccinated AS
SELECT dea.continent, dea.location, dea.dates, dea.population,
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
        ORDER BY dea.location, dea.dates) AS rolling_vaccinations
    
    FROM covid_deaths dea
    JOIN covid_vaccinations vac
        ON dea.location = vac.location
        AND dea.dates = vac.dates
    WHERE dea.continent != "";