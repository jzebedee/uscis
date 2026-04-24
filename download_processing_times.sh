#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < query-processing-time-urls.sql | xargs -r -t -L 1 ./curl_request_next_action.sh

uv run normalize_next_response.py response-processing-time_*.json
