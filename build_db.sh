#!/usr/bin/env bash
set -euxo pipefail

# install dependencies
./install_deps.sh

# install zerobrew
curl -fsSL https://zerobrew.rs/install | bash
zb install sqldiff sqlite # -> bugged in zb
# pick up zb bin folder
export PATH="$HOME/.zerobrew/bin:$HOME/.local/share/zerobrew/prefix/bin:$PATH"

# Check for required commands
command -v sqldiff > /dev/null
command -v sqlite3 > /dev/null

# install curl-impersonate
./install_curl.sh

# populate CF cookies (EGOV)
./populate_cookies.sh "https://egov.uscis.gov/processing-times/"

# forms
./populate_forms.sh

# formtypes
./populate_form_types.sh

# formoffices
./populate_form_types_offices.sh

# processing times
./populate_processing_times.sh

# populate CF cookies (FIRST)
./populate_cookies.sh "https://first.uscis.gov/"

# FOIA
./populate_foia_processing_times.sh

# must be last for selftest checksums
./populate_metadata.sh

# rename to current date
mv uscis.db "$(date +"%F").db"

# generate raw sqldiff
sqldiff prev/*.db *.db > sqldiff.txt

# generate changelog
sqldiff=$(<sqldiff.txt)
max_diff_length=124000
if [ $(wc -c <<< $sqldiff) -gt $max_diff_length ]
then
    printf -v sqldiff '%.*s...\n\nTruncated for length' $max_diff_length "$(<sqldiff.txt)"
fi

printf "$(<changelog-template.txt)" "$(basename prev/*.db .db)" "$(basename *.db .db)" "$sqldiff" > changelog.txt