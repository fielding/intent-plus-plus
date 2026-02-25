# Intent++ (intent-plus-plus)

Intent++ is an agent skill pack that helps you preserve human intent while pairing with an AI coding agent.

It does this by enforcing an artifact-driven workflow with hard phase gates:

1. **presearch** produces and iterates `research.md`
2. **deepplan** produces and iterates `plan.md`
3. Implementation happens only after the plan is approved by a human

This is designed to reduce "agent drift" by turning intent into constraints, annotations, and explicit checkpoints.

Intent++ follows the [Agent Skills](https://agentskills.io) open standard. The skills work with any agent that supports SKILL.md, and it also ships as a Claude Code plugin for richer integration.

## Human++ annotations

Intent++ uses **Human++** as its annotation syntax for human-agent communication inside artifacts. Human++ is a lightweight, grep-friendly marker convention designed for reviewing AI-generated documents. Every marker is two characters, visually distinct, and trivial to search for with standard tools.

The markers:

| Marker | Meaning | Used for |
|--------|---------|----------|
| `!!` | **Blocker** | Incorrect understanding, must-fix error, constraint that cannot be violated |
| `??` | **Question** | Unresolved uncertainty, decision needed from the human, investigation gap |
| `>>` | **Reference** | Evidence pointer — file paths, line ranges, docs, links that support a claim |

Why Human++ instead of something else:

- **Two-character markers are fast to type and hard to miss.** They stand out visually in a wall of markdown without requiring special tooling, syntax highlighting, or IDE support.
- **They are grep-native.** `rg '!!'` finds every blocker. `rg '\?\?'` finds every open question. No parser needed. Any agent with shell access can scan artifacts programmatically.
- **They create a closed feedback loop.** The human annotates artifacts with `!!` and `??`. The agent treats those markers as work items. The loop continues until all markers are resolved. `>>` markers are evidence that persists and accumulates.
- **They work in any editor, any terminal, any agent.** No plugins, no extensions, no configuration. The annotation syntax is the artifact format itself.

In practice, a review cycle looks like:

1. Agent produces `research.md` with `>>` evidence pointers and `!!` invariants
2. Human reads it, adds `!!` where understanding is wrong, `??` where decisions are needed
3. Agent re-runs presearch, addresses every `!!` and `??`, adds more `>>` evidence
4. Repeat until no open markers remain and the human marks `Status: ACCEPTED`

## What you get

- Two focused skills
  - `presearch`: deep codebase research as a reviewable artifact
  - `deepplan`: implementation planning as a reviewable artifact
- Two artifacts in your project root
  - `research.md`
  - `plan.md`
- Human++ annotation markers for tight feedback loops
- Lightweight CLI scripts (bash + ripgrep) that any agent can run
  - no MCP required

## Inspiration and credit

This plugin is heavily inspired by Boris Tane's (@boristane) workflow writeup, "How I Use Claude Code". I had been using a similar approach for awhile, but Boris did a much better job articulating it than I can. The purpose of this repository is to package that iterative planning loop into reusable skills, scripts, hooks and other tooling in the future.

- https://boristane.com/blog/how-i-use-claude-code

## Requirements

- bash
- git
- ripgrep (`rg`)

## Install

    git clone https://github.com/fielding/intent-plus-plus.git

After cloning, choose the install method that matches your agent. You can install for multiple agents simultaneously.

### Claude Code (plugin mode)

No `install.sh` needed. Claude Code's plugin system auto-discovers skills from the plugin directory.

    cd /path/to/your-project
    claude --plugin-dir /path/to/intent-plus-plus

Skills are available as `/intent-plus-plus:presearch` and `/intent-plus-plus:deepplan`.

To load the plugin automatically, add it to your Claude Code settings. See the [Claude Code plugin docs](https://code.claude.com/docs/en/plugins) for details.

### Claude Code (skill mode, without plugin)

If you prefer standalone skills over the full plugin:

    ./install.sh --agents claude

This symlinks into `~/.claude/skills/`, making `/presearch` and `/deepplan` available globally.

For a single project only:

    ./install.sh --project /path/to/your-project --agents claude

### OpenAI Codex CLI

    ./install.sh --agents codex

Symlinks into `~/.agents/skills/` (global) or use `--project` for project-scoped install.

You can also use the cross-agent convention:

    ./install.sh --agents agents

This installs to `.agents/skills/`, which Codex discovers natively.

### GitHub Copilot

    ./install.sh --agents copilot

Symlinks into `.github/skills/` (project-scoped is typical for Copilot).

    ./install.sh --project /path/to/your-project --agents copilot

### Cursor

    ./install.sh --agents cursor

Symlinks into `~/.cursor/skills/` (global) or use `--project` for project-scoped.

Cursor also reads `.agents/skills/`, so the cross-agent install works too:

    ./install.sh --project . --agents agents

### Gemini CLI

    ./install.sh --agents gemini

Symlinks into `~/.gemini/skills/`. Gemini CLI also reads `.agents/skills/` as an alias.

### Windsurf

    ./install.sh --agents windsurf

Symlinks into `~/.windsurf/skills/`.

### Roo Code

    ./install.sh --agents roo

Symlinks into `~/.roo/skills/`. Roo Code also reads `.agents/skills/`.

### Multiple agents at once

    ./install.sh --agents claude,codex,cursor,copilot,gemini

### All detected agents (auto-detect)

    ./install.sh

With no `--agents` flag, `install.sh` scans for agent config directories that already exist on your system and installs into those. If none are found, it defaults to `claude` and the cross-agent `agents` convention.

### Manual install

Symlink the skill directories into your agent's skill path directly:

    ln -s /path/to/intent-plus-plus/skills/presearch <agent-skills-dir>/presearch
    ln -s /path/to/intent-plus-plus/skills/deepplan <agent-skills-dir>/deepplan

Set `INTENT_PP_ROOT` so the scripts can find templates and other assets:

    export INTENT_PP_ROOT="/path/to/intent-plus-plus"

When using Claude Code in plugin mode, this is handled automatically via `CLAUDE_PLUGIN_ROOT`. For all other install methods, `INTENT_PP_ROOT` is the portable equivalent.

## Workflow

### 1) Presearch

Invoke the presearch skill. The exact invocation depends on your agent:

- Claude Code (plugin): `/intent-plus-plus:presearch <task statement>`
- Claude Code (skill): `/presearch <task statement>`
- Codex: `/presearch <task statement>` or ask the agent to run the presearch skill
- Cursor / Copilot / Gemini / others: invoke `/presearch` or ask the agent to research the task

This creates or iterates `research.md`.

Your job as the human:
- Read `research.md`
- Add `!!` where the agent's understanding is wrong
- Add `??` where you need the agent to investigate further or where a decision is needed
- Add `>>` to point at evidence the agent missed
- Re-run presearch until all markers are resolved and you mark it `Status: ACCEPTED`

### 2) Deep plan

Invoke the deepplan skill:

- Claude Code (plugin): `/intent-plus-plus:deepplan <task statement>`
- Claude Code (skill): `/deepplan <task statement>`
- Codex: `/deepplan <task statement>` or ask the agent to plan the implementation
- Cursor / Copilot / Gemini / others: invoke `/deepplan` or ask the agent to create a plan

This creates or iterates `plan.md`.

Your job as the human:
- Read `plan.md`
- Add `!!` where the plan is wrong, unsafe, or missing detail
- Add `??` where decisions are needed or more research is required
- Add `>>` to reference existing patterns or constraints the agent should follow
- Re-run deepplan until all markers are resolved and you mark it `Status: APPROVED`

### 3) Implement

This skill pack intentionally does not include an "implement" skill.
The goal is to keep research and planning clean and gated, and keep implementation separate.

## Repo layout

    intent-plus-plus/
    ├── .claude-plugin/         Claude Code plugin manifest (optional, additive)
    │   └── plugin.json
    ├── skills/                 Agent Skills standard (SKILL.md per skill)
    │   ├── presearch/
    │   │   └── SKILL.md
    │   └── deepplan/
    │       └── SKILL.md
    ├── templates/              Artifact templates
    │   ├── research.template.md
    │   └── plan.template.md
    ├── scripts/                Guardrails and lint scripts
    │   ├── check_deps.sh
    │   ├── guard_no_impl.sh
    │   ├── lint_research.sh
    │   ├── lint_plan.sh
    │   ├── new_artifacts.sh
    │   ├── notes_open.sh
    │   └── notes_all.sh
    ├── hooks/                  Hook experiments (disabled by default)
    ├── install.sh              Multi-agent installer (post-clone)
    ├── LICENSE
    ├── CHANGELOG.md
    ├── CONTRIBUTING.md
    ├── CODE_OF_CONDUCT.md
    └── SECURITY.md

## License

MIT. See LICENSE.
