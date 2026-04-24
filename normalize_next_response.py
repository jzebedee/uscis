#!/usr/bin/env python3
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["njsparser"]
# ///
"""Normalize USCIS responses that now arrive as Next.js HTML shells or server actions.

This helper keeps the existing SQLite parsing path intact by converting
Next.js responses back into the JSON payload shape the SQL templates already
expect. Plain JSON responses are left untouched.
"""

from __future__ import annotations

import json
import re
import sys
from collections import deque
from functools import lru_cache
from pathlib import Path
from typing import Any


import njsparser

from njsparser.parser import types as njs_types


# The USCIS pages currently exercise parts of Next.js flight data that trigger
# a strict assertion in njsparser's optional runtime validation. Disabling the
# validation keeps the parser usable while still relying on the library for the
# actual HTML/flight-data decoding.
njs_types.ENABLE_TYPE_VERIF = False


TARGET_PATHS: dict[str, list[tuple[str, ...]]] = {
    "forms": [("data", "forms"), ("forms",)],
    "form_types": [("data", "form_types"), ("form_types",)],
    "form_offices": [("data", "form_offices"), ("form_offices",)],
    "processing_time": [("data", "processing_time"), ("processing_time",)],
}


def _target_from_name(path: Path) -> str | None:
    name = path.name
    if name.startswith("response-forms."):
        return "forms"
    if name.startswith("response-form-types_"):
        return "form_types"
    if name.startswith("response-form-offices_"):
        return "form_offices"
    if name.startswith("response-processing-time_"):
        return "processing_time"
    return None


def _has_path(node: Any, path: tuple[str, ...]) -> bool:
    current = node
    for key in path:
        if isinstance(current, dict) and key in current:
            current = current[key]
        else:
            return False
    return True


def _find_matching_dict(node: Any, paths: list[tuple[str, ...]]) -> tuple[dict[str, Any], tuple[str, ...]] | None:
    queue: deque[Any] = deque([node])
    while queue:
        current = queue.popleft()
        if isinstance(current, dict):
            for path in paths:
                if _has_path(current, path):
                    return current, path
            queue.extend(current.values())
        elif isinstance(current, list):
            queue.extend(current)
    return None


def _load_json(text: str) -> Any | None:
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return None


def _parse_next_component_stream(text: str) -> dict[int, Any] | None:
    """Parse a text/x-component response into indexed chunks.

    USCIS component responses are compacted onto a mostly single-line stream:
    `0:{...}\n2:T...3:T...1:{...}`. We decode the index prefix, parse `T` text
    records by their byte length, and JSON-decode the remaining records.
    """

    raw = text.encode("utf-8")
    pos = 0
    records: dict[int, Any] = {}
    saw_record = False
    decoder = json.JSONDecoder()

    while pos < len(raw):
        while pos < len(raw) and raw[pos] in b" \t\r\n":
            pos += 1
        if pos >= len(raw):
            break

        match = re.match(rb"(\d+):", raw[pos:])
        if match is None:
            if saw_record:
                raise RuntimeError(
                    "Unexpected content in Next.js component stream near "
                    f"byte {pos}: {raw[pos:pos+80]!r}"
                )
            return None

        saw_record = True
        index = int(match.group(1))
        pos += match.end()

        if pos < len(raw) and raw[pos:pos + 1] == b"T":
            comma = raw.find(b",", pos)
            if comma == -1:
                raise RuntimeError(f"Malformed T record in Next.js component stream at byte {pos}")
            text_length = int(raw[pos + 1:comma], 16)
            start = comma + 1
            end = start + text_length
            if end > len(raw):
                raise RuntimeError(f"Truncated T record in Next.js component stream at byte {pos}")
            records[index] = raw[start:end].decode("utf-8")
            pos = end
            continue

        remainder = raw[pos:].decode("utf-8")
        try:
            value, consumed_chars = decoder.raw_decode(remainder)
        except json.JSONDecodeError as exc:
            raise RuntimeError(
                f"Malformed JSON record in Next.js component stream at byte {pos}"
            ) from exc
        records[index] = value
        pos += len(remainder[:consumed_chars].encode("utf-8"))

    return records if saw_record else None


def _resolve_component_references(records: dict[int, Any]) -> dict[int, Any]:
    ref_pattern = re.compile(r"^\$(\d+)$")

    @lru_cache(maxsize=None)
    def resolve_index(index: int) -> Any:
        if index not in records:
            raise KeyError(f"Component stream referenced missing record ${index}")
        return resolve_value(records[index])

    def resolve_value(value: Any) -> Any:
        if isinstance(value, str):
            match = ref_pattern.fullmatch(value)
            if match is not None:
                return resolve_index(int(match.group(1)))
            return value
        if isinstance(value, list):
            return [resolve_value(item) for item in value]
        if isinstance(value, dict):
            return {key: resolve_value(item) for key, item in value.items()}
        return value

    return {index: resolve_value(value) for index, value in records.items()}


def _load_next_component_payload(text: str) -> Any | None:
    records = _parse_next_component_stream(text)
    if records is None:
        return None
    return _resolve_component_references(records)


def _serializable_root(value: Any) -> Any:
    return json.loads(json.dumps(value, default=njsparser.default))


def _wrap_for_sql(payload: dict[str, Any], path: tuple[str, ...]) -> dict[str, Any]:
    if path and path[0] == "data":
        return payload
    return {"data": payload}


def normalize_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    loaded = _load_json(original)
    if loaded is not None:
        # Keep already-JSON responses untouched so existing behavior is preserved.
        return False

    target = _target_from_name(path)
    if target is None:
        raise ValueError(f"Can't infer a Next.js payload target from {path.name!r}")

    candidate_paths = TARGET_PATHS[target]

    component_payload = _load_next_component_payload(original)
    if isinstance(component_payload, dict):
        record_payload = component_payload.get(1)
        if isinstance(record_payload, dict):
            path.write_text(
                json.dumps(record_payload, ensure_ascii=False, separators=(",", ":")) + "\n",
                encoding="utf-8",
            )
            return True

        match = _find_matching_dict(component_payload, candidate_paths)
        if match is not None:
            payload, path_match = match
            normalized = _wrap_for_sql(payload, path_match)
            path.write_text(json.dumps(normalized, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
            return True

    # Fast path: __NEXT_DATA__ payloads already parse directly.
    next_data = njsparser.get_next_data(original)
    if isinstance(next_data, dict):
        match = _find_matching_dict(next_data, candidate_paths)
        if match is not None:
            payload, path_match = match
            normalized = _wrap_for_sql(payload, path_match)
            path.write_text(json.dumps(normalized, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
            return True

    # Flight data path: parse the Next.js shell, then search for the payload
    # that contains the legacy JSON shape.
    try:
        flight_data = njsparser.BeautifulFD(original)
    except Exception as exc:  # pragma: no cover - depends on upstream payload shape
        raise RuntimeError(f"Failed to parse Next.js flight data in {path.name}") from exc

    for item in flight_data.as_list():
        serializable = _serializable_root(item)
        match = _find_matching_dict(serializable, candidate_paths)
        if match is not None:
            payload, path_match = match
            normalized = _wrap_for_sql(payload, path_match)
            path.write_text(json.dumps(normalized, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
            return True

    raise RuntimeError(
        f"Could not locate a {target} payload in Next.js response {path.name}. "
        "The page may be blocked, a challenge page, or a new payload shape."
    )


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: normalize_next_response.py RESPONSE.json [...]", file=sys.stderr)
        return 2

    changed = 0
    for raw_arg in argv[1:]:
        path = Path(raw_arg)
        if not path.exists():
            raise FileNotFoundError(path)
        if normalize_file(path):
            changed += 1
            print(f"normalized {path}", file=sys.stderr)
    if changed:
        print(f"normalized {changed} file(s)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
