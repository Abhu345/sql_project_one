-- Rank countries within each continent based on:
-- a) Population density (Population/SurfaceArea).

select *,population/surfacearea as population_density,(rank()
 over(partition by continent order by population))rank_value from country;

-- b) GNP growth rate (GNP vs. GNPOld).-- 

select *,gnp/gnpold as growth_rate,rank() 
over(partition by continent order by population) rank_value from country;

-- c) Identify the top 3 most populous cities per region using `RANK()` or `DENSE_RANK()`.-- 

with populous_cities as 
(select city.name,city.population,country.region,rank()over(partition by region order by city.population desc )rank_value 
from country inner join city on city.countrycode=country.code)
select *from populous_cities where rank_value <=3;

-- d) Find the life expectancy quartiles (using `NTILE`) for each continent

select lifeexpectancy,ntile(4)over(partition by continent order by population)ntile_value from country;

-- 2. Dynamic Queries (Stored Procedures & Functions) 
--  Create a stored procedure that:
-- a) Accepts a continent and returns countries sorted by their population density.

delimiter //
create procedure population_density_procedure(in continent_name varchar(50))
begin
select name,population/surfacearea as population_density from country 
where continent=continent_name;
end //
delimiter ;

call population_density_procedure('Asia');

-- b) Allows optional filtering by life expectancy or surface area thresholds.

delimiter //
create procedure filter_procedure(in continent_name varchar(50))
begin
select name,lifeexpectancy,surfacearea from country
where continent=continent_name;
end //
delimiter ;
call population_density_procedure('Asia');

-- c) Write a stored function to calculate the percentage of official languages 
-- spoken globally for a given country.

delimiter //
create function official_language_percentage(countryname varchar (50))
returns decimal (10,2)
deterministic
begin
declare official_language int;
declare all_language int;
select sum(1) into all_language from (select distinct language from countrylanguage) total_language;
select sum(1) into official_language from countrylanguage 
where countrycode = countryName and IsOfficial = true;
return(official_language / all_language) * 100;
end //
delimiter ;

-- 3. Data Validation & Automation (Triggers) 
--  Implement triggers for:
-- a) Preventing insertion of cities with duplicate names within the same country.

delimiter //
create trigger avoid_duplicates
before insert on city 
for each row
begin
if new.name in(select name from city where new.countrycode=countrycode)
then
signal sqlstate '45000'
set MESSAGE_TEXT = 'you cannot insert duplicate values';
end if;
end//
delimiter ;

-- b) Automatically updating the `GNP` in the `Country` table whenever `GNPOld` 
-- changes.

delimiter //
create trigger update_gnp
before update on country
for each row
begin
set new.gnp=new.gnpold+(old.gnpold-old.gnp);
end //
delimiter ;

-- c) Log all deleted rows from the `CountryLanguage` table into a separate audit 
-- table.

create table audit_table as select *from countrylanguage where 1=9;
delimiter //
create trigger logs
before delete
on countrylanguage for each row
begin
insert into audit_table values(old.countrycode,old.language,old.isofficial,old.percentage); 
end //
delimiter ;
select *from audit_table;
delete from countrylanguage where language='Dutch'; 

-- 4. Advanced Data Retrieval (Joins, Subqueries, and CTEs) 
-- a) Create a CTE to recursively find the parent regions and their hierarchical 
-- population totals. 

with recursive parent_region_cte as ( select region, sum(population) as total_population
from country group by region)
select region, total_population from parent_region_cte;

-- b) Compare population data for countries with and without official languages.

with compare_population as(

select *from country inner join countrylanguage 
on country.code=countrylanguage.countrycode 
where countrylanguage.isofficial='f'

union all

select *from country inner join countrylanguage 
on country.code=countrylanguage.countrycode 
where countrylanguage.isofficial='t'
)select *from compare_population;

-- 5. Performance Optimization (Indexes & Query Optimization) 
-- a) Analyze the impact of adding indexes on columns such as `CountryCode`, 
-- `Population`, and `Region`.

create index improve_performance 
on country (code,population,region);

-- b) Use `EXPLAIN` to demonstrate query optimizations.
explain select *from country;

-- 6. Integrated Reporting (Views) 
-- Create a view that consolidates:
-- a) Country name, continent, population, life expectancy, and the percentage of 
-- official languages.

create view reporting 
as select name,continent,population,lifeexpectancy,percentage,language from country
inner join countrylanguage on country.code=countrylanguage.countrycode 
where countrylanguage.isofficial='t';

select *from reporting;

-- b) Provide filtering options on the view for specific continents or GNP ranges.

select *from reporting where continent='Asia';
