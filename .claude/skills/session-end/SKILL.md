---
name: session-end
description: End-of-session checklist — verify items, update docs, check merge readiness
---

Run the Panchangam end-of-session checklist. Work through each item:

1. **Verification blockers** — list all unchecked `[ ]` items in `docs/LatestTask.md` and `docs/todo.md`.
   Any unchecked verification item is a hard blocker — branch does not merge (Rule #12).

2. **Line limit** — check all `.md` files in `docs/` for the 200-line rule.
   Run: `wc -l docs/*.md` — any file over 200 lines must be split immediately.

3. **Update LatestTask.md** — add what was done this session, update verification checklist,
   update "Next Session" items list.

4. **Update lessons.md** — if any corrections were made this session, add the pattern now.

5. **Git status** — show uncommitted changes (`git status` + `git diff --stat`).
   Remind: commit docs before ending session.

6. **Merge readiness verdict**:
   - All verification items checked? ✓ or ✗
   - All .md files under 200 lines? ✓ or ✗
   - Docs committed? ✓ or ✗
   - → READY TO MERGE or BLOCKED (list reasons)

Do not commit or merge without Srikar's explicit confirmation.
