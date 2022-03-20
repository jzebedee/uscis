INSERT INTO forms(name, description_en, description_es)
SELECT
 (form ->> '$.form_name') AS name,
 (form ->> '$.form_description_en') AS description_en,
 (form ->> '$.form_description_es') AS description_es
FROM (SELECT json_each.value AS form FROM (SELECT (readfile('response-forms.json') -> '$.data.forms.forms') as forms), json_each(forms));