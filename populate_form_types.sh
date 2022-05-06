#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < create-form-types-table.sql

sqlite3 uscis.db "SELECT name FROM forms" | while read form; do
  json_file="response-form-types_$form.json"
  ./download_form_types.sh "$form" > "$json_file"

  printf "$(cat populate-form-types-template.sql)" "$json_file" "$form" | sqlite3 uscis.db
done