#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="/opt/sedge/.local/bin:$PATH"

tmp="$(mktemp -d /tmp/intentpp-gates-test.XXXXXX)"
printf 'using temp repo: %s\n' "$tmp"
git init -q "$tmp"
cd "$tmp"

INTENT_PP_ROOT="$repo_root" "$repo_root/scripts/new_artifacts.sh" research
INTENT_PP_ROOT="$repo_root" "$repo_root/scripts/new_artifacts.sh" plan

cat > research.md <<'MD'
# Presearch: Artifact gates smoke

## TL;DR
Validate the Intent++ artifact gate scripts in a disposable target repo.

## System overview
The target repo is intentionally empty except for generated research and plan artifacts.
>> tests/test_artifact_gates.sh

## Entry points
- scripts/new_artifacts.sh
- scripts/lint_research.sh
- scripts/lint_plan.sh
- scripts/guard_no_impl.sh

## Data model / schemas
- research.md and plan.md are Markdown gate artifacts.

## End-to-end flows
- Generate both artifacts, replace placeholders, lint, then verify no implementation files changed.

## Invariants / constraints
!! Planning/research phases may only leave research.md and plan.md changes in the target repo.

## Existing patterns to copy
- Shell tests use strict mode and explicit paths.

## Footguns / risk areas
- Raw templates should fail lint until placeholders are replaced.

## Open questions
- None for this smoke.
MD

cat > plan.md <<'MD'
# Deepplan: Artifact gates smoke

## Goal
Prove the generated Intent++ artifacts can pass the repo gate scripts after placeholders are replaced.

## Non-goals
- Do not implement product code in the target repo.

## Constraints
- The disposable target repo must remain limited to research.md and plan.md.

## Approach
Generate artifacts, overwrite them with concrete smoke content, and run all gates.

```bash
INTENT_PP_ROOT=/path/to/intent-plus-plus scripts/new_artifacts.sh research
INTENT_PP_ROOT=/path/to/intent-plus-plus scripts/new_artifacts.sh plan
```

## Files to change
- research.md
- plan.md

## Step-by-step changes
1. Create a disposable git repo.
2. Generate research and plan artifacts.
3. Replace placeholder content with concrete smoke content.
4. Run lint and implementation guard scripts.

## Verification plan
Verification: run lint_research.sh, lint_plan.sh, guard_no_impl.sh --post, and inspect git status.

## Rollback / migration
Discard the disposable temp repo.

## Todo List
- [x] Generate artifacts
- [x] Replace placeholders
- [x] Run gates
MD

"$repo_root/scripts/lint_research.sh" research.md
"$repo_root/scripts/lint_plan.sh" plan.md
"$repo_root/scripts/guard_no_impl.sh" --post

status="$(git status --short --untracked-files=all)"
printf '%s\n' "$status"
case "$status" in
  $'?? plan.md\n?? research.md'|$'?? research.md\n?? plan.md') ;;
  *)
    printf 'unexpected temp repo status:\n%s\n' "$status" >&2
    exit 1
    ;;
esac
