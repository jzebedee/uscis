#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < query-processing-time-urls.sql | xargs -r -t -L 1 ./curl_request_next_action.sh

for json_file in response-processing-time_*.json
do
  uv run normalize_next_response.py "$json_file"
done
