#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < query-processing-time-urls.sql | xargs -r -t -L 1 ./curl_request_next_action.sh

shopt -s nullglob
json_files=(response-processing-time_*.json)
if ((${#json_files[@]})); then
  uv run normalize_next_response.py "${json_files[@]}"
fi
