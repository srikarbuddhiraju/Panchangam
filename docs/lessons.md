# Claude Lessons — Panchangam Project

Running log of mistakes and rules to avoid repeating.
Updated after every user correction per CLAUDE.md Self-Improvement Loop.

**Platform & Debugging lessons** → [lessons_platform.md](lessons_platform.md)
**Amrita Kalam & OCR lessons** → [lessons_amrita.md](lessons_amrita.md)

---

## Calculation Accuracy

### Never implement a calculation change without first validating the theory against Sringeri data
- **Mistake**: Implemented Chaldean planetary hora system. Theoretically motivated but NEVER spot-checked against even one Sringeri data point. Results were 65–714 minutes wrong.
- **Rule**: For ANY calculation architecture change: validate theory against ground truth FIRST. Pick 2-3 known Sringeri entries → compute what the formula gives → if they match within ~5 min → implement.
- **Rule**: A plan being in plan mode and "approved" does NOT mean the theory is correct. Re-verify the empirical premise before implementing.

### Samvatsara anchor was wrong
- **Fix**: Anchor = Visvavasu = Shaka 1947 index 38
- **Rule**: Always anchor samvatsara to a known verified reference, not derived math

### Yamaganda multiplier was wrong
- **Fix**: Saturday = 5 (position P6), per Pillai table [4,3,2,1,0,7,5]
- **Rule**: For kalam timings, always verify against the published table, not intuition

### Karana off-by-one in 60-karana sequence
- **Fix**: Formula is `(seq-2)%7`; seq 1 = Kimstughna is fixed
- **Rule**: Off-by-one in modular arithmetic — always verify with known examples

### Ugadi kshaya logic was wrong (lookback approach)
- **Fix**: T30 at sunrise + T2 next day → Ugadi = today
- **Rule**: Build festival logic forward from the correct definition, not backward from symptoms

### Telugu monthNumber was solar approximation
- **Fix**: Correct Amavasyant = find next Amavasya → read sun rashi
- **Rule**: Telugu months are lunar (Amavasyant), not solar — never conflate the two

### Validate eclipse times against Sringeri, not NASA website
- **Mistake**: Used own (wrong) memory of NASA UTC times as reference — was 12 hours off
- **Rule**: Always use Sringeri Panchangam as primary reference. Ask Srikar for the specific values.

### Sutak display bug — spanning midnight shows identical HH:mm
- **Fix**: Check if `start.day != end.day`; if so, prepend `d/M ` to end time
- **Rule**: Any time range that can span midnight MUST include a date component, not just HH:mm

### Solar eclipse timing was fallback (720 min) — FIXED Session 10
- **Fix**: New `_solarMiss()` (geocentric Moon–Sun angular separation) + Meeus solar ecliptic limit 1.566° as contact threshold. Durations now 230–307 min.
- **Rule**: After any eclipse timing fix, run `dart run bin/dump_eclipses.dart` — verify Duration is NOT 720 min

### Eclipse contact times used detection threshold, not shadow geometry
- **Bug**: `sutakThreshold = 9.5°` was reused as Sparsha/Moksha threshold → 31h durations
- **Fix**: Shadow miss-distance = `√(delta_lon² + beta²)`. Threshold = `umbralR + moonR = 1.0°`
- **Rule**: Eclipse *detection* threshold ≠ contact *timing* threshold. Never reuse one for the other.

### Lunar latitude ΔB corrections had wrong variable references
- **Fix**: Correct Meeus eq. 47.2: `-2235×sin(Lp) + 382×sin(A3) + 175×sin(A1-F) + 175×sin(A1+F) + 127×sin(Lp-Mp) - 115×sin(Lp+Mp)`
- **Rule**: For Meeus corrections, always match variable names to the exact equation

---

## UI / Navigation

### Calendar flicker
- **Fix**: Removed autoDispose on monthDataProvider + `skipLoadingOnReload: true`
- **Rule**: Providers backing large grids must NOT be autoDispose

### Telugu locale crash
- **Fix**: Call `initializeDateFormatting('te')` in main() before runApp
- **Rule**: Any non-default locale with intl must be initialized explicitly

### No back button on day detail
- **Fix**: `context.push()` instead of `context.go()`
- **Rule**: `go()` = replace stack. `push()` = add to stack. Use push for drill-down.

---

## Adhika Maasa

### Naming rule: Adhika uses FOLLOWING Nija month's name
- **Rule**: Adhika month = same name as the FOLLOWING nija month (nextNextAm's rashi, not nextAm's)

---

## Token Efficiency

### Subagent for simple targeted searches = wasteful
- **Rule**: Use Grep/Glob for known targets. Reserve subagents for open-ended multi-file exploration.

### Web search for reference data = wasteful
- **Rule**: Ask Srikar to fetch and paste external data. Do not use WebSearch for tables/specs.

### Do not read blindly into docs
- **Rule**: Skim and scan first. Only read broadly if targeted scan fails.

---

## Dart / Build

### dart analyze can miss missing imports that the compiler catches
- **Rule**: Always do a full `flutter build apk --release` before declaring a session complete.

### Local functions cannot have `final` modifier
- **Rule**: In Dart, `final` applies to variables, not local function declarations.

---

## Git Branching (MANDATORY)

### Always use feature branches
- **Rule**: NEVER implement on main. Create `feature/<short-description>` branch first.
- **Rule**: Merge only when session is complete AND all verification items are checked.
- Standing instruction from Srikar — applies to ALL future sessions.

---

## Flutter Widget Architecture

### Double-Scaffold — two Scaffolds stacked = two AppBars
- **Fix**: If a screen owns its Scaffold, the parent returns it directly — never wraps it in another Scaffold.

---

## Data Persistence

### Never lose user-pasted data between sessions
- **Rule**: If the user pastes it, immediately write it to `docs/data/` or the relevant source file.
- **Rule**: Confirm to the user: "Saved to docs/data/filename.md"

---

## Design / Feature Planning

### Read existing docs before designing any feature
- **Rule**: Read `docs/features.md` and `docs/LatestTask.md` relevant section before proposing any model.
- **Mistake**: Designed To-Dos as Gregorian-date-based when features.md clearly stated tithi-based.

---

## Screenshots / Documentation

### Screenshot naming must match content
- **Rule**: Verify screenshot content before naming. Filename must accurately describe what's on screen.
