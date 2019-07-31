/* 1. Retrieve all the names of all cities located in Peru, sorted alphabetically. 
Name your output attribute city. [Result Size: 30 rows of {"city":...}]*/

SELECT  u.name as city
FROM hw5.world x, x.mondial.country y, y.province z,
            CASE  WHEN is_array(z.city) THEN z.city
                  ELSE [z.city] END u
WHERE  y.name='Peru'
ORDER BY city;

/* 2. For each country return its name, its population, and the number of religions, sorted alphabetically by country. Report 0 religions for countries without religions. 
Name your output attributes country, population, num_religions. [Result Size:  238 rows of {"num_religions":..., "country":..., "population":...} (order of keys can differ)] */

SELECT c.name as country, c.population, coll_count(religions) as num_religions
FROM hw5.world x, x.mondial.country c
	LET religions = CASE WHEN c.religions IS MISSING THEN []
	      WHEN is_array(c.religions) THEN c.religions
              ELSE [c.religions] END;

/* 3. For each religion return the number of countries where it occurs; order them in decreasing number of countries. Name your output attributes religion, num_countries. 
[Result size: 37 of {"religion':..., "num_countries":...} (order of keys can differ)]*/

SELECT r.`#text` as religion, count(r.`#text`) as num_countries
FROM hw5.world x, x.mondial.country c,
	CASE WHEN c.religions IS MISSING THEN []
	      WHEN is_array(c.religions) THEN c.religions
              ELSE [c.religions] END r
group by r.`#text`;

/* 4. For each ethnic group, return the number of countries where it occurs, as well as the total population world-wide of that group.  Hint: you need to multiply the ethnicity’s percentage with the country’s population.  Use the functions float(x) and/or int(x) to convert a string to a float or to an int. Name your output attributes ethnic_group, num_countries, total_population. You can leave your final total_population as a float if you like. 
[Result Size: 262 of {"ethnic_group":..., "num_countries":..., "total_population":...} (order of keys can differ)]*/

select u.text as ethnic_group, count(*) as num_countries, sum(float(u.percent) * float(u.pop) /100.0) as total_population
from( select y.population as pop,
	    z.`#text` as text,
	    z.`-percentage` as percent from hw5.world x,
            x.mondial.country y,
   	    CASE WHEN y.ethnicgroups is missing THEN []
                 WHEN is_array(y.ethnicgroups) THEN y.ethnicgroups
                 ELSE [y.ethnicgroups] END z) 
     as u
group by u.text;

/* 5. Compute the list of all mountains, their heights, and the countries where they are located.  Here you will join the "mountain" collection with the "country" collection, on the country code.  You should return a list consisting of the mountain name, its height, the country code, and country name, in descending order of the height. Name your output attributes mountain, height, country_code, country_name. 
[Result Size: 272 rows of {"mountain":..., "height":..., "country_code":..., "country_name":...} (order of keys can differ)]*/
SELECT m.`-country` as country_code, m.name as mountain, m.height as height, y.name as country_name
FROM hw5.world x, x.mondial.mountain m, x.mondial.country y
where m.`-country`  = y.`-car_code`
ORDER BY height desc;

/* 6. Compute a list of countries with all their mountains.  This is similar to the previous problem, but now you will group the mountains for each country; return both the mountain name and its height.   Your query should return a list where each element consists of the country code, country name, and a list of mountain names and heights; order the countries by the number of mountains they contain, in descending order. Name your output attributes country_code, country_name, mountains. The attribute mountains should be a list of objects, each with the attributes mountain and height. 
[Result Size: 238 rows of {"country_code":..., "country_name":..., "mountains": [{"mountain":..., "height":...}, {"mountain":..., "height":...}, ...]} (order of keys can differ)]*/

SELECT y.`-car_code` AS country_code,  y.name as country_name,
       (SELECT  m.name as mountain, m.height as height
        FROM x.mondial.mountain m
        WHERE m.`-country` = y.`-car_code`) AS mountains
FROM hw5.world x, x.mondial.country y;

/* 7. Find all countries bordering two or more seas.  Here you need to join the "sea" collection with the "country" collection.  For each country in your list, return its code, its name, and the list of bordering seas, in decreasing order of the number of seas. Name your output attributes country_code, country_name, seas.  The attribute seas should be a list of objects, each with the attribute sea. 
[Result Size: 74 rows of {"country_code":..., "country_name":..., "seas": [{"sea":...}, {"sea":...}, ...]} (order of keys can differ)]*/

SELECT y.name AS country_name, seas, y.`-car_code` AS country_code
FROM hw5.world x, x.mondial.country y
LET seas = ( SELECT z.name AS sea
FROM x.mondial.sea z, split(z.`-country`, ' ') r
WHERE y.`-car_code` = r)
where coll_count(seas) > 2;

/* 8. Return all landlocked countries.  A country is landlocked if it borders no sea. For each country in your list, return its code, its name, in decreasing order of the country's area. 
Note: this should be an easy query to derive from the previous one. Name your output attributes country_code, country_name, area. 
[Result Size: 45 rows of {"country_code":..., "country_name":..., "area":...} (order of keys can differ)]*/

SELECT y.name AS countryName, y.`-car_code` AS country_code,  y.`-area` as area 
	FROM hw5.world x, x.mondial.country y
	LET m = ( SELECT z.name AS sea
FROM hw5.world x2, x2.mondial.sea z, split(z.`-country`, ' ') r
	WHERE y.`-car_code` = r)
WHERE coll_count(m) <1
ORDER BY area desc ;

/* 9. For this query you should also measure and report the runtime; it may be approximate. 
Find all distinct pairs of countries that share both a mountain and a sea.  Your query should return a list of pairs of country names.  
Avoid including a country with itself, like in (France,France), and avoid listing both (France,Korea) and (Korea,France) (not a real answer). 
Name your output attributes first_country, second_country. [Result Size: 7 rows of {"first_country":..., "second_country":...}]*/

SELECT distinct c1.name as first_country, c2.name as second_country
FROM
	(SELECT c.name as name, s.name as sea, m.name as mountain
	FROM hw5.world x, x.mondial.country c, x.mondial.sea s, x.mondial.mountain m, split(s.`-country`, " ") seas, split(m.`-country`, " ") mt
	WHERE seas = c.`-car_code` and mt = c.`-car_code` ) as c1,
	(SELECT c.name as name, s.name as sea, m.name as mountain
	FROM hw5.world x, x.mondial.country c, x.mondial.sea s, x.mondial.mountain m, split(s.`-country`, " ") seas, split(m.`-country`, " ") mt
	WHERE seas = c.`-car_code` and mt = c.`-car_code` ) as c2
WHERE c1.sea = c2.sea AND c1.mountain = c2.mountain AND c1.name < c2.name;
/*Duration of all jobs: 63.418 sec*/

/* 10. Create a new dataverse called hw5index*/
/*This created the type countryType, the dataset country, and a BTREE index on the attribute -car_code, which is also the primary key.  Both types are OPEN, which means that they may have other fields besides the three required fields -car_code, -area, and population.
Create two new types: mountainType and seaType, and two new datasets, mountain and sea.  Both should have two required fields: -id and -country.  Their key should be autogenerated, and of type uuid (see how we did it for the mondial dataset).  
Create an index of type KEYWORD (instead of BTREE) on the -country field (for both mountain and sea).  
Turn in the complete sequence of commands for creating all three types, datasets, and indices (for country, mountain, sea).*/

DROP DATAVERSE hw5index IF EXISTS;
CREATE DATAVERSE hw5index IF NOT EXISTS;
USE hw5index;

CREATE TYPE countryType AS OPEN {
    `-car_code`: string,
    `-area`: string,
    population: string
};

CREATE DATASET country(countryType)
   PRIMARY KEY `-car_code`;

CREATE INDEX countryID ON country(`-car_code`) TYPE BTREE;
LOAD DATASET country USING localfs(("path"="127.0.0.1:///Users/melodyyu/Desktop/Work/cse414/cse414-yuching3/hw/hw5/starter-code/country.adm"),("format"="adm"));

CREATE TYPE mountainType AS OPEN{
    `-id`: string ,
    `-country`: string,
    auto_id:uuid};

CREATE DATASET mountain(mountainType) PRIMARY KEY auto_id AUTOGENERATED;
CREATE INDEX mountainID ON mountain(`-country`) TYPE KEYWORD;
LOAD DATASET mountain USING localfs(("path"="127.0.0.1:///Users/melodyyu/Desktop/Work/cse414/cse414-yuching3/hw/hw5/starter-code/mountain.adm"),("format"="adm"));

CREATE TYPE seaType AS OPEN{
    `-id`: string,
    `-country`: string,
auto_id: uuid};

CREATE DATASET sea(seaType) PRIMARY KEY auto_id AUTOGENERATED;
CREATE INDEX seaID ON sea(`-country`) TYPE KEYWORD;
LOAD DATASET sea USING localfs(("path"="127.0.0.1:///Users/melodyyu/Desktop/Work/cse414/cse414-yuching3/hw/hw5/starter-code/sea.adm"),("format"="adm"));

/* 11. Re-run the query from 9. on the new dataverse hw5index.  
Report the new runtime.  [Result Size: 7 rows of {"first_country":..., "second_country":...}]*/

USE hw5index;
SELECT distinct c1.name as first_country, c2.name as second_country
FROM
	(SELECT c.name as name, s.name as sea, m.name as mountain
	FROM country c, sea s, mountain m, split(s.`-country`, " ") seas, split(m.`-country`, " ") mt
	WHERE seas = c.`-car_code` and mt = c.`-car_code` ) as c1,
	(SELECT c.name as name, s.name as sea, m.name as mountain
	FROM country c, sea s, mountain m, split(s.`-country`, " ") seas, split(m.`-country`, " ") mt
	WHERE seas = c.`-car_code` and mt = c.`-car_code` ) as c2
WHERE c1.sea = c2.sea AND c1.mountain = c2.mountain AND c1.name < c2.name;
/*Duration of all jobs: 0.094 sec*/

/* 12. Modify the query from 11. to return, for each pair of countries, the list of common mountains, and the list of common seas. Name your output attributes first_country, second_country, mountain, sea. 
[Result Size: 7 rows of {"mountains":[{"mountain":...}, ...], "seas":[{"sea":...}, ...], "first_country":..., "second_country":...}]*/

USE hw5index;

SELECT c1.name as first_country, c2.name as second_country, mountains, seas
FROM country c1, country c2
LET seas = (SELECT DISTINCT s.name as sea
            FROM sea s, split(s.`-country`, " ") s1, split(s.`-country`, " ") s2
            WHERE s1 = c1.`-car_code` and s2 = c2.`-car_code`),
mountains = (SELECT DISTINCT m.name as mountain
            FROM mountain m, split(m.`-country`, " ") m1, split(m.`-country`, " ") m2
            WHERE m1 = c1.`-car_code` and m2 = c2.`-car_code`)
WHERE c1.name < c2.name AND len(seas) > 0 AND len(mountains) > 0;
