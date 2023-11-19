
import matplotlib.pyplot as plt
import pandas as pd
import psycopg2
conn = psycopg2.connect(
    dbname="test_db",
    user="admin",
    password="admin",
    host="localhost",
    port="5432"
)
cur = conn.cursor()
cur.execute("""
SELECT
    eng."Engine_Type",
    cons."Year",
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
""")
result=cur.fetchall()

df = pd.DataFrame(result, columns=['Type', 'Year', 'Sales'])

df_pivot = df.pivot(index='Year', columns='Type', values='Sales')

plt.figure(figsize=(10, 6))
plt.bar(df_pivot.index, df_pivot['Thermal'] / 1e6, label='Thermal', color='brown')
plt.bar(df_pivot.index, df_pivot['Electric'] / 1e6, bottom=df_pivot['Thermal'] / 1e6, label='Electric', color='green')


plt.xlabel('Year')
plt.ylabel('Number of Cars Sold (in millions)')
plt.title('Car Sales by Year and Type (Electric vs Thermal)')


ax = plt.gca()
ax.set_yticklabels(['{:.1f} M'.format(yval) for yval in ax.get_yticks()])


plt.legend()

plt.savefig('Car_Sales_by_Year_Graph.png')
plt.show()
