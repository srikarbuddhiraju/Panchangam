---
name: session-start
description: Read all session-start docs and give a crisp summary of current project state
---

Run the Panchangam session start checklist. Read these three files in order:

1. `docs/ConvoQAClaude.md` — past decisions and open questions from Srikar
2. `docs/lessons.md` — mistakes and rules to avoid repeating
3. `docs/LatestTask.md` — current task status and next items

Also run: `git branch --show-current` and `git log --oneline -3`

After reading, output a single crisp summary:

**Branch:** (current branch name)
**Last session:** (one line — what was completed)
**This session:** (numbered list from "Next Session" section of LatestTask.md)
**Hard blockers:** (any unchecked `[ ]` verification items — Rule #12 says these block merge)
**APK:** (size from LatestTask.md)

Do not start any work. Just the summary, ready to act.
