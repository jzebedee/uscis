import json
import sys
from urllib.parse import urlparse

# Read JSON data from file passed as first argument
with open(sys.argv[1], 'r') as file:
    json_data = file.read()

# Parse JSON
payload = json.loads(json_data)

if isinstance(payload, dict) and isinstance(payload.get("cookies"), dict):
    if len(sys.argv) < 3:
        raise SystemExit("target URL is required for cookie responses without domain metadata")
    target = urlparse(sys.argv[2])
    if not target.hostname:
        raise SystemExit(f"invalid target URL: {sys.argv[2]}")
    cookies = [
        {"domain": target.hostname, "name": name, "value": value}
        for name, value in payload["cookies"].items()
    ]
elif isinstance(payload, list):
    cookies = payload
else:
    raise SystemExit("unsupported stealth cookie response")

# Netscape cookies format header
netscape_cookies = "# Netscape HTTP Cookie File\n"

# Convert cookies to Netscape format
for cookie in cookies:
    domain = cookie['domain']
    name = cookie['name']
    value = cookie['value']
    netscape_cookies += f"{domain}\tTRUE\t/\tFALSE\t0\t{name}\t{value}\n"

# Print the result
print(netscape_cookies)
