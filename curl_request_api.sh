#!/bin/bash
set -euxo pipefail

PARAMS="$@"
REFERER_HEADER="Referer: https://egov.uscis.gov/processing-times/"

DEFAULTS=" --fail-with-body -s -S"
if [ -n "${SLOWMODE:-}" ]; then
  RATE_DEFAULTS=" --rate 5/s"
else
  RATE_DEFAULTS=" --parallel --parallel-max 2"
fi
COOKIE_JAR="uscis.cookies"
COOKIE_DEFAULTS=" -b ${COOKIE_JAR} --cookie-jar ${COOKIE_JAR}"

curl_chrome132 ${PARAMS} \
  ${DEFAULTS} \
  ${RATE_DEFAULTS} \
  ${COOKIE_DEFAULTS} \
  -H "$REFERER_HEADER"