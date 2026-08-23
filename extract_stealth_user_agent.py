#!/usr/bin/env python3
"""Persist the user agent returned by the stealth cookie endpoint."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: extract_stealth_user_agent.py RESPONSE_JSON UA_FILE")

    response_path, ua_path = sys.argv[1:]
    with open(response_path, encoding="utf-8") as file:
        response = json.load(file)

    user_agent = response.get("user_agent", "") if isinstance(response, dict) else ""
    output_path = Path(ua_path)
    if user_agent:
        output_path.write_text(f"{user_agent}\n", encoding="utf-8")
    else:
        output_path.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
