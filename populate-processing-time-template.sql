WITH json_doc AS (
  SELECT json(readfile('%s')) AS doc
), pt_doc AS (
  SELECT (doc -> '$.data.processing_time') AS pt FROM json_doc
), pt_subtypes_doc AS (
  SELECT
    (pt ->> '$.form_name') AS form_name,
    (pt ->> '$.office_code') AS office_code,
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
    (subtype ->> '$.range[1].value') AS range_lower,
    (subtype ->> '$.range[0].unit') AS range_unit,
    (subtype ->> '$.service_request_date') AS service_request_date,
    (subtype ->> '$.subtype_info_en') AS subtype_info_en,
    (subtype ->> '$.subtype_info_es') AS subtype_info_es,
    (subtype ->> '$.subtype_note_en') AS subtype_note_en,
    (subtype ->> '$.subtype_note_es') AS subtype_note_es
  FROM pt_subtypes_doc
)

INSERT INTO processing_time
SELECT * FROM pt_record;