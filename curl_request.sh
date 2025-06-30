#!/bin/bash
set -euxo pipefail

PARAMS="$@"
DEFAULTS=" --fail-with-body -s -S"
COOKIE_JAR="uscis.cookies"
COOKIE_DEFAULTS=" -b ${COOKIE_JAR} --cookie-jar ${COOKIE_JAR}"

curl_chrome138 ${PARAMS} ${DEFAULTS} \
  ${COOKIE_DEFAULTS}
