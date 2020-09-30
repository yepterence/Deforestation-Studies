CREATE VIEW forestation 
AS
SELECT fa.country_name country, fa.country_code country_code, fa.year year_recorded, fa.forest_area_sqkm forest_area, la.total_area_sq_mi*2.59 land_area, r.region region_name, r.income_group income_grp
FROM forest_area fa
JOIN land_area la
ON fa.country_name = la.country_name AND fa.country_code = la.country_code
JOIN regions r
ON r.country_name = fa.country_name AND r.country_code = fa.country_code;


-- History of forest area(1990):

SELECT forest_area_sqkm
FROM forestation 
WHERE country_name = 'World'
AND year = '1990';

-- 2016 forest area:

SELECT forest_area_sqkm
FROM forestation
WHERE country_name = 'World'
AND year = '2016';


-- Difference: 
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

-- Land area and value:
SELECT * 
FROM land_area
WHERE total_area_sq_mi * 2.59 < 1324449
AND year = 2016
ORDER BY total_area_sq_mi DESC;


-- percent forest area of largest forested area:
SELECT year_recorded, country, region_name, (land_area-forest_area)/land_area *100 pct_forest_area
FROM forestation 
WHERE year_recorded = 2016 AND NOT country = 'World' 
ORDER BY pct_forest_area DESC;

-- TO DO : Need to deal with NULL values in db

-- REGIONAL OUTLOOK 
-- pct total land area designated forested area:

SELECT year_recorded, country, land_area, region_name, (land_area-forest_area)/land_area *100 pct_forest_area
FROM forestation 
WHERE year_recorded = 2016 AND country = 'World' 
ORDER BY pct_forest_area DESC;


SELECT year_recorded, country, land_area, region_name, (land_area-forest_area)/land_area *100 pct_forest_area
FROM forestation 
WHERE year_recorded = 1990 AND NOT country = 'World' 
ORDER BY pct_forest_area DESC;


