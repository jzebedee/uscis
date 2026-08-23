#!/bin/bash
set -euxo pipefail

TARGET_URL="${1:?usage: populate_cookies.sh TARGET_URL}"
COOKIE_JAR="uscis.cookies"
UA_FILE="${STEALTH_UA_FILE:-uscis.user-agent}"

if [ -n "${STEALTH:-}" ]; then
  JSON_COOKIES="$(mktemp)"
  trap 'rm -f "$JSON_COOKIES"' EXIT
  : "${STEALTH_ENDPOINT:?STEALTH_ENDPOINT is required when STEALTH is enabled}"

  ENCODED_TARGET_URL="$(python3 -c 'from urllib.parse import quote; import sys; print(quote(sys.argv[1], safe=""))' "$TARGET_URL")"
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
  python3 - "$JSON_COOKIES" "$UA_FILE" <<'PY'
import json
import sys
from pathlib import Path

response_path, ua_path = sys.argv[1:]
with open(response_path, encoding="utf-8") as file:
    response = json.load(file)

user_agent = response.get("user_agent", "") if isinstance(response, dict) else ""
ua_file = Path(ua_path)
if user_agent:
    ua_file.write_text(f"{user_agent}\n", encoding="utf-8")
else:
    ua_file.unlink(missing_ok=True)
PY
else
  rm -f "$UA_FILE"
  ./curl_request.sh "$TARGET_URL"
fi
