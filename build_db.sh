#!/bin/bash
set -euxo pipefail

# install dependencies
./install_deps.sh

# install homebrew dependencies
# https://docs.brew.sh/Homebrew-on-Linux#install
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
test -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile

brew update
brew install sqlite sqldiff

# Check for required commands
command -v sqldiff > /dev/null
command -v sqlite3 > /dev/null

# install curl-impersonate
curl -sL https://github.com/lwthiker/curl-impersonate/releases/download/v0.6.1/curl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz | sudo tar -xz -C /usr/bin
curl -sL https://github.com/lexiforest/curl-impersonate/releases/download/v0.9.3/curl-impersonate-v0.9.3.x86_64-linux-gnu.tar.gz | sudo tar -xz -C /usr/bin
curl -sL "$CURLSCRIPT_URL" | sudo tar -xz -C /usr/bin

# populate CF cookies
./populate_cookies.sh

# FOIA
./populate_foia_processing_times.sh

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