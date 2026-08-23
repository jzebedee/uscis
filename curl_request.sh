#!/bin/bash
set -euxo pipefail

COOKIE_JAR="uscis.cookies"

curl_chrome_uscis "$@" \
  --fail-with-body -s -S \
  -b "$COOKIE_JAR" --cookie-jar "$COOKIE_JAR"
