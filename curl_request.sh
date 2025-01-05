#!/bin/bash
set -euxo pipefail

PARAMS="$@"

curl_chrome116 ${PARAMS} --compressed \
  --cookie-jar uscis.cookies \
