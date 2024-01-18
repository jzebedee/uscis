INSERT OR IGNORE INTO offices
SELECT
 (office ->> '$.office_code') AS code,
 (office ->> '$.office_description') AS description
FROM (SELECT json_each.value AS office FROM (SELECT (json(CAST(readfile('%s') AS TEXT)) -> '$.data.form_offices.offices') as offices), json_each(offices));