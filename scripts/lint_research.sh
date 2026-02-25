#!/usr/bin/env bash
set -euo pipefail

project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
f="${1:-$project_root/research.md}"

if [[ ! -f "$f" ]]; then
  echo "error: missing $f" >&2
  exit 2
fi

fail=0

need_headers=(
  "^## TL;DR"
  "^## System overview"
  "^## Entry points"
  "^## Data model / schemas"
  "^## End-to-end flows"
  "^## Invariants / constraints"
  "^## Existing patterns to copy"
  "^## Footguns / risk areas"
  "^## Open questions"
)

for h in "${need_headers[@]}"; do
  if ! rg -q "$h" "$f"; then
    echo "missing section header matching: $h" >&2
    fail=1
  fi
done

# Require at least some evidence pointers.
if ! rg -q '>>\s*\S+' "$f"; then
  echo "research.md must contain at least one '>>' evidence reference" >&2
  fail=1
fi

# Encourage explicit invariants.
if ! rg -q '!!\s*\S+' "$f"; then
  echo "warning: no '!!' invariants found (recommended)" >&2
fi

# Avoid leaving template placeholders.
if rg -q '<short title>|<YYYY-MM-DD>|<copy the task request here|<what the system does' "$f"; then
  echo "research.md still contains template placeholders (<...>)" >&2
  fail=1
fi

exit $fail
