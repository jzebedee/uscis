#!/bin/bash
set -euxo pipefail

#ex: I-129F
form=$1
#ex: CSC
service_center=$2

sqlite3 uscis.db < query-processing-time-urls.sql | xargs -t curl -H 'Referer: https://egov.uscis.gov/processing-times/'