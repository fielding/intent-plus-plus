#!/usr/bin/env bash
set -euo pipefail

project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
f="${1:-$project_root/plan.md}"

if [[ ! -f "$f" ]]; then
  echo "error: missing $f" >&2
  exit 2
fi

fail=0

need_headers=(
  "^## Goal"
  "^## Non-goals"
  "^## Constraints"
  "^## Approach"
  "^## Files to change"
  "^## Step-by-step changes"
  "^## Verification plan"
  "^## Rollback / migration"
  "^## Todo List"
)

for h in "${need_headers[@]}"; do
  if ! rg -q "$h" "$f"; then
    echo "missing section header matching: $h" >&2
    fail=1
  fi
done

# Require at least one code-ish block (snippet/pseudodiff).
if ! rg -q '```' "$f"; then
  echo "plan.md should include code snippets / pseudodiffs (\`\`\` blocks)" >&2
  fail=1
fi

# Require at least one verification command.
if ! rg -q 'Verify:|Verification:' "$f"; then
  echo "plan.md must include verification steps (Verify:/Verification:)" >&2
  fail=1
fi

# Require a non-empty file list (rough check).
if ! rg -q '^-\s+\S+' "$f"; then
  echo "plan.md should list files to change (bullets under Files to change)" >&2
  fail=1
fi

# Avoid placeholders.
if rg -q '<short title>|<YYYY-MM-DD>|<what we are trying to achieve' "$f"; then
  echo "plan.md still contains template placeholders (<...>)" >&2
  fail=1
fi

exit $fail
