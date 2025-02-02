import json
import sys

# Read JSON data from file passed as first argument
with open(sys.argv[1], 'r') as file:
    json_data = file.read()

# Parse JSON
cookies = json.loads(json_data)

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
