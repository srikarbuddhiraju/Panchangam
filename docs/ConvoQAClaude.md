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

**Q4. Any UX feedback from daily use?**
> UX is good for MVP but needs refinement before a great app.
> **Known bug**: Festivals, Grahana (eclipse) highlights do not appear on the landing page at app launch — user has to navigate to next/previous month first, then they appear.
> A dedicated UX refinement session is needed before release. Many small improvements required.
