CREATE TABLE IF NOT EXISTS foia_processing_time(
    "id"	INTEGER,
    "metricTimestamp"	TEXT,
    "metricName"	TEXT,
    "metricValue"	INTEGER,
    "trackId"	INTEGER,
    "officeId"	INTEGER,
    "officeCode"	TEXT,
    PRIMARY KEY("id")
) WITHOUT ROWID;