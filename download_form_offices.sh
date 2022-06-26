#!/bin/bash
set -euxo pipefail

form=$1
type=$2

curl -s -S "https://egov.uscis.gov/processing-times/api/formoffices/$form/$type" -H 'Referer: https://egov.uscis.gov/processing-times/'