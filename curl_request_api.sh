#!/bin/bash
set -euxo pipefail

REFERER_HEADER="Referer: https://egov.uscis.gov/processing-times/"

if [ -n "${RATE:-}" ]; then
  RATE_DEFAULTS=(--rate "$RATE")
else
  RATE_DEFAULTS=(--parallel --parallel-max 2)
fi
COOKIE_JAR="uscis.cookies"

curl_chrome_uscis "$@" \
  --fail-with-body -s -S \
  "${RATE_DEFAULTS[@]}" \
  -b "$COOKIE_JAR" --cookie-jar "$COOKIE_JAR" \
  -H "$REFERER_HEADER"
