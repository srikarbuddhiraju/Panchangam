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
