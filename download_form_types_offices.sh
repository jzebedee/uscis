#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < query-form-type-offices-urls.sql | xargs -r -t -L 1 ./curl_request_next_action.sh

uv run normalize_next_response.py response-form-offices_*.json
