# Latest Task — Dark Mode Validation + Bug Fixes

**Last updated:** Feb 28, 2026
**Status:** DONE. APK built and installed. Ready to commit + push.

---

## What Was Done This Session

### 1. App Icon (previous commits 212398d → 3103e8b)
- Logo PNG applied as launcher icon — deep navy background (#0B1437), sun+moon centered at 85% zoom
- White background removed via ImageMagick `-fuzz 5% -transparent white -trim +repage`
- Both legacy icon (icon.png) and adaptive foreground (icon_fg.png) generated

### 2. Dark Mode Validation — Hardcoded Colors Fixed

**Root cause:** Multiple widgets used `Colors.grey` / `Colors.grey.shadeXXX` hardcoded, which becomes invisible in dark mode.

**Fix pattern:** `Colors.grey*` → `Theme.of(context).colorScheme.onSurfaceVariant`

| File | Issue | Fix |
|------|-------|-----|
| day_cell.dart | `Colors.white` (today circle text) | `colorScheme.onPrimary` |
| day_cell.dart | `Colors.grey.shade600` (nakshatra text) | `onSurfaceVariant` |
| month_header.dart | `Colors.grey` (subtitle text) | `onSurfaceVariant` |
| date_header_card.dart | `Colors.grey` (samvatsara text) | `onSurfaceVariant` |
| five_limbs_card.dart | `Colors.grey` × 3 (label/subtitle/endtime) | `onSurfaceVariant` |
| kalam_card.dart | `Colors.grey.shade200` (time bar track) | `colorScheme.outlineVariant` |
| timings_card.dart | `Colors.grey` (icon label text) | `onSurfaceVariant` |
| muhurtha_card.dart | `Colors.grey` (invalid state text) | `onSurfaceVariant` |
| festival_card.dart | `Colors.grey` + `.shade600` × 2 | `onSurfaceVariant` |
| context_card.dart | `Colors.grey.shade600` (chip label) | `onSurfaceVariant` |

### 3. Eclipse Card — 24hr Format Bug Fixed

**Root cause:** `EclipseCard` had no `use24h` parameter. `_TimingRow` and `_SutakRow` both hardcoded `DateFormat('h:mm a')`.

**Fix:**
- Added `use24h` parameter to `EclipseCard`, `_TimingRow`, `_SutakRow`
- Updated all three callers: `today_screen.dart`, `panchangam_screen.dart`, `eclipse_screen.dart`
- `eclipse_screen.dart` reads `use24h` from `settingsProvider`

### 4. Eclipse Card — "Visible in India" Chip Contrast

**Fix:** Chip text color → `kAuspiciousGreen` with `fontWeight.w600`, background alpha 0.1→0.15, border width 1→1.5

### 5. Eclipse Screen — Dark Mode Greys Fixed

Two `Colors.grey` occurrences in `eclipse_screen.dart` → `onSurfaceVariant`

### 6. App Name Capitalization

`android:label="panchangam"` → `"Panchangam"` in AndroidManifest.xml

---

## Open Items (Low Priority / Next Session)

- Mahalaya Sep 21 vs traditional Sep 22 — minor 1-day diff
- Dhanteras duplicate (vriddhi Trayodashi) — hold
- Rohini Wed + Punarvasu Sat dual Amrit Kalam windows — architecture upgrade
- Hasta Fri (-90) and Krittika Tue (+434) — verify against Sringeri PDF
- Remove autoDispose from festivalProvider + eclipseProvider
- Sringeri disclaimer in app UI
- Family tab decision (branch: `Family-Sharing-v1`)
- MVP checklist session
- Play Store account setup (Srikar)

---

## How to Rebuild APK

```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
/home/srikarbuddhiraju/development/flutter/bin/flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Icon Regeneration (if logo changes)

```bash
SRC="Logos & Assets/Logo/drawing.png"
magick "$SRC" -fuzz 5% -transparent white -trim +repage -resize 85%x85% -gravity center -background none -extent 1024x1024 app/assets/icon_fg.png
magick app/assets/icon_fg.png -background "#0B1437" -flatten app/assets/icon.png
cd app && dart run flutter_launcher_icons
```
