#!/bin/bash
set -euxo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_API="https://api.github.com/repos/lexiforest/curl-impersonate/releases/latest"

case "$(uname -m)" in
    x86_64)
        ASSET_PLATFORM="x86_64-linux-gnu"
        ;;
    aarch64|arm64)
        ASSET_PLATFORM="aarch64-linux-gnu"
        ;;
    *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

command -v python3 >/dev/null

RELEASE_JSON="$(mktemp)"
CURL_OUT="$(mktemp)"
EXTRACT_DIR="$(mktemp -d)"
cleanup() {
    rm -f "$RELEASE_JSON" "$CURL_OUT"
    rm -rf "$EXTRACT_DIR"
}
trap cleanup EXIT

curl --fail --silent --show-error --location \
    --output "$RELEASE_JSON" "$RELEASE_API"

IFS=$'\t' read -r CURL_VERSION CURL_URL CURL_DIGEST < <(
    python3 "$SCRIPT_DIR/select_curl_release.py" "$RELEASE_JSON" "$ASSET_PLATFORM"
)

curl --fail --silent --show-error --location \
    --output "$CURL_OUT" "$CURL_URL"
echo "$CURL_DIGEST  $CURL_OUT" | sha256sum --check --status -

tar --extract --gzip --file "$CURL_OUT" --directory "$EXTRACT_DIR"
sudo install -m 0755 "$EXTRACT_DIR/curl-impersonate" /usr/bin/curl-impersonate
for wrapper in "$EXTRACT_DIR"/curl_chrome[0-9]*; do
    sudo install -m 0755 "$wrapper" /usr/bin/
done
sudo install -m 0755 "$SCRIPT_DIR/curl_chrome_uscis" /usr/bin/curl_chrome_uscis

echo "Installed curl-impersonate ${CURL_VERSION} (${ASSET_PLATFORM})"
