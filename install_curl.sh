#!/bin/bash
set -euxo pipefail

if ! [ -x "$(command -v curl-impersonate)" ]; then
    CURL_URL="https://github.com/lexiforest/curl-impersonate/releases/download/v1.2.2/curl-impersonate-v1.2.2.x86_64-linux-gnu.tar.gz"
    CURL_SHA="c36b53a95c82211bf00b193c10f4a5da7abcaf5f6319e13ba689cb3416a40d5c"
    CURL_OUT="$(mktemp)"

    curl -sL -o "$CURL_OUT" "$CURL_URL"
    echo "$CURL_SHA  $CURL_OUT" | sha256sum -c
    sudo tar -xz -C /usr/bin -f "$CURL_OUT"
    rm "$CURL_OUT"
fi

sudo cp curl_chrome132 /usr/bin/
