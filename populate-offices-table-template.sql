INSERT OR IGNORE INTO offices
SELECT
 (office ->> '$.officeCode') AS code,
 (office ->> '$.officeDescription') AS description
FROM (SELECT json_each.value AS office FROM (SELECT (json(CAST(readfile('%s') AS TEXT)) -> '$.data.items') as offices), json_each(offices));
