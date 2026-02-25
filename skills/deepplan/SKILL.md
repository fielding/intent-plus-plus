---
name: deepplan
description: >
  Implementation planning phase. Creates and iterates plan.md until it is
  implementation-ready and approved by the human. Use after research.md is
  ACCEPTED, or when the user says /deepplan, "plan this", "create a plan",
  "design the implementation", or "write a plan". Uses Human++ markers
  (!! blocker, ?? question, >> reference).
metadata:
  author: fielding
  version: "0.1.0"
license: MIT
compatibility: bash, git, ripgrep (rg)
disable-model-invocation: true
---

# /deepplan

Purpose:
Create or iterate `plan.md` until it is implementation-ready and approved by the human.

Outputs:
- `plan.md` (the artifact the human reviews and annotates)
- A granular Todo List inside plan.md for implementation execution tracking

Human++ annotation contract (in plan.md):
- `!!` = blocker (plan is incorrect, unsafe, missing detail, wrong API, etc.)
- `??` = question/uncertainty (needs answer, decision, or more research)
- `>>` = reference (evidence, existing patterns, links, file pointers)

Hard rules:
1) DO NOT implement. Do not modify source code.
2) Only modify: `plan.md`, optionally `.ai/**`.
3) Plans must be grounded in research.md and existing code patterns.
4) Plans must include concrete file paths and at least one snippet/pseudodiff per step.
5) Verification must be explicit (commands + what "success" means).
6) If plan.md exists, treat this run as an iteration pass driven by `!!/??`.

When to stop:
- When there are no remaining `!!` or `??` markers AND the human has marked `Status: APPROVED`.

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

## 2) Precondition: research must be acceptable
- If `research.md` does not exist: stop and instruct to run `/presearch`.
- If `research.md` contains `!!` or `??` markers:
  - stop and instruct to iterate `/presearch` first (unless the human explicitly says to proceed).

## 3) Initialize the artifact if missing
- If `plan.md` does not exist:
  - Run:
    ```
    bash ${INTENT_PP_ROOT:-${CLAUDE_PLUGIN_ROOT}}/scripts/new_artifacts.sh plan
    ```

## 4) Write/update plan.md (implementation-grade, not vibes)
The plan must be specific enough that implementation is mostly mechanical.

### Required plan qualities
- Concrete:
  - exact files to touch
  - specific functions/types to add/change
  - specific schemas and migration notes
- Grounded:
  - `>>` references to existing patterns in the codebase
  - no invented APIs; if you propose something new, call it out clearly
- Safe:
  - enumerate risks + mitigations
  - preserve invariants discovered in research (bring them forward as `!! constraints`)
- Verifiable:
  - explicit commands (typecheck/tests/lint/build)
  - what output indicates success
- Traceable:
  - todo checklist that maps to the steps

### Plan structure
Fill the template sections:
- Goals / Non-goals
- Constraints (as `!!`)
- Approach
- Alternatives considered
- Files to change
- Step-by-step changes (each step has snippet/pseudodiff)
- Verification
- Rollback / migration plan
- Todo List (granular checkboxes)

## 5) Self-check (quality gates)
Run:
```
bash ${INTENT_PP_ROOT:-${CLAUDE_PLUGIN_ROOT}}/scripts/lint_plan.sh
```

If it fails, fix plan.md and rerun until it passes.

## 6) Hand-off to human
- Set `Status: IN_REVIEW`
- Ask the human to annotate plan.md using `!!/??/>>`
- Include a short summary:
  - what the plan changes
  - key risks
  - what needs human decisions (any `??`)

## 7) Iteration mode (plan.md exists)
If `plan.md` already exists:
- Parse all remaining `!!` and `??` markers and address each in-place.
- Update the plan, not the code.
- Rerun lint. Set `Status: IN_REVIEW`. Notify human again.
