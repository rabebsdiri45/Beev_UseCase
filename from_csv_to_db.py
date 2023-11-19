import psycopg2
import pandas as pd
conn = psycopg2.connect(
    dbname="test_db",
    user="admin",
    password="admin",
    host="localhost",
    port="5432"
)
cur = conn.cursor()

car=pd.read_csv("car_data.csv")
for index,row in car.iterrows():
    cur.execute(f""" 
    Insert Into "Car" ("Make","Model","Year","Price","Engine_Type") values ('{row["Make"]}','{row["Model"]}','{row["Year"]}','{row["Price"]}','{row["Engine Type"]}')
    """)


with open("consumer_data.csv",'r') as consumer:
    l=consumer.readlines()
for row in l[1:]:
    row=row.strip()
    line=row.split(',')
    cur.execute(f"""
    Insert into "Consumer" ("Country","Make","Model","Year","Review_Score","Sales_Volume") values ('{line[0]}','{line[1]}','{line[2]}','{line[3]}','{line[4]}','{line[5]}')
    """)


conn.commit()
cur.close()
conn.close()