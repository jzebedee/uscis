WITH response_types_json AS (
  SELECT
    json_each.value
  FROM(
    (SELECT json(readfile('%s')) -> '$.data.form_types.subtypes' AS types)
  ), json_each(types)
), response_types AS (
  SELECT
    (value ->> '$.form_key') AS form_key,
    (value ->> '$.form_type') AS form_type,
    (value ->> '$.form_type_description_en') AS form_type_description_en,
    (value ->> '$.form_type_description_es') AS form_type_description_es
  FROM response_types_json
)

INSERT OR IGNORE INTO form_types
SELECT '%s', * FROM response_types;