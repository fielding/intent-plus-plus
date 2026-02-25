#!/usr/bin/env bash
set -euo pipefail

# Intent++ multi-agent installer
# Creates symlinks so any supported agent can discover the skills.
#
# Usage:
#   ./install.sh [--global] [--agents agent1,agent2,...] [--project /path/to/project]
#
# Examples:
#   ./install.sh                              # install globally for all detected agents
#   ./install.sh --agents claude,codex        # install globally for specific agents
#   ./install.sh --project /path/to/project   # install into a specific project
#   ./install.sh --project . --agents cursor  # install into current project for Cursor

INTENT_PP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=("presearch" "deepplan")

# Supported agent skill directories
declare -A AGENT_DIRS
AGENT_DIRS=(
  [claude]=".claude/skills"
  [codex]=".agents/skills"
  [copilot]=".github/skills"
  [cursor]=".cursor/skills"
  [gemini]=".gemini/skills"
  [roo]=".roo/skills"
  [windsurf]=".windsurf/skills"
  [opencode]=".opencode/skills"
  [agents]=".agents/skills"      # cross-agent convention
)

# Parse args
scope="global"
project_dir=""
requested_agents=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      scope="global"
      shift
      ;;
    --project)
      scope="project"
      project_dir="${2:-.}"
      shift 2
      ;;
    --agents)
      requested_agents="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [--global] [--agents agent1,agent2,...] [--project /path/to/project]"
      echo ""
      echo "Agents: claude, codex, copilot, cursor, gemini, roo, windsurf, opencode, agents"
      echo ""
      echo "  --global              Install to ~/.<agent>/skills/ (default)"
      echo "  --project <path>      Install to <path>/.<agent>/skills/"
      echo "  --agents <list>       Comma-separated agent list (default: auto-detect)"
      echo ""
      echo "The 'agents' target installs to .agents/skills/ which is the"
      echo "cross-agent convention supported by Codex, Cursor, Gemini CLI, and others."
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      exit 2
      ;;
  esac
done

# Determine base directory
if [[ "$scope" == "global" ]]; then
  base_dir="$HOME"
else
  base_dir="$(cd "$project_dir" && pwd)"
fi

# Determine which agents to install for
agents_to_install=()
if [[ -n "$requested_agents" ]]; then
  IFS=',' read -ra agents_to_install <<< "$requested_agents"
else
  # Auto-detect: install for agents that already have config dirs
  for agent in "${!AGENT_DIRS[@]}"; do
    agent_parent_dir="${AGENT_DIRS[$agent]%%/*}"
    if [[ -d "$base_dir/$agent_parent_dir" ]]; then
      agents_to_install+=("$agent")
    fi
  done

  # If nothing detected, default to the cross-agent convention + claude
  if [[ ${#agents_to_install[@]} -eq 0 ]]; then
    agents_to_install=("agents" "claude")
  fi
fi

# Install
installed=0
for agent in "${agents_to_install[@]}"; do
  agent="${agent// /}"  # trim whitespace
  skill_dir="${AGENT_DIRS[$agent]:-}"
  if [[ -z "$skill_dir" ]]; then
    echo "warning: unknown agent '$agent', skipping" >&2
    continue
  fi

  target_dir="$base_dir/$skill_dir"
  mkdir -p "$target_dir"

  for skill in "${SKILLS[@]}"; do
    src="$INTENT_PP_ROOT/skills/$skill"
    dst="$target_dir/$skill"

    if [[ -L "$dst" ]]; then
      existing="$(readlink "$dst")"
      if [[ "$existing" == "$src" ]]; then
        echo "  ok: $dst -> $src (already linked)"
        continue
      else
        echo "  update: $dst -> $src (was: $existing)"
        rm "$dst"
      fi
    elif [[ -d "$dst" ]]; then
      echo "  skip: $dst (directory exists, not a symlink — remove manually to re-link)" >&2
      continue
    fi

    ln -s "$src" "$dst"
    echo "  link: $dst -> $src"
    installed=$((installed + 1))
  done
done

echo ""
echo "Installed $installed skill symlink(s) from: $INTENT_PP_ROOT"

if [[ "$scope" == "project" ]]; then
  echo ""
  echo "Tip: set INTENT_PP_ROOT in your shell for agents that don't auto-resolve paths:"
  echo "  export INTENT_PP_ROOT=\"$INTENT_PP_ROOT\""
fi
