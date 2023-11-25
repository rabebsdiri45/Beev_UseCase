-- the total number of cars by model by country
SELECT "Model", "Country", sum("Sales_Volume") as total_number
FROM "Consumer"
GROUP BY "Country", "Model";
-- for each model, the country where it was sold the most
SELECT DISTINCT ON ("Model") "Model",
                             "Country",
                             SUM("Sales_Volume") AS total_sales_volume
FROM "Consumer"
GROUP BY "Model",
         "Country"
ORDER BY "Model",
         total_sales_volume DESC;

-- check if any model is sold in the USA but not in France
(SELECT DISTINCT "Model"
 FROM "Consumer"
 WHERE "Country" = 'USA')
EXCEPT
(SELECT DISTINCT "Model"
 FROM "Consumer"
 WHERE "Country" = 'France');
-- how much the average car costs in every country by engine type
-- since we have the Engine_Type and Price in Car table and Country in Consumer table
-- i need join operation but since the combination of  "Model", "Country", "Make" leads to many rows
--i used the distinct
select c2."Country", "Engine_Type", avg("Price")
FROM "Car" c1
         join (select distinct "Model", "Country", "Make" from "Consumer") c2
              on c1."Model" = c2."Model" and c1."Make" = c2."Make"
group by "Country", "Engine_Type"
order by "Country";
-- check the average ratings of electric cars vs thermal cars
--for each row in the Consumer table i needed it to match it with a row from the Car data to extract the "Engine_Type"
--but since not necessarily each year in the Consumer table   match a row in the Car table i opted for taking the closest previous year
--since it represents the latest release compared to the data point
--image
-- this function will take the year , make and model and return a table of 1 row that represents the latest car release compared to the given date
-- i calculated the average of review score for cars from the "Consumer" table, based on their engine type using the previously defined function get_latest_car_before_year.
(select 'Electric', avg("Review_Score")
 from "Consumer"
 where (select "Engine_Type" from get_latest_car_before_year("Year", "Make", "Model")) = 'Electric')
union
(select 'Thermal', avg("Review_Score")
    from "Consumer"
    where (select "Engine_Type" from get_latest_car_before_year("Year", "Make", "Model")) = 'Thermal'
    );
--dynamic version
SELECT
    eng."Engine_Type",
    AVG(cons."Review_Score") as average_review_score
FROM (
    SELECT DISTINCT "Engine_Type"
    FROM "Car"
) eng
JOIN "Consumer" cons ON eng."Engine_Type" = (
    SELECT "Engine_Type"
    FROM get_latest_car_before_year(cons."Year", cons."Make", cons."Model")
)
GROUP BY eng."Engine_Type";


----------

--the bonus task queries
--i calculated the total sales volumes of electric and thermal engine cars for each year,
-- based on records in the "Consumer" table.
-- then i grouped the sales by year and engine type
(select "Year", 'Electric', sum("Sales_Volume")
 from "Consumer"
 where (select "Engine_Type" from get_latest_car_before_year("Year", "Make", "Model")) = 'Electric'
 group by "Year")
union
(select "Year", 'Thermal', sum("Sales_Volume")
 from "Consumer"
 where (select "Engine_Type" from get_latest_car_before_year("Year", "Make", "Model")) = 'Thermal'
 group by "Year")
order by "Year";
---more dynamic version
SELECT
    cons."Year",
    eng."Engine_Type",
    SUM(cons."Sales_Volume") as total_sales_volume
FROM (
    SELECT DISTINCT "Engine_Type"
    FROM "Car"
) eng
JOIN "Consumer" cons ON eng."Engine_Type" = (
    SELECT "Engine_Type"
    FROM get_latest_car_before_year(cons."Year", cons."Make", cons."Model")
)
GROUP BY cons."Year", eng."Engine_Type"
ORDER BY cons."Year";





