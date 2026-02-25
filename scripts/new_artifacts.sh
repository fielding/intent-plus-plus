#!/usr/bin/env bash
set -euo pipefail

what="${1:-}"
if [[ "$what" != "research" && "$what" != "plan" ]]; then
  echo "usage: $0 research|plan" >&2
  exit 2
fi

# Project root = where artifacts live
project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Skill root = where templates live
# Priority: INTENT_PP_ROOT > CLAUDE_PLUGIN_ROOT > self-locate via BASH_SOURCE
skill_root="${INTENT_PP_ROOT:-${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}}"
templates="$skill_root/templates"

if [[ "$what" == "research" ]]; then
  target="$project_root/research.md"
  src="$templates/research.template.md"
else
  target="$project_root/plan.md"
  src="$templates/plan.template.md"
fi

if [[ -f "$target" ]]; then
  echo "exists: $target"
  exit 0
fi

if [[ ! -f "$src" ]]; then
  echo "error: template not found: $src" >&2
  exit 2
fi

cp "$src" "$target"
echo "created: $target"
