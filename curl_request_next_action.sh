#!/bin/bash
set -euo pipefail

ACTION_ID="${1:?usage: curl_request_next_action.sh ACTION_ID [ARGS...] -o OUTPUT_FILE}"
shift

OUTPUT_FILE=""
ARGS=()
while (($#)); do
  case "$1" in
    -o)
      OUTPUT_FILE="${2:?missing output file after -o}"
      shift 2
      ;;
    --)
      shift
      ARGS+=("$@")
      break
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

if [ -z "$OUTPUT_FILE" ]; then
  echo "missing -o OUTPUT_FILE" >&2
  exit 2
fi

JSON_ARGS="$(python3 - "${ARGS[@]}" <<'PY'
import json
import sys

print(json.dumps(sys.argv[1:], ensure_ascii=False))
PY
)"

REQUEST_URL="https://egov.uscis.gov/processing-times"
REFERER_HEADER="Referer: https://egov.uscis.gov/processing-times"

request_once() {
  local headers_file body_file
  headers_file="$(mktemp)"
  body_file="$(mktemp)"

  set +e
  curl_chrome132 \
    -sS \
    --fail-with-body \
    -D "$headers_file" \
    -o "$body_file" \
    -X POST \
    -H "Origin: https://egov.uscis.gov" \
    -H "$REFERER_HEADER" \
    -H "Next-Action: $ACTION_ID" \
    -H "Content-Type: application/json" \
    -H "Accept: text/x-component" \
    -b uscis.cookies \
    --cookie-jar uscis.cookies \
    --data "$JSON_ARGS" \
    "$REQUEST_URL"
  curl_rc=$?
  set -e

  if grep -qi 'Sorry, you have been blocked' "$body_file" || grep -qi 'Attention Required! | Cloudflare' "$body_file"; then
    echo "Cloudflare blocked the Next.js request for $OUTPUT_FILE" >&2
    echo "Aborting immediately." >&2
    exit 1
  fi

  if grep -qi 'Just a moment...' "$body_file" || grep -qi 'cf-mitigated: challenge' "$headers_file"; then
    rm -f "$headers_file" "$body_file"
    return 1
  fi

  if [ "$curl_rc" -ne 0 ]; then
    echo "Next.js action request failed for $OUTPUT_FILE" >&2
    cat "$body_file" >&2
    exit "$curl_rc"
  fi

  mv "$body_file" "$OUTPUT_FILE"
  rm -f "$headers_file"
}

attempt=1
while true; do
  if request_once; then
    break
  fi

  if [ "$attempt" -ge 2 ]; then
    echo "Cloudflare challenge persisted after cookie refresh for $OUTPUT_FILE" >&2
    exit 1
  fi

  echo "Refreshing cookies after Cloudflare challenge..." >&2
  ./populate_cookies.sh "https://egov.uscis.gov/processing-times/"
  attempt=$((attempt + 1))
done
