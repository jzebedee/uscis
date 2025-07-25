#!/bin/bash
set -euxo pipefail

if ! [ -x "$(command -v curl-impersonate)" ]; then
    CURL_URL="https://github.com/lexiforest/curl-impersonate/releases/download/v1.1.2/curl-impersonate-v1.1.2.x86_64-linux-gnu.tar.gz"
    CURL_SHA="439af5886be5033001f1fa38fe5f08409afe160d455b1892dd2f2cc29d018e00"
    CURL_OUT="$(mktemp)"

    curl -sL -o "$CURL_OUT" "$CURL_URL"
    echo "$CURL_SHA  $CURL_OUT" | sha256sum -c
    sudo tar -xz -C /usr/bin -f "$CURL_OUT"
    rm "$CURL_OUT"
fi

sudo cp curl_chrome138 /usr/bin/
