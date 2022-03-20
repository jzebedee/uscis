#!/bin/bash
set -euxo pipefail

form=$1

curl "https://egov.uscis.gov/processing-times/api/formoffices/$form" -H 'Referer: https://egov.uscis.gov/processing-times/'