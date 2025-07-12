#!/bin/bash
set -euxo pipefail

if ! [ -x "$(command -v curl-impersonate)" ]; then
    CURL_URL="https://github.com/lexiforest/curl-impersonate/releases/download/v1.1.1/curl-impersonate-v1.1.1.x86_64-linux-gnu.tar.gz"
    CURL_SHA="e5e128c94f9a6423814985ba483bd2fb3ac2c1558441004f672f7db1f1ba15e5"
    CURL_OUT="$(mktemp)"

    curl -sL -o "$CURL_OUT" "$CURL_URL"
    echo "$CURL_SHA  $CURL_OUT" | sha256sum -c
    sudo tar -xz -C /usr/bin -f "$CURL_OUT"
    rm "$CURL_OUT"
fi

sudo cp curl_chrome132 /usr/bin/
sudo cp curl_chrome136 /usr/bin/
sudo cp curl_chrome138 /usr/bin/
