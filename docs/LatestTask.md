# Latest Task — Session 24 Complete, Session 25 Ready

**Last updated:** Mar 13, 2026
**Branch:** `main` (amrita branch merged)
**Next branch:** `feature/pro-tab-redesign`

---

## NEXT SESSION — START HERE

### Goal: Pro Tab Redesign (replaces Family tab)

**Decision made Mar 13, 2026:**
- Family tab → Pro tab (renamed + full redesign)
- Family sharing deferred to v1.1 (May/June) — too complex for April launch
- Release target: first week of April 2026

### Step 1: Create branch
```bash
git checkout -b feature/pro-tab-redesign
```

### Step 2: Build the Pro tab UI
Design direction — **premium/modern/dark**:
- Hero section: avatar, name, "Pro" badge chip, plan status
- Feature cards grid: Events, To-Dos, Reminders, Alarms — icon + title + 1-line desc
- Non-pro users: polished paywall prompt (not a boring list)
- Colors: deep navy (#0B1437) base, gold (#C9A84C) accents, subtle glassmorphism or gradient cards
- Reference feel: Spotify Premium, Apple One, Google One subscription tabs
- Avoid: flat white cards, basic settings-style list, anything that looks generic

### Step 3: Cleanup
- Archive/remove `FamilyScreen` placeholder
- Update tab label from "Family"/"కుటుంబం" → "Pro"/"ప్రో"
- Ensure bottom nav icon matches premium feel (maybe `workspace_premium` or `diamond`)

### Step 4: Verify
- `dart analyze` → no errors
- `flutter build apk --release` → install → visual check on device
- Confirm non-pro user sees paywall prompt, pro user sees feature cards

### Step 5: Merge
- Commit + merge `feature/pro-tab-redesign` → `main`

---

## What was done Session 24
1. ✅ Investigated PyJHora — dead end (Choghadiya, not nakshatra-based)
2. ✅ True Chitra Paksha ayanamsha implemented (Lahiri + nutation, ±0.5 min impact)
3. ✅ NK-filtered X calibration run — confirmed formula ceiling, no improvement possible
4. ✅ Decision: lookup-only amrit kalam, no formula fallback
5. ✅ UI: source attribution + honest "not available" explanation with reasoning
6. ✅ Release build 58.9 MB, installed on device, verified
7. ✅ Merged `feature/amrita-ramakumar-formula` → `main`
8. ✅ OCR accuracy assessed: 2026-27 ~95%+, 2025-26 standard entries ~90%+, Dec 10 confirmed error

## OCR Data Quality (carry forward)
- Dec 10, 2025: lookup=11:56 is WRONG, raw OCR says dawn amrit ~7:51 → needs fix
- ~10-15 Apr-Nov 2025 non-standard entries (తే/శే.అమృత) unverified
- Fix in next available session by checking 2025-26 PDF directly

## Decisions locked (Mar 13, 2026)
- **App name**: `Panchangam` — clean, pan-India scalable, no regional qualifier
- **Family tab**: replaced by Pro tab in v1.0; family sharing ships v1.1
- **Release target**: First week of April 2026

## Key file locations
- Pro tab (current placeholder): `app/lib/features/family/` → will become `app/lib/features/pro/`
- Tab structure: `app/lib/app/` (router + bottom nav)
- Theme colors: `app/lib/app/theme.dart` — `kSaffron`, `kGold`, `kNavyDark`
- Amrita lookup: `app/lib/core/data/amrita_lookup.dart`
