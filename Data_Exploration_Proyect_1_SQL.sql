
USE PORTFOLIO_PROYECT;

SELECT *
FROM Covid_Deaths_1;

SELECT *
FROM Covid_Deaths_2;

SELECT *
FROM Covid_Vaccinations_1;

SELECT *
FROM Covid_Vaccinations_2;


SELECT Location, date, total_cases, new_cases, total_deaths, population
    FROM Covid_Deaths_1;

SELECT Location, date, total_cases, total_deaths, new_deaths, (CAST(total_deaths AS decimal(18,4)) / CAST(total_cases AS decimal(18, 4)))*100 AS Death_Percentage
    FROM Covid_Deaths_2	
	WHERE Location LIKE '%Peru%'
	--AND continent is not null
	ORDER BY 2 DESC, 5 DESC;

DROP TABLE Covid_Deaths_1;


SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,
                        MAX((CAST(total_cases AS decimal(18,4)) / CAST(population AS decimal(18, 4))))*100 AS Percent_Population_Infected
                    FROM Covid_Deaths_1
					--WHERE Location LIKE '%Peru%'
					WHERE continent is not null
					GROUP BY Location, population
                    ORDER BY 4 DESC;

SELECT Location, date, population,
                    total_cases, new_deaths,total_deaths,
                        (CAST(total_cases AS decimal(18,4)) / CAST(population AS decimal(18, 4)))*100 AS Percent_Population
                    FROM Covid_Deaths_1
                    WHERE Location LIKE '%Andorra%'
                    AND continent is not null
                    ORDER BY 2 DESC

SELECT date, SUM (new_cases)
FROM Covid_Deaths_1
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


SELECT date,
       SUM(ISNULL(new_cases, 0)) AS Total_New_Cases,
       SUM(ISNULL(new_deaths, 0)) AS Total_New_Deaths,
       CASE
           WHEN SUM(ISNULL(new_cases, 0)) = 0 THEN 0  -- Para evitar la división por cero
           ELSE (SUM(ISNULL(new_deaths, 0)) / SUM(ISNULL(new_cases, 0))) * 100
       END AS DeathPercentage
FROM Covid_Deaths_1
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1 DESC, 2;


SELECT 
    date,
    SUM(ISNULL(new_cases, 0)) AS Total_New_Cases,
    SUM(ISNULL(new_deaths, 0)) AS Total_New_Deaths,
    FORMAT(
        CASE
            WHEN SUM(ISNULL(new_cases, 0)) = 0 THEN 0  -- Para evitar la división por cero
            ELSE (SUM(ISNULL(new_deaths, 0)) / SUM(ISNULL(new_cases, 0))) * 100
        END,
        'N2' -- 'N2' indica dos lugares decimales, puedes ajustar según tus necesidades
    ) AS DeathPercentage
FROM 
    Covid_Deaths_1
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    date DESC, Total_New_Deaths DESC;


SELECT 
    date,
    SUM(ISNULL(new_cases, 0)) AS Total_New_Cases,
    SUM(ISNULL(new_deaths, 0)) AS Total_New_Deaths,
    CASE
        WHEN SUM(ISNULL(new_cases, 0)) = 0 THEN 0  -- Para evitar la división por cero
        ELSE CAST(SUM(ISNULL(new_deaths, 0)) AS DECIMAL(18, 4)) / CAST(SUM(ISNULL(new_cases, 0)) AS DECIMAL(18, 4)) * 100
    END AS DeathPercentage
FROM 
    Covid_Deaths_1
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    date DESC, Total_New_Cases DESC;

SELECT * 
FROM Covid_Deaths_1;

SELECT * 
FROM Covid_Vaccinations_1;

USE PORTFOLIO_PROYECT;

DROP TABLE -- Covid_Deaths_1;

SELECT *
FROM Covid_Deaths_1 AS Dea
JOIN Covid_Vaccinations_1 AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date;


With PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM (CAST(Vac.new_vaccinations AS float )) OVER (Partition By Dea.location Order By Dea.location,
Dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM Covid_Deaths_1 AS Dea
JOIN Covid_Vaccinations_1 AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is not null
--ORDER BY 2, 3
)
SELECT * , (RollingPeopleVaccinated / population) * 100
FROM PopvsVac;

-- Temp Table:

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
                Continent varchar(100),
                Location varchar (100),
                Date datetime,
                Population numeric,
                New_Vaccinations numeric,
                RollingPeopleVaccinated numeric
            )

INSERT INTO #PercentPopulationVaccinated
            SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
                        SUM (CAST(Vac.new_vaccinations AS float )) OVER (Partition By Dea.location Order By Dea.location,
                        Dea.date) AS RollingPeopleVaccinated
                        FROM Covid_Deaths_1 AS Dea
                            JOIN Covid_Vaccinations_1 AS Vac
                                ON Dea.location = Vac.location
                        AND Dea.date = Vac.date
                    WHERE Dea.continent is not null
                    ;

SELECT * , (RollingPeopleVaccinated / population) * 100
FROM #PercentPopulationVaccinated;

-- Creating view to store data for later visualizations


CREATE View PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
                        SUM (CAST(Vac.new_vaccinations AS float )) OVER (Partition By Dea.location Order By Dea.location,
                        Dea.date) AS RollingPeopleVaccinated
                        FROM Covid_Deaths_1 AS Dea
                            JOIN Covid_Vaccinations_1 AS Vac
                                ON Dea.location = Vac.location
                        AND Dea.date = Vac.date
                    WHERE Dea.continent is not null;
					--ORDER BY 2,3;











