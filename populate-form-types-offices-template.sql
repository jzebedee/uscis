WITH form_offices_new AS (
  SELECT
    file_args.form_name,
    file_args.form_key,
    json_group_array(json_each.value ->> '$.officeCode') AS offices
  FROM (
    SELECT
      '%s' AS filename,
      '%s' AS form_name,
      '%s' AS form_key
  ) AS file_args,
  json_each((SELECT json(CAST(readfile(file_args.filename) AS TEXT)) -> '$.data.items'))
  GROUP BY file_args.form_name, file_args.form_key
)

UPDATE form_types AS ft
SET
  offices = fo.offices
FROM form_offices_new AS fo
WHERE ft.form_name = fo.form_name AND ft.form_key = fo.form_key;
