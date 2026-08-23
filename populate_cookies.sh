#!/bin/bash
set -euxo pipefail

TARGET_URL="${1:?usage: populate_cookies.sh TARGET_URL}"
COOKIE_JAR="uscis.cookies"
UA_FILE="${STEALTH_UA_FILE:-uscis.user-agent}"

if [ -n "${STEALTH:-}" ]; then
  JSON_COOKIES="$(mktemp)"
  cleanup() {
    rm -f "$JSON_COOKIES"
  }
  trap cleanup EXIT
  : "${STEALTH_ENDPOINT:?STEALTH_ENDPOINT is required when STEALTH is enabled}"

  ENCODED_TARGET_URL="$(python3 ./encode_url.py "$TARGET_URL")"
  case "$STEALTH_ENDPOINT" in
    *\?url=*)
      COOKIE_URL="${STEALTH_ENDPOINT}${ENCODED_TARGET_URL}"
      ;;
    *\?*)
      COOKIE_URL="${STEALTH_ENDPOINT}&url=${ENCODED_TARGET_URL}"
      ;;
    */cookies|*/cookies/)
      COOKIE_URL="${STEALTH_ENDPOINT%/}?url=${ENCODED_TARGET_URL}"
      ;;
    *)
      COOKIE_URL="${STEALTH_ENDPOINT%/}/cookies?url=${ENCODED_TARGET_URL}"
      ;;
  esac

  CURL_CHROME_SKIP_UA=1 ./curl_request.sh "$COOKIE_URL" > "$JSON_COOKIES"
  python3 convert_cookies.py "$JSON_COOKIES" "$TARGET_URL" > "$COOKIE_JAR"
  python3 ./extract_stealth_user_agent.py "$JSON_COOKIES" "$UA_FILE"
else
  rm -f "$UA_FILE"
  ./curl_request.sh "$TARGET_URL"
fi
