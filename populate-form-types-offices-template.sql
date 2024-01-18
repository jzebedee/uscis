WITH form_offices_new AS (
  SELECT
    form_name,
    form_type AS form_key,
    (json_each.value ->> '$.office_code') AS office
  FROM(
    SELECT
      (response ->> '$.data.form_offices.form_name') AS form_name,
      (response ->> '$.data.form_offices.form_type') AS form_type,
      (response -> '$.data.form_offices.offices') AS offices
    FROM (SELECT json(CAST(readfile('%s') AS TEXT)) AS response)
  ), json_each(offices)
), form_offices_old AS (
  SELECT
    form_name,
    form_key,
    (json_each.value) AS office
  FROM form_types AS ft, json_each(ft.offices)
), form_offices_merged AS (
  SELECT
    form_name,
    form_key,
    json_group_array(office) AS offices
  FROM (
    SELECT * FROM form_offices_new AS fo
    LEFT JOIN form_offices_old AS ft
    ON ft.form_name = fo.form_name AND ft.form_key = fo.form_key
  )
)

UPDATE form_types AS ft
SET
  offices = fo.offices
FROM form_offices_merged AS fo
WHERE ft.form_name = fo.form_name AND ft.form_key = fo.form_key;