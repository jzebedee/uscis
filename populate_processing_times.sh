#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < create-processing-time-table.sql

./download_processing_times.sh

for f in response-processing-time_*.json;
do
	printf "$(cat populate-processing-time-template.sql)" "$f" | sqlite3 uscis.db
done
