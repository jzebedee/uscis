#!/bin/bash
set -euxo pipefail

# forms
./populate_forms.sh

# formtypes
./populate_form_types.sh

# formoffices
./populate_form_types_offices.sh

# processing times
./populate_processing_times.sh

# must be last for selftest checksums
./populate_metadata.sh

# create json response artifact
sqlite3 responses.db -A -c *.json

# rename to current date
mv uscis.db "$(date +"%F").db"