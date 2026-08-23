#!/usr/bin/env python3
"""Serialize command-line arguments as a JSON array."""

from __future__ import annotations

import json
import sys


def main() -> None:
    print(json.dumps(sys.argv[1:], ensure_ascii=False))


if __name__ == "__main__":
    main()
