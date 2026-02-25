#!/usr/bin/env bash
set -euo pipefail

# Lists all Human++ markers: !! ?? >>
# Always exits 0 (informational).

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required" >&2
  exit 2
fi

project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
files=("$@")
if [[ ${#files[@]} -eq 0 ]]; then
  files=("$project_root/research.md" "$project_root/plan.md")
fi

pattern='(^|[^A-Za-z0-9_])(!!|\?\?|>>)([^A-Za-z0-9_]|$)'
for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue
  rg -n --no-heading "$pattern" "$f" || true
done
