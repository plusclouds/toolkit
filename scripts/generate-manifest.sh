#!/usr/bin/env bash
# Generates manifest.json (sha256 + size per file, for human/PHP consumption) and
# checksums.sha256 (plain `sha256sum -c`-compatible format, for consumers that only
# have coreutils available - e.g. the ISO-repo host self-provisioning its toolkit
# cache with no jq/python3 dependency).
# Run before cutting a release; both files ship as release assets.
set -euo pipefail

cd "$(dirname "$0")/.."

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "{" > "$tmp"
echo "  \"generated_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> "$tmp"
echo "  \"files\": {" >> "$tmp"

first=1
> checksums.sha256
while IFS= read -r -d '' f; do
  rel="${f#./}"
  sha="$(sha256sum "$f" | cut -d' ' -f1)"
  size="$(stat -c%s "$f")"
  [ "$first" -eq 1 ] || echo "," >> "$tmp"
  first=0
  printf '    "%s": {"sha256": "%s", "size": %s}' "$rel" "$sha" "$size" >> "$tmp"
  echo "${sha}  ${rel}" >> checksums.sha256
done < <(find capabilities agents -type f -print0 | sort -z)

echo "" >> "$tmp"
echo "  }" >> "$tmp"
echo "}" >> "$tmp"

mv "$tmp" manifest.json
echo "wrote manifest.json and checksums.sha256 ($(grep -c sha256 manifest.json) files)"
