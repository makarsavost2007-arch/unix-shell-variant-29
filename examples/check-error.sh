#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
log=$(mktemp)
trap 'rm -f "$log"' EXIT
for image in minimal files deep; do
  if ./run.sh --config examples/config.yml --vfs "examples/$image.xml" --script examples/error.txt --log "$log"; then
    exit 1
  fi
  if grep -q UNREACHED "$log"; then exit 1; fi
done
