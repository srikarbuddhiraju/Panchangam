# Claude Lessons — Panchangam Project

Running log of mistakes and rules to avoid repeating.
Updated after every user correction per CLAUDE.md Self-Improvement Loop.

**Platform & Debugging lessons** → [lessons_platform.md](lessons_platform.md)

---

## Calculation Accuracy

### Never implement a calculation change without first validating the theory against Sringeri data
- **Mistake**: Implemented Chaldean planetary hora system to replace the 27×7 table. Hora was theoretically motivated but NEVER spot-checked against even one Sringeri data point before writing code. Results were 65–714 minutes wrong.
- **What should have happened**: Pick 2-3 known Sringeri entries → compute what the formula gives → if they match within ~5 min → implement. This takes 5 minutes and catches wrong theories instantly.
- **Rule**: For ANY calculation architecture change: validate theory against ground truth FIRST. No exceptions. The "Accurate" design principle means ground truth wins over theory.
- **Rule**: A plan being in plan mode and "approved" does NOT mean the theory is correct. Re-verify the empirical premise before implementing, especially for core calculation changes.

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
- **Mistake**: Used my own (wrong) memory of NASA UTC times as reference — was 12 hours off
- **Correct reference**: Mar 3 2026 eclipse — Sringeri says Pa|| 3.20 (15:20 IST) Sparsha, Sa|| 6.47 (18:47 IST) Moksha
- **Rule**: Always use Sringeri Panchangam as primary reference. Ask Srikar for the specific values. Never rely on memory of eclipse UTC times.

### Sutak display bug — spanning midnight shows identical HH:mm
- **Bug**: `_SutakRow` formats start and end as `HH:mm` only. When sutakStart is
  evening of day N and moksha is same clock-time of day N+1, both show identically
  (e.g. "22:30 – 22:30"). Root cause: no date shown, times equal across midnight.
- **Fix**: Check if `start.day != end.day`; if so, prepend `d/M ` to end time.
- **Rule**: Any time range that can span midnight MUST include a date component,
  not just HH:mm. Test every eclipse manually for sutaka cross-midnight cases.

### Solar eclipse timing is still the old fallback (720 min) — FIXED Session 10
- The Session 8 shadow geometry fix was for LUNAR eclipses only.
  Solar eclipses still use `_findSolarSparsha/Moksha` with node-distance threshold,
  which always hits the fallback (±6h = 12h = 720 min duration).
- **Fix**: New `_solarMiss()` (geocentric Moon–Sun angular separation) + Meeus
  solar ecliptic limit 1.566° as contact threshold. Durations now 230–307 min.
- **Rule**: After any eclipse timing fix, run `dart run bin/dump_eclipses.dart`
  and verify Duration is NOT 720 min for any eclipse.

### Solar eclipse isVisibleInIndia is daytime-only (ground track deferred)
- Daytime check (max IST between 06:00–18:30) is a necessary but NOT sufficient
  condition for India visibility. Feb 17 2026 annular (Antarctica path) passes
  the daytime check (max at 17:43 IST) but is NOT visible from India.
- **Rule**: For solar eclipses, full India visibility requires eclipse ground
  track geometry. The daytime check is a placeholder until Session 11.

### Eclipse contact times used detection threshold, not shadow geometry
- **Bug**: `sutakThreshold = 9.5°` (node-distance limit for eclipse to occur) was used as Sparsha/Moksha threshold → 31h durations
- **Fix**: Shadow miss-distance = `√(delta_lon² + beta²)` where `delta_lon = moonSunDiff - 180°`, `beta = latitude`. Threshold = `umbralR + moonR = 1.0°`.
- **Rule**: Eclipse *detection* threshold ≠ contact *timing* threshold. Never reuse one for the other.

### Lunar latitude ΔB corrections had wrong variable references
- **Bug**: Used `sin(F)` instead of `sin(Lp)` for -2235 term; used `A1` instead of `A3` for +382 term; missing 4 terms
- **Fix**: Correct Meeus eq. 47.2: `-2235×sin(Lp) + 382×sin(A3) + 175×sin(A1-F) + 175×sin(A1+F) + 127×sin(Lp-Mp) - 115×sin(Lp+Mp)`
- **Rule**: For Meeus corrections, always match variable names to the exact equation — `Lp`, `A1`, `A3`, `F` are all different angles

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

---

## Sarvam OCR API (Session 13)

### API v2 format (verified working)
- Header: `api-subscription-key: <key>` (NOT `Authorization: Bearer`)
- Create job: `{"job_parameters": {"language": "te-IN", "output_format": "md"}}`
- Upload files: `{"job_id": "...", "files": ["page.pdf"]}` (strings, not objects)
- Upload URL: `upload_resp['upload_urls']['page.pdf']['file_url']`
- Download URL: `list(dl_resp['download_urls'].values())[0]['file_url']`
- Rate limit: 429 after ~3 concurrent requests — run sequentially with 10s inter-page delay + 60s backoff retry

### PDF Page Offsets (Sringeri Panchangams)
- **2025-26**: `pdf_page = printed_page + 2` (PDF 69 = printed 67, April 2025 Chaitra)
- **2026-27**: `pdf_page = printed_page + 3` (PDF 58 = printed 55, March 2026 Ugadi)
- Always confirm offset from first page content before running batch

### Panchangam Format Differences
- **2025-26**: per-day HTML table, `ది.అమృత <frac> <period>॥<H>.<MM>మొ॥`
- **2026-27**: bi-weekly compact, `అ:<period>.<H>.<MM>-<period>.<H>.<MM>`, Gregorian date in col 2

### Telugu Period-to-24h Conversion (CRITICAL)
- ఉ॥ (udayam/morning): keep as-is (5-12 AM)
- ప॥ (pagalu/daytime): h 1-6 → +12 (PM), h 7-11 → keep (AM morning)
- సా॥ (saayam/evening): h < 12 → +12 (17-20 PM)
- రా॥ (raatri/night): h=12 → 0 (midnight!), h 7-11 → +12 (19-23), h 0-6 → keep (early AM)
- తె॥ (pre-dawn): keep as-is
