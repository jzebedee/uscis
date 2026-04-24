#!/usr/bin/env python3
"""Resolve a Next.js server-action id from the live USCIS page bundle."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import urljoin


BASE_URL = "https://egov.uscis.gov/processing-times"
ACTION_BLOCK_PATTERNS = (
    "Sorry, you have been blocked",
    "Attention Required! | Cloudflare",
)
CHALLENGE_PATTERNS = (
    "Just a moment...",
    "cf-mitigated: challenge",
)


def run_command(cmd: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, capture_output=True, text=True)


def fetch_with_cookie_refresh(url: str) -> str:
    if not Path("uscis.cookies").exists() or Path("uscis.cookies").stat().st_size == 0:
        refresh = run_command(["./populate_cookies.sh", f"{BASE_URL}/"])
        if refresh.returncode != 0:
            raise SystemExit(
                f"failed to initialize cookies for {url}:\nstdout:\n{refresh.stdout}\nstderr:\n{refresh.stderr}"
            )

    for attempt in range(2):
        proc = run_command(["./curl_request.sh", url])

        body = proc.stdout
        if any(pattern in body for pattern in ACTION_BLOCK_PATTERNS):
            raise SystemExit(f"Cloudflare blocked the page while fetching {url}")

        if any(pattern in body for pattern in CHALLENGE_PATTERNS):
            if attempt == 1:
                raise SystemExit(f"Cloudflare challenge persisted while fetching {url}")
            print("Refreshing cookies after Cloudflare challenge...", file=sys.stderr)
            refresh = run_command(["./populate_cookies.sh", f"{BASE_URL}/"])
            if refresh.returncode != 0:
                raise SystemExit(
                    f"failed to refresh cookies for {url}:\nstdout:\n{refresh.stdout}\nstderr:\n{refresh.stderr}"
                )
            continue

        if proc.returncode != 0:
            raise SystemExit(
                f"failed to fetch {url}:\nstdout:\n{proc.stdout}\nstderr:\n{proc.stderr}"
            )

        return body

    raise SystemExit(f"failed to fetch {url}")


def extract_bundle_urls(html: str) -> list[str]:
    matches = re.findall(r'["\'](/processing-times/_next/static/chunks/[^"\']+\.js)["\']', html)
    seen: set[str] = set()
    bundles: list[str] = []
    for match in matches:
        if match not in seen:
            seen.add(match)
            bundles.append(match)
    return bundles


def fetch_bundle(url: str) -> str:
    return fetch_with_cookie_refresh(url)


def find_action_id(bundle_text: str, action_name: str) -> str | None:
    pattern = re.compile(
        rf'createServerReference\)\("([0-9a-f]{{42}})",[^)]*"{re.escape(action_name)}"\)',
        re.DOTALL,
    )
    match = pattern.search(bundle_text)
    if match:
        return match.group(1)
    return None


def resolve_action_id(action_name: str) -> str:
    if re.fullmatch(r"[0-9a-f]{42}", action_name):
        return action_name

    html = fetch_with_cookie_refresh(BASE_URL)
    bundle_urls = extract_bundle_urls(html)
    if not bundle_urls:
        raise SystemExit("could not find any Next.js bundle URLs on the processing-times page")

    for bundle_url in bundle_urls:
        bundle_text = fetch_bundle(urljoin(BASE_URL, bundle_url))
        action_id = find_action_id(bundle_text, action_name)
        if action_id:
            return action_id

    raise SystemExit(f"could not resolve Next.js action id for {action_name}")


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: resolve_next_action_id.py ACTION_NAME", file=sys.stderr)
        return 2

    print(resolve_action_id(sys.argv[1]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
