#!/bin/bash
set -euxo pipefail

form=$1
json_file="response-form-offices_$form.json"

./download_form_offices.sh "$form" > "$json_file"

# Fill out any offices we haven't seen yet in the offices table
printf "$(cat populate-offices-table-template.sql)" "$json_file" | sqlite3 uscis.db

# Fill out the offices column on this form
printf "$(cat populate-form-offices-template.sql)" "$json_file" | sqlite3 uscis.db