#!/bin/bash
set -euxo pipefail

# TODO: insert commit id / gh_run_id / etc

sqlite3 uscis.db '.selftest --init'