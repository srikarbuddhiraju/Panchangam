# Claude Lessons — Panchangam Project

Running log of mistakes, corrections, and patterns to avoid repeating.
Updated after every user correction, per CLAUDE.md Self-Improvement Loop.

---

## Calculation Accuracy

### Samvatsara anchor was wrong
- **Mistake**: Calibration anchor was wrong
- **Fix**: Anchor = Visvavasu = Shaka 1947 index 38
- **Rule**: Always anchor samvatsara to a known verified reference, not derived math

### Yamaganda multiplier was wrong
- **Mistake**: Saturday multiplier was 7 (position P8)
- **Fix**: Should be 5 (position P6), per Pillai table [4,3,2,1,0,7,5]
- **Rule**: For kalam timings, always verify against the published table, not intuition

### Karana off-by-one in 60-karana sequence
- **Mistake**: Formula was `(seq-1)%7`, Kimstughna was in wrong position
- **Fix**: Formula is `(seq-2)%7`; seq 1 = Kimstughna is fixed
- **Rule**: Off-by-one errors in modular arithmetic are easy to miss — always verify with known examples (Amavasya karana, etc.)

### Ugadi kshaya logic was wrong (lookback approach)
- **Mistake**: Was using a lookback from T2 to T30 which was structurally wrong
- **Fix**: T30 at sunrise + T2 next day → Ugadi = today
- **Rule**: For festival logic, build forward from the correct definition, not backward from symptoms

### Telugu monthNumber was solar approximation
- **Mistake**: Was using solar position approximation for month number
- **Fix**: Correct Amavasyant = find next Amavasya → read sun rashi
- **Rule**: Telugu months are lunar (Amavasyant), not solar — never conflate the two

---

## UI / Navigation

### Calendar flicker
- **Mistake**: monthDataProvider was autoDispose, causing rebuild on every navigation
- **Fix**: Removed autoDispose + added `skipLoadingOnReload: true`
- **Rule**: Providers that back large grids must NOT be autoDispose; they get rebuilt too often

### Telugu locale crash
- **Mistake**: Used `DateFormat('te')` without initializing locale
- **Fix**: Call `initializeDateFormatting('te')` in main() before runApp
- **Rule**: Any non-default locale with intl must be initialized explicitly

### No back button on day detail
- **Mistake**: Used `context.go()` which replaced the navigation stack
- **Fix**: Changed to `context.push()` in calendar_grid.dart
- **Rule**: `go()` = replace stack (no back button). `push()` = add to stack (back works). Use push for drill-down navigation.

---

## Adhika Maasa

### Naming rule: Adhika uses FOLLOWING Nija month's name
- **Confirmed**: Traditional rule is Adhika month = same name as the following Nija month
- **Implementation**: `monthNumber()` for Adhika uses nextNextAm's rashi, not nextAm's rashi
- **Rule**: Never use the preceding month's name for Adhika — it's always named after what comes after

---

## Token Efficiency

### Do not read blindly into docs
- **Rule**: Skim and scan first to find what you need. Only read deeply if absolutely required.
- Don't open a full file/image to extract one value — target what you need first.

### Subagent for simple targeted searches = wasteful
- **Mistake**: Launched an Explore subagent to find Amruthakalam code — used 45k tokens
- **Fix**: Use direct Grep/Glob for known targets (file names, class names, function names)
- **Rule**: Reserve subagents for open-ended, multi-file exploration. For targeted searches, use Grep/Glob directly.

### Web search for reference data = wasteful
- **Mistake**: Attempted WebSearch for traditional Amrit Kalam table
- **Fix**: Ask the user to fetch the info (e.g., check DrikPanchang manually) and paste it
- **Rule**: If you need external reference data (tables, spec pages, external URLs), ask the user to fetch and paste it. Do not use WebSearch for large lookups.

---

## Screenshots / Documentation

### Screenshot naming must match content
- **Rule**: Always verify screenshot content before naming. Filename must accurately describe what's on screen.

---

## Dart / Build

### dart analyze can miss missing imports that the compiler catches
- **Mistake**: Three files used `UserTithiEvent` without importing `user_tithi_event.dart`. MCP `analyze_files` reported "No errors" but `flutter build apk --release` failed with `'UserTithiEvent' isn't a type.`
- **Fix**: Add the missing import to each affected file.
- **Rule**: Always do a full release build before declaring a session complete — the compiler catches things the analysis server can miss due to caching.

---

## Dart Syntax

### Local functions cannot have `final` modifier
- **Mistake**: Wrote `final String fmt(DateTime dt) => ...` inside a build() method
- **Fix**: Local functions are just `String fmt(DateTime dt) => ...` — no modifier
- **Rule**: In Dart, `final` applies to variables, not local function declarations

---

## Git Branching (MANDATORY)

### Always use feature branches
- **Rule**: NEVER implement features or sessions directly on main. Create a branch first.
- **Rule**: Naming convention: `feature/<short-description>` (e.g., `feature/pro-session1-data-foundation`)
- **Rule**: Merge to main only when session is complete and verified with tests + build
- **Rule**: For Pro feature sessions, one branch per session. Smaller branches for bug fixes.
- This is a standing instruction from Srikar — applies to ALL future sessions.

---

## Flutter Widget Architecture

### Double-Scaffold — two Scaffolds stacked = two AppBars
- **Mistake**: `FamilyScreen` had its own `Scaffold+AppBar`, and it was rendering `MyEventsScreen` (which also had a `Scaffold+AppBar`) inside its body. This stacks two AppBars on screen.
- **Fix**: Two-branch approach — if Pro, return `MyEventsScreen()` directly (it owns the Scaffold). If free, return a thin `Scaffold + PremiumGuard` (no child Scaffold inside).
- **Rule**: A widget that contains its own `Scaffold` must NOT be embedded inside another `Scaffold`'s body. If a screen owns its own layout (AppBar + FAB + body), the parent should return it directly, not wrap it.

---

## Data Persistence (CRITICAL)

### Never lose user-pasted data between sessions
- **Mistake**: User pasted Sringeri PDF entries (nakshatra data, amrit kalam offsets, etc.) during a session. I processed it in context but did NOT save it to a file. When the session ended, the data was lost. I then asked the user to paste it again — completely unacceptable.
- **Fix**: The moment a user pastes any reference data (PDF content, table entries, corrections, lookup values), IMMEDIATELY write it to a file in `docs/data/` or update the relevant source file. Do not wait until "later in the session."
- **Rule**: If the user pastes it, it gets saved to disk. No exceptions. Context is ephemeral. Files are permanent.
- **Rule**: After saving, confirm to the user: "Saved to docs/data/amrit_kalam_entries.md" so they know it's persisted.

---
