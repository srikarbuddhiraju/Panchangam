# Latest Task — Amrit Kalam 27×7 Table (IN PROGRESS)

**Last updated:** Feb 27, 2026
**Status:** Architecture complete. 11 of 189 cells verified. Actively gathering more data from Sringeri PDF.

---

## What Was Done This Session

### Key Discovery
The Amrit Kalam type (Di.Amrita vs Ra.Amrita) and offset are NOT fixed per nakshatra alone.
The same nakshatra gives different types on different weekdays.
E.g., Vishaka = Di.Amrita 501 min on Tuesday, Ra.Amrita 254 min on Monday.
A **27×7 nakshatra×weekday table** is required.

### Architecture Implemented
- Replaced two `_dayOffset`/`_nightOffset` arrays with a single `_amritTable` — a 27×7 `List<List<int?>>`.
- Encoding: `null`=unverified, `0`=confirmed none, `+N`=Di.Amrita N min from sunrise, `-N`=Ra.Amrita N min from sunset.
- `amritKalam()` now takes `vara` (weekday 0-6) as a parameter.
- Updated call sites in `panchangam_engine.dart` and `validate_amrit.dart`.
- validate_amrit.dart updated to show weekday column and sunrise+sunset for easy verification.

### Files Changed
- `app/lib/core/calculations/muhurtha.dart`
- `app/lib/core/calculations/panchangam_engine.dart`
- `app/bin/validate_amrit.dart`

---

## Verified Table Entries (11/189)

| # | Nakshatra | Weekday | Type | Minutes | Source |
|---|-----------|---------|------|---------|--------|
| 6 | Ardra | Tuesday | none | 0 | Jan 27 Sringeri PDF |
| 8 | Pushya | Saturday | Ra | 144 | Feb 01 Sringeri PDF |
| 9 | Ashlesha | Sunday | Ra | 146 | Feb 02 Sringeri PDF |
| 10 | Magha | Monday | Ra | 194 | Feb 03 Sringeri PDF |
| 11 | Purva Phalguni | Wednesday | Di | 626 | Feb 04 Sringeri PDF |
| 12 | Uttara Phalguni | Thursday | Ra | 628 | Feb 05 Sringeri PDF |
| 13 | Hasta | Friday | Ra | 80 | Feb 06 back-calc (needs recheck) |
| 14 | Chitra | Saturday | Ra | 147 | Feb 07 Sringeri PDF |
| 15 | Swati | Sunday | Ra | 147 | Feb 08 Sringeri PDF |
| 16 | Vishaka | Monday | Ra | 254 | Feb 09 Sringeri PDF |
| 16 | Vishaka | Tuesday | Di | 501 | Jan 13 Sringeri PDF |

### Known Contradictions (need more data)
- Jyeshtha #18, Thursday: Jan 15 shows Ra.Amrita 143 min BUT Feb 12 shows no amrit kalam. Left null.
- Hasta #13, Friday: source offset "3.75" unclear — 80 min back-calculated from clock. Needs recheck.
- Mula/PurvaAshadha plan values (449 min, 682 min) were based on misidentified nakshatra — removed.

---

## Validation Output (dart run bin/validate_amrit.dart)

```
 8  పుష్యమి    Sat  2026-03-28  06:13  18:28  20:52 – 22:28  ✓
 9  ఆశ్లేష     Sun  2026-03-29  06:12  18:28  20:54 – 22:30  ✓
10  మఖ          Mon  2026-03-30  06:12  18:28  21:42 – 23:18  ✓
11  పుబ్బ      Wed  2026-03-04  06:32  18:23  16:58 – 18:34  ✓ (Di.Amrita)
12  ఉత్తర     Thu  2026-03-05  06:31  18:23  04:51 – 06:27  ✓ (next morning)
13  హస్త       Fri  2026-03-06  06:30  18:23  19:43 – 21:19  ✓
14  చిత్త      Sat  2026-03-07  06:30  18:24  20:51 – 22:27  ✓
15  స్వాతి    Sun  2026-03-08  06:29  18:24  20:51 – 22:27  ✓
16  విశాఖ     Mon  2026-03-09  06:28  18:24  22:38 – 00:14  ✓
```

32/32 tests pass. dart analyze clean.

---

## To Do For Next Session

### Amrit Kalam (priority)
1. **Continue pasting Feb 13–28 entries** — Srikar was mid-paste when session was interrupted.
   Need: nakshatra name + Di/Ra type + ghati.vipala offset after each amrit label.
2. **Resolve Jyeshtha contradiction** — Jan 15 (Ra 143 min) vs Feb 12 (none) both Thursday.
   Ask for one more Jyeshtha entry on a different weekday to see if pattern holds.
3. **Recheck Hasta** — Feb 06 offset "3.75" unclear. Ask for that entry again.
4. **After more data** — rebuild APK, push to device, Srikar spot-checks.

### Other Pending
- Festival bugs: Vaikunta Ekadashi showing Dec 1 (should be Dec 30), Diwali wrong date
- Festival/eclipse not loading on calendar launch (provider init timing bug)
- Sringeri disclaimer in app UI
- MVP checklist session

---

## How to Rebuild APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```
