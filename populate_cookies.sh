#!/bin/bash
set -euxo pipefail

TARGET_URL="https://egov.uscis.gov/processing-times/"

if [ -n "${STEALTH:-}" ]; then
  JSON_COOKIES="${TMPDIR:-/tmp}/uscis_cookies.json"
  COOKIE_URL="${STEALTH_ENDPOINT}${TARGET_URL}"
  curl --fail-with-body -s -S "${COOKIE_URL}" > "$JSON_COOKIES"
  COOKIE_JAR="uscis.cookies"
  python3 convert_cookies.py "$JSON_COOKIES" > "$COOKIE_JAR"
else
  ./curl_request.sh "$TARGET_URL"
fi
