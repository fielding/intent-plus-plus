#!/usr/bin/env bash
set -euo pipefail

# Lists only "open" notes: !! and ?? (blockers + questions)
# Exit code:
#   0 = no open notes
#   1 = open notes exist
#   2 = usage / missing dependencies

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required" >&2
  exit 2
fi

project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
files=("$@")
if [[ ${#files[@]} -eq 0 ]]; then
  files=("$project_root/research.md" "$project_root/plan.md")
fi

pattern='(^|[^A-Za-z0-9_])(!!|\?\?)([^A-Za-z0-9_]|$)'

found=0
for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue
  if rg -n --no-heading "$pattern" "$f"; then
    found=1
  fi
done

if [[ $found -eq 1 ]]; then
  exit 1
fi
exit 0
