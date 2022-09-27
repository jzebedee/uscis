#!/bin/bash
set -euxo pipefail

curl -s -S 'https://egov.uscis.gov/processing-times/api/forms' -H 'Referer: https://egov.uscis.gov/processing-times/' -o response-forms.json

which sqlite3

sqlite3 uscis.db < create-forms-table.sql

sqlite3 uscis.db < populate-forms-table.sql