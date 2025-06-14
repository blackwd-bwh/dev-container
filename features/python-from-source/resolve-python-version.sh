#!/bin/bash

INPUT_VERSION="${1:-3.12}"  # Pass as argument or default to 3.12.

echo "🔍 Looking up latest patch version for: $INPUT_VERSION"

RESOLVED=$(curl -fsSL https://www.python.org/ftp/python/ \
  | grep -Eo "${INPUT_VERSION//./\\.}\\.[0-9]+/" \
  | sed 's|/||' \
  | sort -V \
  | tail -n 1)

if [[ -z "$RESOLVED" ]]; then
  echo "❌ Failed to resolve a full patch version for: $INPUT_VERSION"
  exit 1
fi

echo "✅ Resolved: $RESOLVED"

