#!/bin/bash
set -euxo pipefail

sqlite3 -noheader -separator '|' uscis.db 'SELECT form_name, form_key FROM form_types ORDER BY form_name, form_key;' | while IFS='|' read -r form_name form_key; do
  [ -z "${form_name}" ] && continue
  output_file="response-form-offices_${form_name}_${form_key}.json"
  ./curl_request_next_action.sh getOfficesScs "${form_name}" "${form_key}" -o "${output_file}"
  uv run normalize_next_response.py "${output_file}"
done
