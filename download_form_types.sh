#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < query-form-types-urls.sql | xargs -r -t -L 1 ./curl_request_next_action.sh

./normalize_next_response.py response-form-types_*.json
