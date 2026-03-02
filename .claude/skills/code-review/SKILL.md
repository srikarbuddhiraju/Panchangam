---
name: code-review
description: Review changed files against all 6 design philosophy pillars before merging
---

## Code Review — Design Philosophy Audit

Review all staged/uncommitted changes against the 6 pillars from CLAUDE.md.

### Step 1 — Get the diff
```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam
git diff HEAD
git diff --cached
```

### Step 2 — Rate each pillar (PASS / WARN / FAIL)

**1. Easy** — Is the code readable without needing to trace 3 files?
- No clever abstractions where a simple function works
- Variable names explain intent

**2. Scalable** — Can features be added without rewriting?
- No hardcoded lists that will become switch statements
- Single responsibility per class/file

**3. Robust** — Will it fail loudly?
- No bare `catch (_) {}` or `.ignore()` on platform/notification/persistence code (Hard Rule #3, #9)
- Input validation at system boundaries
- Errors surfaced before any fix is written (Hard Rule #1)

**4. Secure** — No secrets, no injections?
- No hardcoded API keys, passwords, pricing
- No string interpolation in SQL/platform commands
- Paywall files not accidentally staged

**5. Light** — No unnecessary dependencies?
- Any new `pubspec.yaml` dependency must be justified
- No copy-pasted Dart SDK functionality

**6. Accurate** — For calculation code only:
- Algorithm sourced from Meeus or Sringeri Panchangam
- All correction terms present and correctly referenced (not copy-pasted wrong)
- Tested against at least one known-good reference date

### Step 3 — Check Hard Rules
Scan for violations of CLAUDE.md Hard Rules:
- Rule #3: grep for `catch (_)` in changed files
- Rule #9: grep for `.ignore()` in changed files
- Rule #12: check docs/todo.md and docs/LatestTask.md for unchecked `[ ]` verification items

### Step 4 — Verdict
MERGE READY / NEEDS FIXES — list specific issues with file:line references.
