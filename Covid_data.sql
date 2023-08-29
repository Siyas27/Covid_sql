show variables like "local_infile";

load data local infile 'C:\\Users\\Dell\\Documents\\project_material\\covid_deaths.csv'
into table covid_deaths
fields terminated by ","
ignore 16 rows;


load data local infile 'C:\\Users\\Dell\\Documents\\project_material\\covid_vaccination.csv'
into table covid_vaccination
fields terminated by ","
ignore 2 rows;

select * from covid_vaccination;

/* total case & total deaths */

select location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where location = "india"
order by date;

-- total cases vs population
select location, max(total_cases), population, max(( total_cases/ population))*100 as percent_population_affected
from covid_deaths
group by location, population
order by percent_population_affected desc;


select * from covid_deaths;

-- highest death count per population

select location, max(cast(total_deaths as unsigned ))  as totaldeath_count
from covid_deaths
group by location
order by totaldeath_count desc;

-- looking at total population VS how many got vaccinated 
-- that i'll get roll sum : all people vaccinated for particular local  divide by population of that location.

select dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(vac.new_vaccinations, unsigned)) over ( partition by dea.location order by dea.location, dea.date) as rollsum
from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location
AND dea.date = vac.date
order by 1,2;

-- now doing actucall versus: so putting cte

with cte as(
select dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(vac.new_vaccinations, unsigned)) over ( partition by dea.location order by dea.location, dea.date) as rollsum
from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location
AND dea.date = vac.date
order by 1,2)

select * , (rollsum/population)*100
from cte;

-- creating view to store data to get visualization later

create view cte as
with cte as(
select dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(vac.new_vaccinations, unsigned)) over ( partition by dea.location order by dea.location, dea.date) as rollsum
from covid_deaths dea
join covid_vaccination vac
on dea.location = vac.location
AND dea.date = vac.date
)

select * , (rollsum/population)*100
from cte;







