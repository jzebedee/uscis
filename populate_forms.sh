#!/bin/bash
set -euxo pipefail

./curl_request_api.sh "https://egov.uscis.gov/processing-times/api/forms" -o response-forms.json

sqlite3 uscis.db < create-forms-table.sql

sqlite3 uscis.db < populate-forms-table.sql