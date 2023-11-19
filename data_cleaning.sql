DELETE from "Consumer" c1
where (c1."Model",c1."Make")not in (select "Model","Make" from "Car");