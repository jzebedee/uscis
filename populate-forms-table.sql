INSERT INTO forms(name, description_en, description_es)
SELECT
 (form ->> '$.formName') AS name,
 (form ->> '$.formDescriptionEn') AS description_en,
 (form ->> '$.formDescriptionEs') AS description_es
FROM (SELECT json_each.value AS form FROM (SELECT json(CAST(readfile('response-forms.json') AS TEXT) -> '$.data.items') as forms), json_each(forms));
