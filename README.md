# Beev_UseCase
# Data Understanding

## Initial Remarks

### `consumer_data.csv`

- Header issue: missing the 'make' column.
- Data mismatch: Approximately 96% of `(make, model)` combinations are incorrect and do not correlate with entries in `car_data.csv` (e.g., `model=Passat` assigned to `make=Tesla`).

### `car_data.csv`

- Duplicate entries: For the same `(make, model)` pair, there are multiple rows featuring different years, prices, and engine types, which could complicate analyses involving both datasets.

# Database Model 
[Create_database.sql file link](Create_database.sql)

Implemented a straightforward approach by creating two tables corresponding to the datasets, each with an added `id` as a primary key.

## Schema Overview

![alt text](schema.png?row=true)

## Column Types

- Chose `varchar(20)` for `make`, `model`, and `country` due to their typical length.
- `year`, `sales_volume`, and `price` are set as `integer`.
- `review_Score` is set as `float(1)`.
- Created an `enum` for `engine_type` with values `Electric` and `Thermal`.
- Both primary keys are set to auto-increment.

# From CSV to Database
[from_csv_to_db.py file link](from_csv_to_db.py)
Utilized Pandas for data reading and psycopg2 for database connections.

# Data Cleaning
[data_cleaning.sql file link](data_cleaning.sql)
I deleted the rows from the Customer table where the pair (Make, Model) does not exist in the Car table.
Although I can see problems in the Car table that I mentioned above , there is no criteria for the imputation. So I assumed that it could be that a company (Make) can release different variation of the same Model (Thermal/Electric) over the years or even the same year.
```sql
DELETE from "Consumer" c1
where (c1."Model",c1."Make")not in (select "Model","Make" from "Car");
```
# Tasks 
[Queries.sql file link](Queries.sql)
## SQL Queries
# Question A
Total number of cars by model by country
```sql

SELECT "Model", "Country", SUM("Sales_Volume") AS total_number
FROM "Consumer"
GROUP BY "Country", "Model";
```
Query result : [result link](results/Query1.csv) <br>
# Question B
For each model, the country where it was sold the most
```sql
SELECT DISTINCT ON ("Model") "Model",
                             "Country",
                             SUM("Sales_Volume") AS total_sales_volume
FROM "Consumer"
GROUP BY "Model", "Country"
ORDER BY "Model", total_sales_volume DESC;
```
Query result : [result link](results/Query2.csv) <br>
# Question C
Check if any model is sold in USA but not in France
```sql
(SELECT DISTINCT "Model"
 FROM "Consumer"
 WHERE "Country" = 'USA')
EXCEPT
(SELECT DISTINCT "Model"
 FROM "Consumer"
 WHERE "Country" = 'France');
```
Query result : empty <br>
# Question D
How much the average car costs in every country by engine type since we have the Engine_Type and Price in Car table and Country in Consumer table
I need join operation but since the combination of  "Model", "Country", "Make" leads to many rows
I used the distinct
```sql
SELECT c2."Country", "Engine_Type", AVG("Price")
FROM "Car" c1
JOIN (SELECT DISTINCT "Model", "Country", "Make" FROM "Consumer") c2
ON c1."Model" = c2."Model" AND c1."Make" = c2."Make"
GROUP BY "Country", "Engine_Type"
ORDER BY "Country";
```
Query result : [result link](results/Query4.csv) <br>
Check the average ratings of electric cars vs thermal cars
for each row in the Consumer table i needed it to match it with a row from the Car data to extract the "Engine_Type"
but since not necessarily each year in the Consumer table   match a row in the Car table i opted for taking the closest previous year
since it represents the latest release compared to the data point
![alt text](Func_diagram.png?row=true)
This function will take the year , make and model and return a table of 1 row that represents the latest car release compared to the given date
[Functions.sql file link](Functions.sql) 
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
# Question E
I calculated the average of review score for cars from the "Consumer" table, based on their engine type using the previously defined function get_latest_car_before_year.
```sql
(select 'Electric'as Engine_Type, avg("Review_Score")
 from "Consumer"
 where (select "Engine_Type" from get_latest_car_before_year("Year", "Make", "Model")) = 'Electric')
union
(select 'Thermal'as Engine_Type, avg("Review_Score")
    from "Consumer"
    where (select "Engine_Type" from get_latest_car_before_year("Year", "Make", "Model")) = 'Thermal'
    );
```
Query result : [result link](results/Query5.csv) <br>
Dynamic version
```sql
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
```
## Bonus Task Queries
I calculated the total sales volumes of electric and thermal engine cars for each year,based on records in the "Consumer" table.Then i grouped the sales by year and engine type

```sql
(select "Year", 'Electric'as Engine_Type, sum("Sales_Volume")
 from "Consumer"
 where (select "Engine_Type" from get_latest_car_before_year("Year", "Make", "Model")) = 'Electric'
 group by "Year")
union
(select "Year", 'Thermal'as Engine_Type, sum("Sales_Volume")
 from "Consumer"
 where (select "Engine_Type" from get_latest_car_before_year("Year", "Make", "Model")) = 'Thermal'
 group by "Year")
order by "Year";
```
Query result : [result link](results/Query6.csv) <br>
Dynamic version 
```sql
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
```
I used matplotlib, psycopg2 and Pandas to create the graph
[Graph_from_db.py file link](Graph_from_db.py)
## The output bar plot
![alt text](Car_Sales_by_Year_Graph.png?row=true)
