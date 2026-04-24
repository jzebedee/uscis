#!/bin/bash
set -euxo pipefail

sqlite3 -noheader -separator '|' uscis.db 'SELECT form_name, json_each.value AS office_code, form_key FROM form_types, json_each(offices) ORDER BY form_name, form_key, office_code;' | while IFS='|' read -r form_name office_code form_key; do
  [ -z "${form_name}" ] && continue
  output_file="response-processing-time_${form_name}_${office_code}_${form_key}.json"
  ./curl_request_next_action.sh getProcessingTime "${form_name}" "${form_key}" "${office_code}" -o "${output_file}"
  uv run normalize_next_response.py "${output_file}"
done
