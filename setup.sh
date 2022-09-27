#!/bin/bash
set -euxo pipefail

test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
# don't fail on warnings about GH hosted runners having unbrewed headers
brew doctor || true

brew update && brew install sqlite3