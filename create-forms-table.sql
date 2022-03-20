CREATE TABLE IF NOT EXISTS forms(
    name TEXT PRIMARY KEY,
    description_en TEXT,
    description_es TEXT,
    offices JSON
) WITHOUT ROWID;