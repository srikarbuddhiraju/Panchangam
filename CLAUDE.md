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
6. **Capture Lessons**: Update "tasks/lessons.md" after corrections

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.