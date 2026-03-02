# Agents — Panchangam Project

Runnable slash commands for Claude Code. Each skill is a `.md` prompt in `.claude/skills/`.
Type the command in Claude Code to invoke it.

---

## Session Management

| Command | When to use |
|---------|------------|
| `/session-start` | First thing at the start of every session — reads all 3 required docs, gives current state summary |
| `/session-end` | Before ending a session — verifies checklist, updates docs, confirms merge readiness |

## Build & Deploy

| Command | When to use |
|---------|------------|
| `/build-release` | Full release APK build + ADB install (use before closing any session) |
| `/build-debug` | Fast debug build for Dart iteration (does not verify R8/ProGuard behavior) |

## Git

| Command | When to use |
|---------|------------|
| `/new-feature <name>` | Start of every new session — creates `feature/<name>` branch |

## Calculations

| Command | When to use |
|---------|------------|
| `/verify-date <YYYY-MM-DD>` | Verify all 5 Panchangam elements for a specific date against references |
| `/grahanam-check` | Investigate eclipse start/peak/end timing discrepancies |
| `/accuracy-check` | Full accuracy audit: validate script + eclipse reference cross-check |

## Notifications

| Command | When to use |
|---------|------------|
| `/notify-test` | Step-by-step device verification checklist for all notification types |

## Code Quality

| Command | When to use |
|---------|------------|
| `/code-review` | Audit changed files against all 6 design philosophy pillars (Easy/Scalable/Robust/Secure/Light/Accurate) |
| `/dep-check` | Audit pubspec dependencies for bloat, outdated versions, ProGuard coverage |

---

## Recommended Session Flow

```
/session-start          ← read docs, get summary
/new-feature <name>     ← create branch (if new session)
... do the work ...
/accuracy-check         ← after any calculation change
/code-review            ← before committing
/build-release          ← verify release build
/notify-test            ← if notification changes were made
/session-end            ← update docs, confirm merge readiness
```

---

## Adding New Skills

1. Create `.claude/skills/<skill-name>/SKILL.md`
2. Add `name:` frontmatter matching the folder name
3. Write the prompt with embedded project context (paths, rules, conventions)
4. Add a row to this README
5. Commit both files together

Skills live in `.claude/skills/` (tracked by git, shared across machines).
