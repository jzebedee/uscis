WITH args1 AS (
  SELECT
    filename,
    substr(filename, length('response-processing-time_')+1) AS no_prefix
  FROM (SELECT '%s' AS filename)
), args2 AS (
  SELECT
    *,
    substr(no_prefix, 1, length(no_prefix)-5) AS no_ext
  FROM args1
), args3 AS (
  SELECT
    *,
    substr(no_ext, 1, instr(no_ext, '_')-1) AS form_name,
    substr(no_ext, instr(no_ext, '_')+1, 3) AS office_code,
    substr(no_ext, instr(no_ext, '_')+5) AS form_subtype
  FROM args2
), json_doc AS (
  SELECT
    json(CAST(readfile(filename) AS TEXT)) AS doc,
    office_code AS true_office_code
  FROM args3
), pt_doc AS (
  SELECT
    (doc -> '$.data.processing_time') AS pt,
    true_office_code
  FROM json_doc
), pt_subtypes_doc AS (
  SELECT
    (pt ->> '$.form_name') AS form_name,
    true_office_code AS office_code,
--  (pt ->> '$.office_code') AS office_code,
    (pt ->> '$.form_note_en') AS form_note_en,
    (pt ->> '$.form_note_es') AS form_note_es,
    json_each.value AS subtype
  FROM pt_doc, json_each(pt -> '$.subtypes')
), pt_record AS (
  SELECT
    form_name,
    office_code,
    form_note_en,
    form_note_es,
    (subtype ->> '$.form_type') AS form_subtype,
    (subtype ->> '$.publication_date') AS publication_date,
    (subtype ->> '$.range[0].value') AS range_upper,
    (subtype ->> '$.range[0].unit') AS range_upper_unit,
    (subtype ->> '$.range[1].value') AS range_lower,
    (subtype ->> '$.range[1].unit') AS range_lower_unit,
    (subtype ->> '$.service_request_date') AS service_request_date,
    (subtype ->> '$.subtype_info_en') AS subtype_info_en,
    (subtype ->> '$.subtype_info_es') AS subtype_info_es,
    (subtype ->> '$.subtype_note_en') AS subtype_note_en,
    (subtype ->> '$.subtype_note_es') AS subtype_note_es
  FROM pt_subtypes_doc
)

INSERT INTO processing_time
SELECT * FROM pt_record;