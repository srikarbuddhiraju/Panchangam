# Latest Task — Session 28 Complete

**Last updated:** Mar 15, 2026
**Branch:** `main`

---

## STATUS: Push + GitHub Pages done — Play Store next

### Session 28 — What was done

1. ✅ Pushed all Session 27 work to GitHub (`git push origin main`)
2. ✅ GitHub Pages enabled — publishing from `main` branch `/docs` folder
3. ✅ Privacy policy live at `https://srikarbuddhiraju.github.io/Panchangam/privacy-policy`
   - Fixed Jekyll 404: removed `layout: default` (no `_layouts/` dir), kept `title` only
4. ✅ Documented email replacement as pre-release to-do (not changed yet)

---

## NEXT SESSION — START HERE

### Goal: Play Store internal testing

1. Play Store Console: upload APK, add 5+ testers, submit listing
2. Tackle F3 (email whitelist in git) — move `_proEmails` out of source

### Srikar's tasks (independent)
- [ ] Google Play Developer account ($25 one-time) if not done
- [ ] Feature graphic: 1024×500px (deep navy bg, centered icon, "Panchangam" in gold)
- [ ] Retake `ps-04-pro-tab.png` screenshot after adding test events (current is empty state)
- [ ] Set up contact email on srikarbuddhiraju.com (e.g. hello@ or support@)
  → Once done, replace `srikarbuddhiraju@gmail.com` in:
  → `docs/privacy-policy.md:63`
  → `docs/play-store/privacy-policy.md:59`

---

## Key file locations
- Release keystore: `app/android/app/release.jks` (gitignored, local only)
- Signing credentials: `app/android/key.properties` (gitignored, local only)
- Security findings: `docs/security-findings.md`
- Play Store listing: `docs/play-store/listing.md`
- Privacy policy (GitHub Pages): `docs/privacy-policy.md`
- Privacy policy (Play Store ref): `docs/play-store/privacy-policy.md`
- APK: 58.9 MB (release, signed)
