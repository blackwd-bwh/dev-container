#!/usr/bin/env bash
set -euo pipefail

BASE_VERSION="${1:-}"
if [[ -z "$BASE_VERSION" ]]; then
  echo "Usage: $0 <base_version> (e.g. 3.11)"
  exit 1
fi

echo "Looking up latest patch version for Python $BASE_VERSION..."

echo "Fetching tags from https://github.com/python/cpython..."
TAGS=$(git ls-remote --tags https://github.com/python/cpython | awk '{print $2}' | grep -v '\^{}')
echo "Retrieved tags: $(echo "$TAGS" | wc -l) tags"

REGEX="refs/tags/v?${BASE_VERSION//./\\.}\.[0-9]+$"
echo "Filtering versions matching base $BASE_VERSION"

MATCHING_VERSIONS=$(echo "$TAGS" | grep -E "$REGEX" | sed -E 's|refs/tags/v?||' | sort -V || true)

if [[ -z "$MATCHING_VERSIONS" ]]; then
  echo "No official patch releases found for Python $BASE_VERSION. It may not be released yet."
  exit 1
fi

LATEST_VERSION=$(echo "$MATCHING_VERSIONS" | tail -n1)
echo "Latest version for $BASE_VERSION is: $LATEST_VERSION"
