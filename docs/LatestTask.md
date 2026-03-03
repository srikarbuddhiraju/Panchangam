# Latest Task — Session 10 In Progress

**Last updated:** Mar 3, 2026
**Branch:** `feature/eclipse-sutak-display-fix`

---

## Session 9 (Pro UI) — Complete ✓
- [x] "Mark this Tithi" FAB paywall + two-button sheet
- [x] PremiumTeaser feature list
- [x] Splash screen logo
- [x] Disclaimer tile
- [x] Sign-in error surfacing → tested, no error reproduced, closed
- [x] APK 58.8 MB, device tested ✓, merged to main ✓

---

## Session 10 — Eclipse Fixes (In Progress)

### Bug 1 — Sutak display spanning midnight ✅ Fixed & committed
- `_SutakRow` now shows date when end.day ≠ start.day
- e.g. Aug 12, 2026 solar: "22:30 – 13/8 22:30" instead of "22:30 – 22:30"
- **Committed**: `fix(eclipse): show date in sutak range when spanning midnight`

### Bug 2 — Solar eclipse timing (was always 720 min fallback) ✅ Fixed
- Root cause: `_findSolarSparsha/Moksha` used node-distance (17° limit) which
  never crossed in the scan window → always fell back to ±6h = 720 min
- Fix: new `_solarMiss()` measures geocentric Moon–Sun angular separation
  (sqrt(delta_lon² + beta²)), analogous to lunar `_shadowMiss()`
- New `_findSolarMaximumJD` minimises `_solarMiss` (not `_nodeDist`)
- Contact threshold: 1.566° (Meeus Ch.54 solar ecliptic limit, includes parallax)
- Solar eclipses now show real durations (230–307 min) not fallback 720 min
- False positive (Aug 23, 2025) correctly eliminated by geometry check
- **Pending commit**

### Bug 3 — isVisibleInIndia hardcoded to true (deferred to Session 11)
- All eclipses show "Visible in India" regardless of ground track
- Requires eclipse ground track computation — Session 11 work

---

## Verified eclipse durations (after fix)

| Eclipse | Sparsha | Moksha | Duration |
|---|---|---|---|
| Mar 29, 2025 Annular Solar | 14:23 IST | 18:13 IST | 230 min ✓ |
| Sep 21, 2025 Total Solar | 22:39 IST | 03:47 IST+1 | 307 min ✓ |
| Feb 17, 2026 Annular Solar | 15:14 IST | 20:12 IST | 297 min ✓ |
| Aug 12, 2026 Annular Solar | 21:01 IST | 01:33 IST+1 | 271 min ✓ |

---

## Next Session — Work Items

1. **isVisibleInIndia** — implement real India visibility check or suppress
   false "Visible in India" for clearly non-Indian eclipses
2. **Solar timing accuracy** — current times are geocentric global contacts,
   not India-local. India-local computation needs eclipse ground track.
3. **UX refinement pass** — small improvements from daily use
4. **Push main to origin** — Srikar to do via SSH

---

## Rebuild + Reinstall APK

```bash
cd /home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```

## Diagnostic script
```bash
cd /home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
dart run bin/dump_eclipses.dart
```
