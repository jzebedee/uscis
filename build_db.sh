#!/bin/bash
set -euxo pipefail

# install dependencies
# https://docs.brew.sh/Homebrew-on-Linux#install
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile

brew update && brew install sqlite sqldiff

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