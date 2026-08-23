#!/usr/bin/env python3
"""URL-encode one value for use as a query parameter."""

from __future__ import annotations

import sys
from urllib.parse import quote


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: encode_url.py URL")
    print(quote(sys.argv[1], safe=""))


if __name__ == "__main__":
    main()
