# Plan: <short title>

Status: DRAFT  <!-- DRAFT | IN_REVIEW | APPROVED -->
Owner: <agent or human>
Last updated: <YYYY-MM-DD>

Human++ markers in this plan:
- `!!` = blocker (must resolve before approval)
- `??` = question/uncertainty (must resolve or escalate)
- `>>` = reference/evidence pointer (keep these!)

---

## Goal
- <what we are trying to achieve>

## Non-goals
- <explicitly out of scope>

---

## Constraints (write as `!!`)
!! <must preserve response shape>
!! <must not change behavior X>
!! <migration constraint>

---

## Approach
Describe the approach in a few paragraphs.
Include why this fits existing patterns.

>> References:
- >> path/to/reference:Lx-Ly
- >> path/to/reference:Lx-Ly

---

## Alternatives considered
- Option A: ...
- Option B: ...
Why chosen approach is best.

---

## Files to change
(Explicit list; no surprises.)

- path/to/file1.ext
- path/to/file2.ext
- path/to/file3.ext

---

## Step-by-step changes

### Step 1: <title>
What:
- <clear description>

Where:
- path/to/file1.ext
- path/to/file2.ext

How (snippet / pseudodiff):
```diff
- old
+ new
```

Risks:
- <risk + mitigation>

Verification:
- Command: `<command>`
- Success looks like: <specific output/behavior>

---

### Step 2: <title>
...

---

## Verification plan (global)
- `pnpm test` (or your test command)
- `pnpm typecheck`
- `pnpm lint`
- <manual checks>

Define "done":
- <list the acceptance criteria>

---

## Rollback / migration
- <how to revert safely>
- <data migrations and how to undo / backfill>

---

## Todo List (execution checklist)

(Granular enough to drive implementation mechanically.)

- [ ] Step 1: <task>
  - Verify: `<command>` passes
- [ ] Step 2: <task>
  - Verify: `<command>` passes
- [ ] Step 3: <task>
  - Verify: `<command>` passes
