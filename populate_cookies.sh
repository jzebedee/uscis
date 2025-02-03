#!/bin/bash
set -euxo pipefail

URL="https://egov.uscis.gov/processing-times/"

if [ -n "${STEALTH:-}" ]; then
  JSON_COOKIES="${TMPDIR:-/tmp}/uscis_cookies.json"
  COOKIE_JAR="uscis.cookies"
  curl --fail-with-body -s -S "${STEALTH_ENDPOINT}${URL}" > "$JSON_COOKIES"
  python3 convert_cookies.py "$JSON_COOKIES" > "$COOKIE_JAR"
else
  ./curl_request.sh "$URL"
fi