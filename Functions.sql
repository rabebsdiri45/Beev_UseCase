CREATE OR REPLACE FUNCTION get_latest_car_before_year(_year INT, _make TEXT, _model TEXT)
RETURNS TABLE("Car_pk" INT,"Make" TEXT, "Model" TEXT, "Year" INT,"Price" INT,"Engine_Type" engine_type_enum) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c."Car_pk",
        c."Make"::TEXT,
        c."Model"::TEXT,
        c."Year",
        c."Price",
        c."Engine_Type"
    FROM
        "Car" c
    WHERE
        c."Year" <= _year
        AND c."Model" = _model
        AND c."Make" = _make
    ORDER BY
        c."Year" DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
