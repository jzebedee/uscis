#!/bin/bash
set -euxo pipefail

REFERER_HEADER='Referer: https://first.uscis.gov/'

./curl_request.sh "https://first.uscis.gov/api/public/foia-metrics" \
  -o foia-metrics.json \
  -H "$REFERER_HEADER"

sqlite3 uscis.db < create-foia-processing-time-table.sql

sqlite3 uscis.db < populate-foia-processing-time-table.sql
