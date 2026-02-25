# Research: <short title>

Status: DRAFT  <!-- DRAFT | IN_REVIEW | ACCEPTED -->
Owner: <agent or human>
Last updated: <YYYY-MM-DD>

Task statement:
- <copy the task request here verbatim>

---

## TL;DR (5-10 bullets)
- <what the system does relevant to this task>
- <what will likely need to change>
- <biggest risks / coupling points>

---

## System overview
Explain the relevant subsystem in plain language.

>> Evidence:
- >> path/to/file.ext:Lx-Ly — <what it proves>
- >> path/to/other.ext:Lx-Ly — <what it proves>

---

## Entry points
List the real entry points.

- <entry point> — >> path/to/file:Lx-Ly
- <entry point> — >> path/to/file:Lx-Ly

---

## Data model / schemas
- Entities / tables / documents involved
- Important fields and relationships

>> Evidence:
- >> ...

---

## End-to-end flows
### Flow A: <name>
1) <step> >> path/to/file:Lx-Ly
2) <step> >> path/to/file:Lx-Ly
3) <step> >> path/to/file:Lx-Ly

### Flow B: <name>
...

---

## Invariants / constraints (write as `!!`)
!! <invariant / must-not-break behavior>
!! <auth boundary / response compatibility / ordering guarantee>
!! <performance constraint>

>> Evidence:
- >> ...

---

## Existing patterns to copy
- <pattern> >> path/to/reference:Lx-Ly
  - Copy: <what to reuse>
  - Avoid: <what not to do>

---

## Footguns / risk areas
- <risk> >> <evidence if possible>

---

## Open questions (write as `??`)
?? <question you cannot answer yet>
?? <decision needed from human>

---

## Research checklist
- [ ] Every major claim has at least one `>>` pointer.
- [ ] Entry points identified and traced.
- [ ] Invariants captured as `!!`.
- [ ] Open questions captured as `??` (and minimized).
- [ ] No hand-wavy "probably" statements without follow-up investigation.
