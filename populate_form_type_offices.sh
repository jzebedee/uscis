#!/bin/bash
set -euxo pipefail

form=$1
type=$2

json_file="response-form-offices_${form}_${type}.json"

./download_form_offices.sh "$form" "$type" > "$json_file"

# Fill out any offices we haven't seen yet in the offices table
printf "$(cat populate-offices-table-template.sql)" "$json_file" | sqlite3 uscis.db

# Fill out the offices column on this form
printf "$(cat populate-form-types-offices-template.sql)" "$json_file" | sqlite3 uscis.db