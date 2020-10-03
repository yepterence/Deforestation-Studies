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
GROUP BY 1)
;


SELECT year_recorded, country, land_area, region_name, (land_area-forest_area)/land_area *100 pct_forest_area
FROM forestation 
WHERE year_recorded = 1990 AND NOT country = 'World' 
ORDER BY pct_forest_area DESC;


