WITH response_types_json AS (
  SELECT
    json_each.value
  FROM(
    (SELECT json(CAST(readfile('%s') AS TEXT)) -> '$.data.items' AS types)
  ), json_each(types)
), response_types AS (
  SELECT
    (value ->> '$.formKey') AS form_key,
    (value ->> '$.formType') AS form_type,
    (value ->> '$.formTypeDescriptionEn') AS form_type_description_en,
    (value ->> '$.formTypeDescriptionEs') AS form_type_description_es
  FROM response_types_json
)

INSERT OR IGNORE INTO form_types
SELECT '%s', *, json('[]') FROM response_types;
