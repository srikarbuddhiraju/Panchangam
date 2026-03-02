---
name: new-feature
description: Create a new feature branch and prepare LatestTask.md for the session
---

Create a new feature branch for Panchangam. Branch name: `feature/$ARGUMENTS`

**Steps:**
1. Check working tree is clean: `git status`
   - If NOT clean: stop and ask Srikar how to handle uncommitted changes. Never stash without confirmation.
2. Check current branch: `git branch --show-current`
   - If on `main`: proceed to create branch
   - If on another feature branch: confirm with Srikar before branching off it
3. Create branch: `git checkout -b feature/$ARGUMENTS`
4. Update `docs/LatestTask.md`:
   - Change the heading to `# Latest Task — Session [N] In Progress`
   - Add branch name + today's date at the top

**Naming convention:** `feature/<short-description>`
Examples: `feature/grahanam-fix`, `feature/pro-session8-splash-logo`, `feature/agents-folder`

**Mandatory rule (from Srikar):** NEVER implement features on `main` directly.
One branch per session. Merge only when all verification items are checked.
