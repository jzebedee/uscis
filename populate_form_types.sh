#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < create-form-types-table.sql

./download_form_types.sh

for json_file in response-form-types_*.json;
do
  form=$(echo $json_file | sed 's/.*_\(.*\)\.json/\1/')

	printf "$(cat populate-form-types-template.sql)" "$json_file" "$form" | sqlite3 uscis.db
done