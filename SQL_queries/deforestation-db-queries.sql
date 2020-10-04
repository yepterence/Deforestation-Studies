-- Author: Terence Yep

-- Create a view named forestation that combines all 3 tables in dataset
CREATE VIEW forestation
AS
SELECT f.country_code, f.country_name, f.year, r.income_group, r.region, f.forest_area_sqkm, COALESCE(land_tab.total_land_area,0.01) total_land_area, f.forest_area_sqkm/total_land_area pct_forest_area
FROM (SELECT country_code, year, country_name, (total_area_sq_mi * 2.59) total_land_area FROM land_area) land_tab
JOIN forest_area f
ON f.year = land_tab.year AND f.country_code = land_tab.country_code
JOIN regions r
ON land_tab.country_code = r.country_code;

-- Global Situation
-- History of forest area(1990):

SELECT forest_area_sqkm
FROM forestation 
WHERE country_name = 'World'
AND year = '1990';
-- Assigning 2016 to year value in the WHERE clause will provide the value for 2016

-- Change (in sq km and percentage) in the forest area of the world from 1990 to 2016: 
SELECT ( a.forest_area_sqkm-b.forest_area_sqkm ) AS loss_sqkm,
 ( a.forest_area_sqkm-b.forest_area_sqkm ) * 100 / a.forest_area_sqkm
 loss_percent
FROM forestation a,
 forestation b
WHERE a.year = 1990
 AND b.year = 2016
 AND a.country_name = 'World'
 AND b.country_name = 'World'
LIMIT 1;


-- compare the amount of forest area lost between 1990 and 2016, and to which country's land mass is the area lost most similar to in 2016:
WITH ar_lost AS (SELECT b.year , ( a.forest_area_sqkm-b.forest_area_sqkm ) AS loss_sqkm
FROM forestation a,
 forestation b
WHERE a.year = 1990
 AND b.year = 2016
 AND a.country_name = 'World'
 AND b.country_name = 'World'
LIMIT 1)
SELECT f.country_name, f.total_land_area
FROM forestation f
JOIN ar_lost
ON f.year = ar_lost.year
WHERE f.total_land_area < ar_lost.loss_sqkm
ORDER BY 3 DESC
LIMIT 1;

-- REGIONAL OUTLOOK 
-- What was the percent forest of the entire world in 2016?
SELECT (total_forest/total_land)*100 pct_forest_world
FROM(SELECT f.year year_recorded,  SUM(forest_area_sqkm) total_forest, SUM(total_land_area) total_land
FROM forestation f
WHERE f.year = 2016 AND f.country_name = 'World' 
GROUP BY 1) sub
;

-- Which region had the HIGHEST percent forest in 2016, to 2 decimal places?
SELECT f.year year_recorded, f.region region_name,  (SUM(f.forest_area_sqkm)/SUM(f.total_land_area))*100 pct_forest 
FROM forestation f
WHERE f.year = 2016
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

-- and which had the LOWEST:
SELECT f.year year_recorded, f.region region_name,  (SUM(f.forest_area_sqkm)/SUM(f.total_land_area))*100 pct_forest 
FROM forestation f
WHERE f.year = 2016 
GROUP BY 1,2                                                                       
ORDER BY 3 
LIMIT 1;

-- What was the percent forest of the entire world in 1990? 
SELECT (total_forest/total_land)*100 pct_forest_world
FROM(SELECT f.year year_recorded,  SUM(forest_area_sqkm) total_forest, SUM(total_land_area) total_land
FROM forestation f
WHERE f.year = 1990 AND f.country_name = 'World' 
GROUP BY 1) fa_1990


-- Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
SELECT f.year year_recorded, f.region region_name,  (SUM(f.forest_area_sqkm)/SUM(f.total_land_area))*100 pct_forest 
FROM forestation f
WHERE f.year = 1990
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

-- Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016

CREATE VIEW region_pct_diff
AS
WITH fa_1990 AS
(SELECT f.region region_name, (SUM(f.forest_area_sqkm)/SUM(f.total_land_area))*100 pct_forest 
FROM forestation f
WHERE f.year = 1990
GROUP BY 1
ORDER BY 2 DESC
), 
fa_2016 AS 
(SELECT f.region region_name,  (SUM(f.forest_area_sqkm)/SUM(f.total_land_area))*100 pct_forest 
FROM forestation f
WHERE f.year = 2016
GROUP BY 1
ORDER BY 2 DESC
)

SELECT fa_2016.region_name, ROUND(fa_1990.pct_forest::numeric,2) forest_pct_1990, ROUND(fa_2016.pct_forest::numeric,2) forest_pct_2016
-- using ::numeric casts the float8 value to numeric which can then be rounded down to two digits.
FROM fa_1990 
JOIN fa_2016 
ON fa_2016.region_name = fa_1990.region_name
WHERE fa_2016.region_name NOT LIKE 'World';

-- which regions of the world DECREASED in forest area from 1990 to 2016?

SELECT region_name regions, forest_pct_1990 1990_forest_pct, forest_pct_2016 2016_forest_pct
FROM region_pct_diff
WHERE forest_pct_1990 - forest_pct_2016 > 0;

-- COUNTRY LEVEL DETAILS
-- Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? 
-- What was the difference in forest area for each?

WITH c_fa_1990 AS
(SELECT country_name, forest_area_sqkm fa_1990
FROM forestation 
WHERE year = 1990),
c_fa_2016 AS
(SELECT country_name countries, forest_area_sqkm fa_2016
FROM forestation 
WHERE year = 2016)

SELECT country_name countries, ROUND((c_fa_1990.fa_1990 - c_fa_2016.fa_2016)::numeric,2) AS fa_loss
FROM c_fa_1990
JOIN c_fa_2016
ON c_fa_2016.countries = c_fa_1990.country_name
WHERE c_fa_1990.fa_1990 - c_fa_2016.fa_2016 IS NOT NULL AND country_name NOT LIKE 'World'
ORDER BY fa_loss DESC
LIMIT 5;

-- Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? 
-- What was the percent change to 2 decimal places for each?
  WITH c_fa_1990 AS
  (SELECT country_name, forest_area_sqkm fa_1990
  FROM forestation 
  WHERE year = 1990),
  c_fa_2016 AS
  (SELECT country_name countries, forest_area_sqkm fa_2016
  FROM forestation 
  WHERE year = 2016)

  SELECT country_name countries, ROUND(((c_fa_1990.fa_1990 - c_fa_2016.fa_2016)*100/c_fa_1990.fa_1990)::numeric,2) AS pct_fa_loss
  FROM c_fa_1990
  JOIN c_fa_2016
  ON c_fa_2016.countries = c_fa_1990.country_name
  WHERE c_fa_1990.fa_1990 - c_fa_2016.fa_2016 IS NOT NULL AND country_name NOT LIKE 'World'
  ORDER BY fa_loss DESC
  LIMIT 5;