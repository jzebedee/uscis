#!/bin/bash
set -euxo pipefail

if ! [ -x "$(command -v curl-impersonate)" ]; then
    CURL_URL="https://github.com/lexiforest/curl-impersonate/releases/download/v1.1.0/curl-impersonate-v1.1.0.x86_64-linux-gnu.tar.gz"
    CURL_SHA="69dc4835aea5241e85742e465f2ea70c27e4db02675ccd6f8ae5a63a919bc098"
    CURL_OUT="$(mktemp)"

    curl -sL -o "$CURL_OUT" "$CURL_URL"
    echo "$CURL_SHA  $CURL_OUT" | sha256sum -c
    sudo tar -xz -C /usr/bin -f "$CURL_OUT"
    rm "$CURL_OUT"
fi

sudo cp curl_chrome132 /usr/bin/
sudo cp curl_chrome138 /usr/bin/
