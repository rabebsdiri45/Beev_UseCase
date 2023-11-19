# Beev_UseCase
# Data Understanding

## Initial Remarks

### `consumer_data.csv`

- Header issue: missing the 'make' column.
- Data mismatch: Approximately 96% of `(make, model)` combinations are incorrect and do not correlate with entries in `car_data.csv` (e.g., `model=Passat` assigned to `make=Tesla`).

### `car_data.csv`

- Duplicate entries: For the same `(make, model)` pair, there are multiple rows featuring different years, prices, and engine types, which could complicate analyses involving both datasets.

# Database Model

Implemented a straightforward approach by creating two tables corresponding to the datasets, each with an added `id` as a primary key.

## Schema Overview

(The database schema would be described or diagrammed here.)

## Column Types

- Chose `varchar(20)` for `make`, `model`, and `country` due to their typical length.
- `year`, `sales_volume`, and `price` are set as `integer`.
- `review_Score` is set as `float(1)`.
- Created an `enum` for `engine_type` with values `Electric` and `Thermal`.
- Both primary keys are set to auto-increment.

# From CSV to Database

Utilized Pandas for data reading and psycopg2 for database connections.

# Data Cleaning

Removed entries from the Customer table where the `(Make, Model)` pair does not exist in the Car table. No imputation criteria were provided for issues within the Car table, leading to the assumption that a Make could release various Model versions over time.

# Tasks Explanations

## SQL Queries
## Total number of cars by model by country
```sql

SELECT "Model", "Country", SUM("Sales_Volume") AS total_number
FROM "Consumer"
GROUP BY "Country", "Model";
```
## For each model, the country where it was sold the most
```sql
SELECT DISTINCT ON ("Model") "Model",
                             "Country",
                             SUM("Sales_Volume") AS total_sales_volume
FROM "Consumer"
GROUP BY "Model", "Country"
ORDER BY "Model", total_sales_volume DESC;
```
## Check if any model is sold in Germany but not in France
```sql
(SELECT DISTINCT "Model"
 FROM "Consumer"
 WHERE "Country" = 'Germany')
EXCEPT
(SELECT DISTINCT "Model"
 FROM "Consumer"
 WHERE "Country" = 'France');
```
## how much the average car costs in every country by engine type since we have the Engine_Type and Price in Car table and Country in Consumer table
## i need join operation but since the combination of  "Model", "Country", "Make" leads to many rows
## i used the distinct
```sql
SELECT c2."Country", "Engine_Type", AVG("Price")
FROM "Car" c1
JOIN (SELECT DISTINCT "Model", "Country", "Make" FROM "Consumer") c2
ON c1."Model" = c2."Model" AND c1."Make" = c2."Make"
GROUP BY "Country", "Engine_Type"
ORDER BY "Country";
```
## check the average ratings of electric cars vs thermal cars
## for each row in the Consumer table i needed it to match it with a row from the Car data to extract the "Engine_Type"
## but since not necessarily each year in the Consumer table   match a row in the Car table i opted for taking the closest previous year
## since it represents the latest release compared to the data point
##image
## this function will take the year , make and model and return a table of 1 row that represents the latest car release compared to the given date
```sql
CREATE OR REPLACE FUNCTION get_latest_car_before_year(_year INT, _make TEXT, _model TEXT)
RETURNS TABLE("Car_pk" INT, "Make" TEXT, "Model" TEXT, "Year" INT, "Price" INT, "Engine_Type" engine_type_enum) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c."Car_pk", c."Make"::TEXT, c."Model"::TEXT, c."Year", c."Price", c."Engine_Type"
    FROM
        "Car" c
    WHERE
        c."Year" <= _year AND c."Model" = _model AND c."Make" = _make
    ORDER BY
        c."Year" DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
```
## i calculated the average of review score for cars from the "Consumer" table, based on their engine type using the previously defined function get_latest_car_before_year.
```sql
SELECT eng."Engine_Type", AVG(cons."Review_Score") AS average_review_score
FROM (
    SELECT DISTINCT "Engine_Type"
    FROM "Car"
) eng
JOIN "Consumer" cons ON eng."Engine_Type" = (
    SELECT "Engine_Type"
    FROM get_latest_car_before_year(cons."Year", cons."Make", cons."Model")
)
GROUP BY eng."Engine_Type";
```
## dynamic version
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
## Bonus Task Queries
## i calculated the total sales volumes of electric and thermal engine cars for each year,based on records in the "Consumer" table.Then i grouped the sales by year and engine type

```sql
SELECT cons."Year", eng."Engine_Type", SUM(cons."Sales_Volume") AS total_sales_volume
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
```
## I used matplotlib, psycopg2 and Pandas to create the graph 
![alt text](Car_Sales_by_Year_Graph.png?row=true)
