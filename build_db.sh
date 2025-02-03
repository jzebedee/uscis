#!/bin/bash
set -euxo pipefail

# install dependencies
./install_deps.sh

# install homebrew dependencies
./install_brew_deps.sh
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile

# Check for required commands
command -v sqldiff >/dev/null 2>&1 || { echo >&2 "sqldiff command not found. Aborting."; exit 1; }
command -v sqlite3 >/dev/null 2>&1 || { echo >&2 "sqlite3 command not found. Aborting."; exit 1; }

# install curl-impersonate
curl -sL https://github.com/lwthiker/curl-impersonate/releases/download/v0.6.1/curl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz | sudo tar -xz -C /usr/bin
curl -sL https://github.com/lexiforest/curl-impersonate/releases/download/v0.9.1/curl-impersonate-v0.9.1.x86_64-linux-gnu.tar.gz | sudo tar -xz -C /usr/bin
curl -sL "$CURLSCRIPT_URL" | sudo tar -xz -C /usr/bin

# populate CF cookies
./populate_cookies.sh

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