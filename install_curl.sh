#!/bin/bash
set -euxo pipefail

if ! [ -x "$(command -v curl-impersonate)" ]; then
    CURL_URL="https://github.com/lexiforest/curl-impersonate/releases/download/v1.2.0/curl-impersonate-v1.2.0.x86_64-linux-gnu.tar.gz"
    CURL_SHA="d5c0b31b14a93e3a41d83bc881c3ed0710a41e7742ab7c19051536547404f2c5"
    CURL_OUT="$(mktemp)"

    curl -sL -o "$CURL_OUT" "$CURL_URL"
    echo "$CURL_SHA  $CURL_OUT" | sha256sum -c
    sudo tar -xz -C /usr/bin -f "$CURL_OUT"
    rm "$CURL_OUT"
fi

sudo cp curl_chrome138 /usr/bin/
