#!/bin/bash
set -euxo pipefail

sqlite3 uscis.db < create-offices-table.sql

sqlite3 uscis.db "SELECT name FROM forms" | while read name; do
  ./populate_form_offices.sh "$name"
done