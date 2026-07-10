#!/usr/bin/env bash
# Generates manifest.json: sha256 + size for every tracked file under capabilities/ and agents/.
# Run before cutting a release; the resulting manifest.json ships as a release asset
# so consumers can verify integrity before executing anything they download.
set -euo pipefail

cd "$(dirname "$0")/.."

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "{" > "$tmp"
echo "  \"generated_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$tmp"
echo "  \"files\": {" >> "$tmp"

first=1
while IFS= read -r -d '' f; do
  rel="${f#./}"
  sha="$(sha256sum "$f" | cut -d' ' -f1)"
  size="$(stat -c%s "$f")"
  [ "$first" -eq 1 ] || echo "," >> "$tmp"
  first=0
  printf '    "%s": {"sha256": "%s", "size": %s}' "$rel" "$sha" "$size" >> "$tmp"
done < <(find capabilities agents -type f -print0 | sort -z)

echo "" >> "$tmp"
echo "  }" >> "$tmp"
echo "}" >> "$tmp"

mv "$tmp" manifest.json
echo "wrote manifest.json ($(jq '.files | length' manifest.json 2>/dev/null || grep -c sha256 manifest.json) files)"
