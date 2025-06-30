#!/bin/bash
set -euxo pipefail

TARGET_URL="$1"

if [ -n "${STEALTH:-}" ]; then
  JSON_COOKIES="$(mktemp)"
  COOKIE_URL="${STEALTH_ENDPOINT}${TARGET_URL}"
  ./curl_request.sh "${COOKIE_URL}" > "$JSON_COOKIES"
  COOKIE_JAR="uscis.cookies"
  python3 convert_cookies.py "$JSON_COOKIES" > "$COOKIE_JAR"
else
  ./curl_request.sh "$TARGET_URL"
fi
