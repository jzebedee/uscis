#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < create-offices-table.sql

./download_form_types_offices.sh

for json_file in response-form-offices_*.json;
do
  base_name=${json_file##*/}
  stem=${base_name#response-form-offices_}
  form_name=${stem%%_*}
  form_key=${stem#${form_name}_}
  form_key=${form_key%.json}

	# Fill out any offices we haven't seen yet in the offices table
  printf "$(cat populate-offices-table-template.sql)" "$json_file" | sqlite3 uscis.db

  # Fill out the offices column on this form
  printf "$(cat populate-form-types-offices-template.sql)" "$json_file" "$form_name" "$form_key" | sqlite3 uscis.db
done
