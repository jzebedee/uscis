#!/bin/bash
set -euxo pipefail

sqlite3 -noheader -separator '|' uscis.db 'SELECT name FROM forms ORDER BY name;' | while IFS='|' read -r form; do
  [ -z "${form}" ] && continue
  output_file="response-form-types_${form}.json"
  ./curl_request_next_action.sh getFormCategories "${form}" -o "${output_file}"
  uv run normalize_next_response.py "${output_file}"
done
