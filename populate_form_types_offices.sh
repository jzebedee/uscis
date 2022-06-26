#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < create-offices-table.sql

./download_form_types_offices.sh

for json_file in response-form-offices_*.json;
do
  form_chunk=$(echo $json_file | sed 's/.*_\(.*\)_\(.*\)\.json/\1|\2/')
  form_name=$(echo $form_chunk | cut -d '|' -f 1)
  form_key=$(echo $form_chunk | cut -d '|' -f 2)

	# Fill out any offices we haven't seen yet in the offices table
  printf "$(cat populate-offices-table-template.sql)" "$json_file" | sqlite3 uscis.db

  # Fill out the offices column on this form
  printf "$(cat populate-form-types-offices-template.sql)" "$json_file" | sqlite3 uscis.db
done