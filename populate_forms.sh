#!/bin/bash
set -euxo pipefail

./curl_request_next_action.sh 0021b2e16f25a9eb60b2c289205fbffd2f4d0c19d2 -o response-forms.json
uv run normalize_next_response.py response-forms.json

sqlite3 uscis.db < create-forms-table.sql

sqlite3 uscis.db < populate-forms-table.sql
