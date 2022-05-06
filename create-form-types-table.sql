CREATE TABLE IF NOT EXISTS form_types(
    form_name TEXT,
    form_key TEXT,
    form_type TEXT,
    description_en TEXT,
    description_es TEXT,
    offices JSON,
    PRIMARY KEY("form_name","form_key")
) WITHOUT ROWID;