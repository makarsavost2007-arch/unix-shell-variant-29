#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
log=$(mktemp)
trap 'rm -f "$log"' EXIT
./run.sh --config examples/config.yml --vfs examples/minimal.xml --script examples/basic.txt --log "$log"
cat "$log"
