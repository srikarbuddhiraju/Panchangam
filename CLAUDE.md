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
