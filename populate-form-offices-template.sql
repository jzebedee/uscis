WITH form_offices AS (
  SELECT
  form_name AS name,
  json(printf('[%%s]', group_concat(json_each.value -> '$.office_code'))) AS offices
  FROM(
    SELECT
      (response -> '$.data.form_offices.offices') AS offices,
      (response ->> '$.data.form_offices.form_name') AS form_name
    FROM (SELECT json(readfile('%s')) AS response)
  ), json_each(offices)
)

UPDATE forms
SET offices = fo.offices
FROM form_offices AS fo
WHERE forms.name = fo.name;