#!/usr/bin/env bash
set -euo pipefail

# Prevent accidental implementation during research/planning skills.
# Usage:
#   guard_no_impl.sh --pre
#   guard_no_impl.sh --post
#
# Fails if git diff contains changes outside the allowed set.

phase="${1:---pre}"
if [[ "$phase" != "--pre" && "$phase" != "--post" ]]; then
  echo "usage: $0 --pre|--post" >&2
  exit 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Not a git repo; skip guard.
  exit 0
fi

allowed_regex='^(research\.md|plan\.md|\.ai/|\.agents/|\.claude/)'

changed="$(git diff --name-only --diff-filter=ACMR || true)"

# Empty diff is OK.
if [[ -z "${changed// }" ]]; then
  exit 0
fi

bad=0
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  if ! [[ "$file" =~ $allowed_regex ]]; then
    echo "disallowed change during planning/research: $file" >&2
    bad=1
  fi
done <<< "$changed"

if [[ $bad -eq 1 ]]; then
  echo "" >&2
  echo "Only these files may change in /presearch or /deepplan:" >&2
  echo "  - research.md" >&2
  echo "  - plan.md" >&2
  echo "  - .ai/** (templates/scripts)" >&2
  echo "  - .agents/** or .claude/** (skills)" >&2
  exit 1
fi

exit 0
