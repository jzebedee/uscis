#!/bin/bash
set -euxo pipefail

PARAMS="$@"

curl_chrome116 ${PARAMS} --compressed \
  --parallel \
  --parallel-max 2 \
  -H 'Referer: https://egov.uscis.gov/processing-times/' \
  --cookie-jar uscis.cookies
