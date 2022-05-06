#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < create-offices-table.sql

sqlite3 uscis.db "SELECT form_name, form_key FROM form_types" | while IFS='|' read -a results; do
  form_name="${results[0]}"
  form_key="${results[1]}"
  
  ./populate_form_type_offices.sh "$form_name" "$form_key"
done