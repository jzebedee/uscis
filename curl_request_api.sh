#!/bin/bash
set -euxo pipefail

PARAMS="$@"
REFERER_HEADER="Referer: https://egov.uscis.gov/processing-times/"

if [ -n "${SLOWMODE:-}" ]; then
  curl_chrome131 ${PARAMS} --compressed \
    --rate 5/s \
    -H "$REFERER_HEADER" \
    --cookie-jar uscis.cookies
else
  curl_chrome131 ${PARAMS} --compressed \
    --parallel \
    --parallel-max 2 \
    -H "$REFERER_HEADER" \
    --cookie-jar uscis.cookies
fi
