CREATE TABLE IF NOT EXISTS processing_time(
  "form_name" TEXT,
  "office_code" TEXT,
  "form_note_en" TEXT,
  "form_note_es" TEXT,
  "form_subtype" TEXT,
  "publication_date" TEXT,
  "range_upper" REAL,
  "range_upper_unit" TEXT,
  "range_lower" REAL,
  "range_lower_unit" TEXT,
  "service_request_date" TEXT,
  "subtype_info_en" TEXT,
  "subtype_info_es" TEXT,
  "subtype_note_en" TEXT,
  "subtype_note_es" TEXT,
  PRIMARY KEY("form_name","office_code","form_subtype")
) WITHOUT ROWID;