CREATE TABLE IF NOT EXISTS form_types(
    form_key TEXT PRIMARY KEY,
    form_type TEXT,
    description_en TEXT,
    description_es TEXT
) WITHOUT ROWID;