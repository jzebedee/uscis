#!/bin/bash
set -euxo pipefail

test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
brew update && brew install sqlite3

# make sure I'm not going insane
sqlite3 --version
which sqlite3