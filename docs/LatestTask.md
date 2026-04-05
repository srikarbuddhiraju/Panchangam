# Latest Task — Session 30 Complete

**Last updated:** Apr 5, 2026
**Branch:** `main`

---

## STATUS: Timezone-aware + 36 international cities merged to main

### Session 30 — What was done

1. ✅ Timezone architecture: `utcOffsetHours` threaded through all calculations
   - `JulianDay.toOffset()` / `fromOffset()` added (general timezone conversion)
   - All `toIST()` calls replaced — fully backward-compatible (default 5.5)
   - Files updated: tithi, nakshatra, yoga, karana, sunrise_sunset, moonrise_moonset,
     muhurtha, eclipse, panchangam_engine, all providers
2. ✅ `CityData.utcOffsetMinutes` field added (Hive key: `utcOffsetMins`)
3. ✅ 36 international cities with `tz` UTC offsets in `cities_india.json`
   - USA (10), Canada (2), UK (4), Europe (2), Australia (5), NZ (1), Gulf (9), SE Asia (2)
4. ✅ Eclipse visibility: `isVisibleFromLocation` uses user's lat/lng + local time
   - EclipseCard: "Visible from your location" / "Not visible from your location" (EN + TE)
5. ✅ Amrita kalam: deshantar correction scoped to India (lng 68–97°)
   - IST lookup shifted to local timezone for international users
6. ✅ `dart analyze`: 0 errors — merged to main and pushed

---

## NEXT SESSION — START HERE

### Blocked (external)
- **Play Store**: Google Play Developer account ($25) — budget, Srikar's call on timing

### Ready to build next
- **Release build**: Run `./build_release.sh`, install on device, spot-check timings for London/Dubai
- **DST handling** (v1.1): Add `timezone` package for proper DST support (deferred)
- **Security F2**: Client-side `isPremium` fix before billing goes live
- **Security F4**: GoRouter redirect guard for `/events/*` and `/todos/*`
- **Marketing**: Organic launch strategy — Akshaya Tritiya Apr 29 window

### Build process (CHANGED — always use this)
```bash
./build_release.sh    # gitignored, has --dart-define=PRO_EMAILS
```
Never run `flutter build apk --release` directly — builds with no Pro access.

### Srikar's pending tasks
- [ ] Google Play Developer account ($25) — when budget allows
- [ ] Feature graphic: 1024×500px (deep navy bg, centered icon, "Panchangam" in gold)
- [ ] Retake `ps-04-pro-tab.png` screenshot (current is empty state)
- [ ] Device test: install release APK, pick London → check eclipse timings in local time

---

## Key file locations
- Release keystore: `app/android/app/release.jks` (gitignored, local only)
- Signing credentials: `app/android/key.properties` (gitignored, local only)
- Build script: `build_release.sh` (gitignored) — USE FOR ALL RELEASE BUILDS
- Build template: `build_release.sh.example` (tracked)
- Security findings: `docs/security-findings.md`
- Play Store listing: `docs/play-store/listing.md`
- Privacy policy (GitHub Pages): `docs/privacy-policy.md`
- Privacy policy (Play Store ref): `docs/play-store/privacy-policy.md`
- International cities: `app/assets/data/cities_india.json`
- APK: 58.9 MB (release, signed — rebuild needed after this session's changes)
