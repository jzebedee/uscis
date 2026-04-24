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
    (doc -> '$.data.data.processingTime') AS pt,
    true_office_code
  FROM json_doc
), pt_subtypes_doc AS (
  SELECT
    (pt ->> '$.formName') AS form_name,
    true_office_code AS office_code,
--  (pt ->> '$.office_code') AS office_code,
    (pt ->> '$.formNoteEn') AS form_note_en,
    (pt ->> '$.formNoteEs') AS form_note_es,
    json_each.value AS subtype
  FROM pt_doc, json_each(pt -> '$.subtypes')
), pt_record AS (
  SELECT
    form_name,
    office_code,
    form_note_en,
    form_note_es,
    (subtype ->> '$.formType') AS form_subtype,
    (subtype ->> '$.publicationDate') AS publication_date,
    (subtype ->> '$.range[0].value') AS range_upper,
    (subtype ->> '$.range[0].unitEn') AS range_upper_unit,
    (subtype ->> '$.range[1].value') AS range_lower,
    (subtype ->> '$.range[1].unitEn') AS range_lower_unit,
    (subtype ->> '$.serviceRequestDate') AS service_request_date,
    (subtype ->> '$.subtypeInfoEn') AS subtype_info_en,
    (subtype ->> '$.subtypeInfoEs') AS subtype_info_es,
    (subtype ->> '$.subtypeNoteEn') AS subtype_note_en,
    (subtype ->> '$.subtypeNoteEs') AS subtype_note_es
  FROM pt_subtypes_doc
)

INSERT INTO processing_time
SELECT * FROM pt_record;
