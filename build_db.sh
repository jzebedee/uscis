#!/bin/bash
set -euxo pipefail

# 
./populate_forms.sh

# formS
./populate_forms_offices.sh

# 
./populate_processing_times.sh

# must be last for selftest checksums
./populate_metadata.sh

mv uscis.db "$(date +"%F").db"