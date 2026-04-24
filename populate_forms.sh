#!/bin/bash
set -euxo pipefail

./curl_request_next_action.sh getFormNumbers -o response-forms.json
uv run normalize_next_response.py response-forms.json

sqlite3 uscis.db < create-forms-table.sql

sqlite3 uscis.db < populate-forms-table.sql
