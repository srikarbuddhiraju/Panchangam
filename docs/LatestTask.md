# Latest Task — Amrit Kalam + Festival Date Bugs

**Last updated:** Feb 28, 2026
**Status:** ALL DONE this session. APK built and installed on device.

---

## What Was Done This Session

### 1. Amrit Kalam Table — Full Feb 2026 Update (muhurtha.dart)
- Replaced sparse/wrong old entries with all 28 days from Feb 2026 Sringeri PDF.
- All 27 nakshatras now have at least one verified weekday entry (Vishaka had two days).
- **Key corrections vs old table:**

| Entry | Old value | Error | New value |
|-------|-----------|-------|-----------|
| Ashlesha [Sun] | -146 | Feb 2 is Monday, not Sunday | cleared → null |
| Ashlesha [Mon] | null | missed | -258 |
| Magha [Mon] | -194 | Feb 3 is Tuesday, not Monday | cleared → null |
| Magha [Tue] | null | missed | -194 |
| Uttara Phalguni [Thu] | -628 (Ra) | Type wrong; Feb 5 is Di | +648 (Di) |
| Hasta [Fri] | -80 (back-calc) | Unverified | -90 (3.75 ghati×24) |
| Chitra [Sat] | -147 | 6.23=153, not 147 | -153 |
| Swati [Sun] | -147 | 4.50=116, not 147 | -116 |
| Vishaka [Tue] | +501 (Di) | Feb 10 is Ra | -289 (Ra) |

- Days 25 (Rohini Wed) and 28 (Punarvasu Sat) have BOTH Di and Ra windows.
  Only Di stored for now. Ra values: Rohini Wed=-604, Punarvasu Sat=-490.
  Future: upgrade amritKalam() to return multiple windows.
- Ardra [Fri]=0 confirmed (Feb 27). Jyeshtha [Thu]=0 confirmed (Feb 12).
- Hasta Fri "3.75" and Krittika Tue "17.66" have ambiguous notation — need recheck.

### 2. Festival Date Bugs — FIXED (festival_data.dart + festival_calculator.dart)

**Root cause:** The `monthNumber()` formula (sun's rashi at nextAm → rashi+1) gives:
- Oct Amavasya: sun in Tula → month 7 (Ashvayuja). Traditional calls it Kartika = month 8.
- The Diwali cluster (Oct 18-21) is in month 7 per our formula — teluguMonth was set to 8 → fired 1 month late.
- Vaikunta Ekadashi: Ekadashi is a kshaya tithi (Dec 30-31, 2025 tithi jumps 10→12). Never appeared at sunrise → never fired.

**Fixes:**

| Festival | Old teluguMonth | New | Why |
|----------|----------------|-----|-----|
| Dhanteras | 8 | 7 | Oct 18-21 dates give monthNumber=7 |
| Naraka Chaturdashi | 8 | 7 | same |
| Deepavali | 8 | 7 | same |
| Vaikunta Ekadashi | 9 | 10 | Dec 30 gives monthNumber=10; + kshaya handling added |
| Mahalaya Amavasya | 7 | 6 | Sep Amavasya (sun Kanya) gives monthNumber=6 |

**Kshaya tithi handling added to `festival_calculator.dart`:**
When festival tithi N is skipped (today sunrise = N-1, tomorrow = N+1), fire on today.
This fixed Vaikunta Ekadashi Dec 30, 2025.

**Validated output (key dates):**

| Festival | 2024 | 2025 | 2026 |
|----------|------|------|------|
| Mahalaya Amavasya | Oct 2 ✓ | Sep 21 (traditional Sep 22, ~1 day off) | Oct 10 |
| Dasara | Oct 13 ✓ | Oct 2 ✓ | Oct 21 |
| Dhanteras | Oct 30 ✓ | Oct 19 ✓ | Nov 7 |
| Naraka Chaturdashi | Oct 31 ✓ | Oct 20 ✓ (Sringeri: Oct 20 "Diwali" ✓) | Nov 8 |
| Deepavali | Nov 1 ✓ | Oct 21 ✓ (Sringeri confirmed) | Nov 9 |
| Karthika Purnima | Nov 15 ✓ | Nov 5 ✓ | Nov 24 |
| Vaikunta Ekadashi | Jan 21 | Jan 10 + **Dec 30 ✓** (Sringeri confirmed) | (Jan 2027) |

### 3. Calendar Launch Bug (FIXED prev session, included in this commit)
`calendar_provider.dart` — `.valueOrNull` → `await .future` for festival and eclipse overlays.

---

## Open Items

### Low priority / next session
- Mahalaya Sep 21 vs traditional Sep 22 — 1 day tithi boundary difference, minor
- Dhanteras duplicate (vriddhi Trayodashi): hold until Srikar confirms no other festival issues
- Rohini Wed + Punarvasu Sat: add dual-window support to amritKalam() architecture
- Hasta Fri (-90) and Krittika Tue (+434): verify against original PDF
- Remove autoDispose from festivalProvider + eclipseProvider
- Sringeri disclaimer in app UI
- Dark mode validation
- MVP checklist session

---

## How to Rebuild APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```
