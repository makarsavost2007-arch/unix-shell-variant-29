#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
log=$(mktemp)
trap 'rm -f "$log"' EXIT
for image in minimal files deep; do
  ./run.sh --config examples/config.yml --vfs "examples/$image.xml" --script examples/basic.txt --log "$log"
  cat "$log"
done
