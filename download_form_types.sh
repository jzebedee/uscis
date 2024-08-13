#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < query-form-types-urls.sql | xargs -t ./curl_request_api.sh 