#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < query-processing-time-urls.sql | xargs -t curl -s -S -H 'Referer: https://egov.uscis.gov/processing-times/'