# Panchangam Project — Claude Instructions

## Project Overview
A Telugu Panchangam app with a modern calendar overlay.
- **Platform**: Android first, then iOS, then Web
- **Tech Stack**: Flutter (Dart)

## Owner
Srikar Buddhiraju. No prior programming experience. Learning as we build.

## Design Philosophy (ALWAYS follow these, no exceptions)
1. **Easy** — prefer simple, readable code over clever abstractions
2. **Scalable** — structure code so features can be added without rewriting
3. **Robust** — handle errors gracefully, strong typing, no silent failures
4. **Secure** — no hardcoded secrets, validate inputs, follow platform security guidelines
5. **Light** — minimize dependencies, avoid bloat, optimize for performance
6. **Accurate** — calculations MUST NOT compromise on precision. Use the highest-precision astronomical formulae available. Never accept known inaccuracies in core Panchangam calculations (tithi, nakshatra, solar position, etc.). Accuracy beats simplicity when it comes to the math.

## Tech Decisions (settled, do not re-question)
- Flutter + Dart for all platforms
- Single codebase: Android → iOS → Web rollout order

## Working Conventions
- Always explain what you're doing and why, in plain language
- When adding a dependency, justify it against the design philosophy
- Prefer Flutter built-ins over third-party packages where reasonable
- Keep files small and focused (single responsibility)
- Use feature-based folder structure inside `lib/`
- **Use tokens strategically** — prefer MCP server tools (dart, android-adb) over reading large files; use targeted Grep/Glob over broad reads; avoid re-reading files already in context
- **No web searches for reference data** — if you need external info (tables, specs, API docs), ask Srikar to fetch and paste it. Do not use WebSearch for this — it burns tokens and often fails.
- **Skim and scan, never read blindly** — when given a file, image, or pasted text, scan for the specific keyword/value you need first. Only read broadly if the targeted scan fails. For Panchangam PDF text, scan for ది.అమృత / రా.అమృత / అమృతఘటికాభావ directly.
- Always store what was the latest task/objective that was being worked, in `docs/LatestTask.md`. This has to be for every commit and session wise. Follow clear convention while updating this document.
- No need to keep history of all tasks/objective and sessions (since we already have commit messages for each commit) in `docs/LatestTask.md`, but rather the latest couple (at max).
- Always save the context in relevant .md files at regular intervals.
- **200-line limit on ALL markdown files (STANDING RULE)**: If any `.md` file exceeds 200 lines, split it immediately into smaller focused files. Follow a microservices-style architecture — each file has one clear responsibility, files are short and scannable, and they link to each other by relative path. Establish consistent naming conventions across the docs folder. This minimises token consumption when reading files at session start.
- You are free to check https://github.com/srikarbuddhiraju/Panchangam if needed. Do not read into files, as this is the same as project directory. Use it for reference purposes.

## Session Start Checklist
At the start of EVERY new session, read these files before doing anything else:
1. `docs/ConvoQAClaude.md` — past decisions and open questions from Srikar
2. `docs/lessons.md` — mistakes made and rules to avoid repeating them
3. `docs/LatestTask.md` — latest taks that was being worked on in the last session.

## Workflow Orchestration
### 1. Plan Node Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity
### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution
### 3. Self-Improvement Loop
- After ANY correction from the user: update "docs/lessons.md" with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project
### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness
### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it
### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding unless absolutely necessary
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management
1. **Plan First**: Write plan to "docs/todo.md" with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to "docs/todo.md"
6. **Capture Lessons**: Update "docs/lessons.md" after corrections
7. **LatestTask.md**: During any active work session, update `docs/LatestTask.md` every ~5 minutes with current status, what was done, what is pending, and any key findings. This is the handoff doc for the next session.

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## HARD RULES — Never Break These (learned the hard way)

### 1. Surface the error BEFORE writing any fix
When something is not working, the FIRST and ONLY action is to make it fail loudly.
- Remove or temporarily replace `catch (_)` with error surfacing
- Add a diagnostic UI (button, SnackBar, log) to expose the real error
- Read the error. Then — and only then — write a fix.
- **NEVER apply fixes to a silent failure. NEVER.**
- Applying fixes before reading the error is guessing. Guessing wastes builds, wastes the user's time, and erodes trust.

### 2. Never write a platform API call without verifying the exact method name
Before calling ANY method from a third-party package or platform plugin:
- `grep` the pub-cache source for the exact method signature
- Do not assume from memory, docs for a different version, or intuition
- One wrong method name = one failed build = wasted install cycle

### 3. Never use bare `catch (_)` on platform API code paths
`catch (_) { }` or `catch (_) { // silently skip }` on scheduling, permissions, or platform channel calls is forbidden.
- At minimum: `catch (e) { debugPrint('$e'); }`
- In user-facing flows: surface the error via SnackBar or rethrow
- Silent failures hide root causes and make debugging sessions multi-session nightmares

### 4. Read the relevant doc section before designing a feature
Before proposing a model or architecture for any feature:
- Read the relevant section in `docs/features.md` and `docs/LatestTask.md`
- Do not invent a design that contradicts what is already written
- One misread = wrong model = wasted planning + rework

### 5. Diagnose → propose → confirm → implement. In that order. Always.
For any non-trivial fix:
1. Get the actual error (surface it if needed)
2. Explain the root cause clearly
3. Wait for Srikar's nod before building
4. Implement, build, install
5. Wait for device confirmation before moving on
- Never chain multiple fix attempts without confirmation between them
- Never install a new build while the previous one hasn't been tested yet

### 6. Notification changes require explicit device confirmation before closing
There is no substitute for "I tested it, the notification fired."
- `dart analyze` passing = nothing. Build succeeding = nothing.
- Every notification-related change must end with: device test → confirmed → then close.
- Never mark a notification task complete based on code alone.

### 7. For R8/ProGuard/plugin issues — check the library's GitHub issues first
Before writing any ProGuard rule or platform workaround:
- Search the library's GitHub issues for the exact error string
- Check if the library has a `consumer-rules.pro` or documented R8 guidance
- The correct fix is almost always already documented — find it before guessing

### 8. Release builds are a different environment — test release explicitly
R8, ProGuard, minification, and reflection all behave differently in release vs debug.
- Any plugin using GSON, reflection, or serialisation must be tested in `--release`
- "Works in debug" means nothing for release-only failures
- For notification, platform channel, and persistence code: always build and test release

### 9. Never use `.ignore()` on user-facing async calls
`.ignore()` silences every error permanently. It is only acceptable when the operation has zero user-visible effect.
- For notifications, persistence, permissions, platform channels: NEVER use `.ignore()`
- If fire-and-forget is genuinely needed, use a named catchError:
  ```dart
  unawaited(_scheduleNotifications(event).catchError((e) => debugPrint('schedule: $e')));
  ```
- `_scheduleNotifications(event).ignore()` was the original sin that hid the R8 error for multiple sessions

### 10. Ship diagnostic/test UI on day 1 for any system-level feature
Any feature that cannot be verified visually in 10 seconds needs a test button shipped alongside it.
- Notifications: "Test" (immediate) + "Schedule Test" (1-min zonedSchedule) buttons
- Permissions: show granted/denied status in Settings
- If the diagnostic had existed in Session 4, the R8 error would have been caught the same day
- Rule: do not close the PR for any system-level feature without a way to test it manually

### 11. Notification channels are immutable once created on a device — design all channels upfront
Android notification channels cannot have their sound, importance, or audio attributes changed after creation.
- Before the first real-device install of any notification feature, define ALL required channels
- Reminder channel (notification sound) and Alarm channel (alarm ringtone, AudioAttributesUsage.alarm) must be separate from day 1
- You get one shot per channel ID — plan it before shipping

### 12. An unchecked verification item is a hard blocker — do not merge
If `docs/todo.md` or `docs/LatestTask.md` has an unchecked `[ ]` verification item, the branch does not merge.
- `[ ] Notification fires at correct time (device test)` sat unchecked across 3 merged sessions
- Treat unchecked verification items the same as failing tests: they block the merge