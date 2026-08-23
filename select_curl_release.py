#!/usr/bin/env python3
"""Select the latest curl-impersonate release asset for a platform."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: select_curl_release.py RELEASE_JSON PLATFORM")

    release_path = Path(sys.argv[1])
    platform = sys.argv[2]
    with release_path.open(encoding="utf-8") as file:
        release = json.load(file)

    asset = next(
        (
            asset
            for asset in release.get("assets", [])
            if asset.get("name", "").startswith("curl-impersonate-")
            and asset.get("name", "").endswith(f".{platform}.tar.gz")
        ),
        None,
    )
    if asset is None:
        raise SystemExit(f"No curl-impersonate asset found for {platform}")

    digest = asset.get("digest", "")
    if not digest.startswith("sha256:"):
        raise SystemExit(f"Latest release asset has no SHA-256 digest: {asset['name']}")

    print("\t".join((release["tag_name"], asset["browser_download_url"], digest[7:])))


if __name__ == "__main__":
    main()
