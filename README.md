# Beev_UseCase
# Data Understanding

## Initial Remarks

### consumer_data.csv

- The header is missing the 'make' column.
- A significant issue is the mismatch between `make` and `model` (approximately 96% of the data); these combinations do not exist in `car_data.csv`. For instance, the model `Passat` is incorrectly assigned to make `Tesla`.

### car_data.csv

- There are multiple rows for the same `(Make, Model)` pair with different attributes such as years, prices, and engine types. This will pose a problem when attempting to join the two datasets for any analysis.

# Database Model

A simplistic approach was taken to model the database, creating two tables that correspond to the datasets with the addition of an `id` as a primary key.

## Schema Description

(Here you would typically insert a diagram or description of your database schema)

## Column Types

- `varchar(20)` for `Make`, `Model`, and `Country` since they are short strings that usually do not exceed 20 characters.
- `integer` for `Year`, `Sales_volume`, and `Price`.
- `float(1)` for `Review_Score`.
- `enum` for `Engine_type`, composed of `Electric` and `Thermal`.
- Auto-incremented primary keys.

# From CSV to Database

Pandas was utilized for reading data, and psycopg2 for database connection.

# Data Cleaning

Rows from the Customer table where the `(Make, Model)` pair does not exist in the Car table were removed. Despite issues in the Car table, no criteria for imputation were provided. It is assumed that a company (Make) could release different variations of the same Model (Thermal/Electric) over the years or even within the same year.

# Tasks Explanations

## Total Number of Cars by Model by Country

```sql
SELECT "Model", "Country", SUM("Sales_Volume") AS total_number
FROM "Consumer"
GROUP BY "Country", "Model";

