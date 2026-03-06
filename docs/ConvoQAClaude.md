# Convo Q&A — Claude ↔ Srikar

_Questions Claude asked + Srikar's answers, saved for cross-session memory._

---

## Session: Feb 23 2026 — Pre-Release Planning

**Q1. Family tab — hide entirely or "Coming Soon" for MVP?**
> If Family Sharing (+ account management, premium payments, and dependencies) is finished by next week → include it. Otherwise, exclude entirely.
> **Decision**: Create a new branch `Family-Sharing-v1` for this work. Practice proper git branching from now on — internal versioning (v1, v2…) on feature branches, merge to main only for full releases.

**Q2. App name for Play Store?**
> "Panchangam" alone is the intent — this is what it is, and adding "Telugu Calendar" won't scale (goal is all Indic calendars).
> **Decision**: Defer final name decision. Ask again before release. Don't finalize without Srikar's sign-off.

**Q3. Play Store account — already set up?**
> Not yet. Srikar will set it up this weekend or next week.

**Q4. Amruthakalam fix — before release?**
> Yes. Fix it before release. Needs a proper nakshatra→hora table.
> **Session 11 finding**: 27×7 fixed-offset table is fundamentally flawed — same nakshatra+vara gives different offsets across months (nakshatra position shifts relative to sunrise). 8 conflict cells marked ‡ in muhurtha.dart. 27 new cells added from Dec 2025 + Mar 2026 Sarvam OCR. Architecture upgrade (nakshatra→hora) still needed before release.

**Q5. Dark mode — MVP or V1.1?**
> Option exists in settings but needs validation. Validate dark mode before release.

---

## Session: Feb 23 2026 — Amrit Kalam & Roadmap

**Q1. Source hierarchy for Amrit Kalam (and all traditional data)?**
> Priority: (1) Sringeri Panchangam, (2) TTD Panchangam, (3) DrikPanchang.
> Do NOT blindly rectify against other calendars — understand the core calculation and mechanism, question the approach first.
> For reading PDFs: ask Srikar for the specific page number, share only that. Do not skim/read entire PDFs — too many tokens.

**Q2. When Sringeri and DrikPanchang disagree, which wins?**
> Sringeri is the standard. It comes from the great Sringeri Matha, supervised by the gurus.
> **Action**: Add a note or disclaimer somewhere in the app acknowledging Sringeri Panchangam as the primary reference.

**Q3. What's next after Amrit Kalam is verified?**
> Review MVP checklist together before deciding. Goal is to reach MVP stage.
> Likely candidates: dark mode validation, festival loading bug, Family tab decision.

---

## Session: Feb 28 2026 — Panchangam Pro Planning (Sessions 1–3)

**Q1. Festival data migration — delete `festival_data.dart` or keep it?**
> Do not delete. Archive it to a `_archive/` subfolder as `.bak`. Build the new thing first, test it, then move the old one — never delete outright.
> **Decision**: `festival_data.dart` → `_archive/festival_data.dart.bak`. `FestivalCalculator` falls back to `FestivalData.all` in CLI/test contexts.

**Q2. Where to store `isPremium`?**
> Go with Claude's recommendation.
> **Decision**: `isPremium` stored in the existing `settings` Hive box (not a new box). Simpler, consistent with existing patterns.

**Q3. UUID vs manual ID for user events?**
> UUID chosen (after comparing options).
> **Decision**: `uuid: ^4.5.1` added to pubspec. UUID v4 (RFC 4122), collision-proof, cloud-sync-ready for future ₹119 Family tier.

**Q4. Push paywall files to git?**
> Do not push if it could be a vulnerability.
> **Decision**: `paywall_screen.dart` and `premium_shell_screen.dart` are gitignored (pricing is sensitive). `premium_guard.dart` is safe (no pricing) — gitignore updated to allow it specifically.

**Q5. Notifications — build now or later?**
> Build in Session 4 as planned. Needed at launch.
> **Decision**: Session 4 = Notifications. Reminder toggle in EventFormScreen is a placeholder until then.

**Q6. Git branching — mandatory?**
> YES, mandatory. One branch per session. Merge to main only when session is complete and verified.
> **Standing rule**: NEVER implement features directly on main. This applies to all future sessions.

**Q7. .md file updates — how often?**
> Update all relevant .md files every ~10 minutes during a session, or when a task completes.
> **Standing rule**: LatestTask.md, todo.md, lessons.md, ConvoQAClaude.md — all must be kept current.

**Q4. Any UX feedback from daily use?**
> UX is good for MVP but needs refinement before a great app.
> **Known bug**: Festivals, Grahana (eclipse) highlights do not appear on the landing page at app launch — user has to navigate to next/previous month first, then they appear.
> A dedicated UX refinement session is needed before release. Many small improvements required.

---

## Session: Mar 6, 2026 — Amrita Kalam Formula (Session 12)

**Q1. Amrita Kalam formula — what did we find?**
> **Finding**: The 27×7 table is wrong in principle. Formula is 1D: amritaStart = time when Moon's sidereal longitude reaches a nakshatra-specific target fraction (0.0–1.0). Di/Ra falls naturally from whether amritaStart is before/after sunset. Weekday is NOT a factor.
> Evidence: Anuradha 57%/59%/59% across Thu/Wed/Tue; Vishaka 65%/67% across Wed/Tue.
> **Implementation**: Bisection search over `LunarPosition.siderealLongitude()`. 27-entry `_amritFrac[]` table. 22/41 Sringeri entries validated within 15 min.

**Q2. Current accuracy and what's still failing?**
> 22/41 OK (≤15 min), 6 MISS, 13 WARN/FAIL. Root causes:
> - Nakshatra boundary ayanamsha mismatch (Dec08/10/11) — big deltas
> - Fraction variance (±5-10%) for nakshatras with only 1-2 data points (Revati, Chitra, Swati, Jyeshtha)
> - Ra.Amrita before sunrise (Dec14) — convention mismatch, won't fix
> **Decision**: Gather more data (Feb 2026 Sringeri entries) before finalizing. APK built but not installed.

**Q3. Feb 2026 data — status?**
> User confirmed they gave February 2026 data in a prior session, but it was NOT saved to a file (context compressed). Need re-paste. Target file: `docs/data/sringeri_feb2026.txt`.
