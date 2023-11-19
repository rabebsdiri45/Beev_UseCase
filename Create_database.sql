CREATE TYPE engine_type_enum AS ENUM ('Electric', 'Thermal');
create table "Car"
(
    "Car_pk"    serial primary key,
    "Make"        varchar(20) not null,
    "Model"       varchar(20) not null,
    "Year"        integer     not null,
    "Price"       integer     not null,
    "Engine_Type" engine_type_enum     not null
);


comment on column "Car"."Make" is 'the manufacture company';

comment on column "Car"."Model" is 'the car model';

comment on column "Car"."Year" is 'the release year';

comment on column "Car"."Price" is 'the price of the car';

create table "Consumer"
(
    "Consumer_pk"    serial primary key,
    "Country" varchar(20) not null,
    "Make"        varchar(20) not null,
    "Model"       varchar(20) not null,
    "Year"        integer     not null,
    "Review_Score"       float(1)     not null,
    "Sales_Volume" integer     not null
);
comment on column "Consumer"."Make" is 'the manufacture company';

comment on column "Consumer"."Model" is 'the car model';

comment on column "Consumer"."Year" is 'the sales year';

comment on column "Consumer"."Country" is 'the country of the sales';

comment on column "Consumer"."Review_Score" is 'the car review score';

comment on column "Consumer"."Sales_Volume" is 'how many cars were sold';