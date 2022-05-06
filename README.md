# USCIS Dataset

Daily datasets of USCIS form processing times

## About

The U.S. Citizenship and Immigration Services (USCIS) provides estimated [case processing times](https://egov.uscis.gov/processing-times/more-info) that vary by form and service center. These estimates include both an estimate of the case adjudication time as well as the _case inquiry date_, which determines when an applicant may contact USCIS regarding a case that is outside of normal processing times.

Unfortunately, these estimates are updated silently without any notification or record, sometimes multiple times per day. This project is an attempt to provide transparency for applicants who may be surprised to find that their case inquiry date was changed without their knowledge.

## How it works

The dataset releases are produced on a daily cron schedule that scrapes the USCIS case processing time API and compiles the results into a SQLite database.

The raw JSON results are also collected into a [SQLite archive](https://www.sqlite.org/sqlar.html) and published as an artifact, in the case of debugging or if there's additional information to extract. These artifacts are _not_ a permanent collection and will be removed eventually based on the [artifact retention period](https://docs.github.com/en/organizations/managing-organization-settings/configuring-the-retention-period-for-github-actions-artifacts-and-logs-in-your-organization).

## Changelog

### v0.2 - 2022-05-05

* Office data is now grouped by form subtype in the `form_types` table
* JSON result artifacts are now published in each action run

#### Schema

##### `forms` table
```sql
CREATE TABLE forms(
    name TEXT PRIMARY KEY,
    description_en TEXT,
    description_es TEXT
) WITHOUT ROWID
```

##### `offices` table
```sql
CREATE TABLE offices(
    code TEXT PRIMARY KEY,
    description TEXT
) WITHOUT ROWID
```

##### `processing_time` table
```sql
CREATE TABLE processing_time(
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
) WITHOUT ROWID
```

##### `form_types` table
```sql
CREATE TABLE form_types(
    form_name TEXT,
    form_key TEXT,
    form_type TEXT,
    description_en TEXT,
    description_es TEXT,
    offices JSON,
    PRIMARY KEY("form_name","form_key")
) WITHOUT ROWID
```

##### `selftest` table
Used for [SQLite database integrity self-tests](https://www.sqlite.org/cli.html#database_content_self_tests)

### v0.1 - 2022-03-21

* Initial release

#### Schema

##### `forms` table
```sql
CREATE TABLE forms(
    name TEXT PRIMARY KEY,
    description_en TEXT,
    description_es TEXT,
    offices JSON
) WITHOUT ROWID
```

##### `offices` table
```sql
CREATE TABLE offices(
    code TEXT PRIMARY KEY,
    description TEXT
) WITHOUT ROWID
```

##### `processing_time` table
```sql
CREATE TABLE processing_time(
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
) WITHOUT ROWID
```

##### `selftest` table
Used for [SQLite database integrity self-tests](https://www.sqlite.org/cli.html#database_content_self_tests)
