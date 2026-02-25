---
name: presearch
description: >
  Deep codebase research phase. Creates and iterates research.md as a
  review surface until it is accurate and grounded in the actual codebase.
  Use when the user says /presearch, "research this", "understand the code",
  "investigate the system", or needs to start a new task with proper research.
  Uses Human++ annotation markers (!! blocker, ?? question, >> reference).
metadata:
  author: fielding
  version: "0.1.0"
license: MIT
compatibility: bash, git, ripgrep (rg)
disable-model-invocation: true
---

# /presearch

Purpose:
Create or iterate `research.md` as a *review surface* until it is accurate and grounded in the actual codebase.

Outputs:
- `research.md` (the artifact the human reviews and annotates)

Human++ annotation contract (in research.md):
- `!!` = blocker / incorrect understanding / must-fix
- `??` = unresolved uncertainty / decision needed / investigation gap
- `>>` = evidence reference (file paths, line ranges, docs, links)

Hard rules:
1) DO NOT implement. Do not modify source code.
2) Only modify: `research.md`, optionally `.ai/**`.
3) Every major claim must be supported by at least one `>>` evidence pointer.
4) If you are not sure, write `??` and continue investigating until resolved.
5) You may iterate research multiple times. If research.md exists, treat this run as an iteration pass.

When to stop:
- If `research.md` has no remaining `!!` or `??` markers AND the human has marked it `Status: ACCEPTED`.
- Otherwise, end by setting `Status: IN_REVIEW` and handing off to the human for annotations.

Script root resolution:
- Claude Code plugin: `${CLAUDE_PLUGIN_ROOT}` is set automatically.
- Other agents: set `INTENT_PP_ROOT` to the intent-plus-plus install directory.
- Fallback: scripts self-locate via `BASH_SOURCE`.
- In all commands below, `$SKILL_ROOT` means `${INTENT_PP_ROOT:-${CLAUDE_PLUGIN_ROOT}}`.

Procedure:

## 0) Dependency check
- Run:
  ```
  bash ${INTENT_PP_ROOT:-${CLAUDE_PLUGIN_ROOT}}/scripts/check_deps.sh
  ```

## 1) Safety checks (no implementation)
- Run:
  ```
  bash ${INTENT_PP_ROOT:-${CLAUDE_PLUGIN_ROOT}}/scripts/guard_no_impl.sh --pre
  ```
- If the repo is dirty with code changes outside allowed files, stop and report.

## 2) Initialize the artifact if missing
- If `research.md` does not exist:
  - Run:
    ```
    bash ${INTENT_PP_ROOT:-${CLAUDE_PLUGIN_ROOT}}/scripts/new_artifacts.sh research
    ```
  - This creates `research.md` from the template.

## 3) Deep research: fully grok the system (do not skim)
Your goal is to understand the *existing system* well enough that the plan will not break surrounding behavior.

You MUST do all of the following (as applicable):

### 3.1 Identify entry points
Find the actual starting points relevant to the task:
- HTTP routes / controllers / handlers
- CLI commands
- job/queue processors
- cron tasks
- event handlers
- UI components (if frontend)

Write them down in `research.md` with `>>` pointers.

### 3.2 Trace data flow end-to-end
For each entry point, trace:
- inputs (request schema, args, UI props)
- validation
- main business logic
- persistence (DB/cache)
- side effects (queues, events, emails, logs)
- outputs (response shape, UI state)

This must be documented as a flow, not just a list of files.

### 3.3 Extract invariants and constraints
Write the invariants as `!!` lines:
- response shape compatibility
- auth boundaries
- ordering guarantees
- idempotency expectations
- performance/caching expectations

### 3.4 Find existing patterns to copy
Search for existing code that already solves similar problems.
Add these as `>>` references and explain:
- what to copy
- what to avoid

### 3.5 Replace uncertainty with evidence
Any time you catch yourself guessing:
- write `??` and immediately go find the answer in code
- convert the `??` into a supported statement with `>>` evidence

## 4) Write/update research.md
Fill the template with:
- concise TL;DR
- system overview
- flows
- invariants (as `!!`)
- open questions (as `??` *only if truly unresolved*)
- evidence map (`>> path:line-line`)

## 5) Self-check (quality gates)
Run:
```
bash ${INTENT_PP_ROOT:-${CLAUDE_PLUGIN_ROOT}}/scripts/lint_research.sh
```

If it fails, fix research.md and rerun until it passes.

## 6) Hand-off to human
- Set `Status: IN_REVIEW`
- Provide a short handoff message:
  - what you read / where you looked
  - what you believe the system does
  - any remaining `??` (should ideally be none)

## 7) Iteration mode (if research.md already existed)
If `research.md` already exists:
- Treat all `!!` and `??` markers as tasks:
  - fix misunderstandings (`!!`)
  - resolve questions (`??`) by additional code reading
- Do not delete markers without addressing them; if you disagree, explain inline and ask the human.
- Re-run lint and handoff again.
