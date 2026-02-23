# Panchangam — Release Roadmap

## Release Target
**First week of March 2026** — full release if everything is complete, otherwise MVP release.

---

## MVP Definition (must-have for any release)
- [x] All 5 Panchangam limbs (Tithi, Vara, Nakshatra, Yoga, Karana)
- [x] All daily timings (Sunrise/Sunset, Moonrise/Moonset, Kalams, Muhurthas)
- [x] Calendar grid with Tithi/Nakshatra per cell
- [x] Day detail view (full Panchangam per day)
- [x] Festivals (major Telugu Hindu festivals)
- [x] Location picker (city-based, persisted)
- [x] Telugu + English language
- [ ] App icon (custom, not default Flutter)
- [ ] Splash screen (matches icon, not default Flutter)
- [ ] Family tab: hide or show "Coming Soon" — decide before release
- [ ] Play Store listing (title, description, screenshots, privacy policy)
- [ ] Internal testing pass (5+ users, varied devices)

## Post-MVP V1.1
- [ ] Festival markers on calendar grid cells
- [ ] Dark mode / theme toggle
- [ ] Sutak timings for eclipses
- [ ] Amruthakalam accuracy improvement (exact hora table, currently approximate)

## Post-MVP V2 (Premium)
- [ ] To-Dos, Reminders, Alarms
- [ ] Tithi-based occasions (birthdays, death anniversaries)
- [ ] Family sharing + group features
- [ ] User accounts (Google sign-in)

## Future
- [ ] Muhurtham finder
- [ ] Jatakam basics
- [ ] Home screen widget
- [ ] PDF export
- [ ] iOS release
- [ ] Web app

---

## Known Accuracy Gaps (fix before full release)
- **Amruthakalam**: Code is explicitly approximate (`horaOffsets` array, comment in `muhurtha.dart:67`). Needs exact nakshatra→hora table. Flagged 2026-02-23.
- **Durmuhurtha**: Wednesday overlap with Amruthakalam on 2026-03-04 is mathematically valid (independent systems), but worth validating against DrikPanchang.

---

## Claude Working Conventions (as of Feb 2026)
These govern how Claude works on this project:

### Workflow
1. **Plan First** — Enter plan mode for any non-trivial task (3+ steps or architectural decisions). Write plan to `docs/todo.md`.
2. **Verify Plan** — Check in with user before implementation starts.
3. **Track Progress** — Mark items complete as work progresses.
4. **Verify Before Done** — Never mark complete without proving it works. Run tests, check logs.
5. **Demand Elegance** — For non-trivial changes, pause and ask "is there a more elegant way?"
6. **Autonomous Bug Fixing** — Given a bug: just fix it. No hand-holding needed.
7. **Capture Lessons** — After any correction: update `docs/lessons.md`.

### Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, parallel analysis to subagents
- One focused task per subagent

### Self-Improvement
- `docs/lessons.md` — running log of mistakes, patterns, corrected approaches
- Review lessons at start of each session (relevant ones)
- Ruthlessly iterate until mistake rate drops

---

## Things Srikar Can Do Without Claude

### App Store / Release Prep (independent work)
- [ ] Design app icon (1024×1024 PNG, no alpha) — use Canva, Figma, or Adobe Express
- [ ] Create splash screen (simple: icon on white/saffron background)
- [ ] Set up Google Play Developer account ($25 one-time) if not done
- [ ] Write store listing: title (≤30 chars), short description (≤80 chars), full description (≤4000 chars) in English
- [ ] Write Telugu store listing (translation of above)
- [ ] Write privacy policy (use privacypolicygenerator.info or similar)
- [ ] Take Play Store screenshots (5–8 screenshots, various screen sizes) manually from device
- [ ] Set up internal test track on Play Console (upload APK, add testers)

### Testing (independent work)
- [ ] Manually verify 10+ dates against DrikPanchang (tithi, nakshatra, kalams, muhurthas)
- [ ] Test on at least 2 different Android devices/screen sizes
- [ ] Test edge cases: Amavasya, Purnima, Adhika month, eclipse days, Ugadi
- [ ] Test location change (settings → different city → verify times shift)
- [ ] Test language toggle (Telugu ↔ English)
- [ ] Test time format toggle (12h ↔ 24h)

### Content Decisions (independent work)
- [ ] Decide: Family tab → hide entirely, or show "Coming Soon" message
- [ ] Decide: any additional festivals to add before release
- [ ] Decide: app name for store listing (Panchangam? Telugu Panchangam? specific brand name?)
