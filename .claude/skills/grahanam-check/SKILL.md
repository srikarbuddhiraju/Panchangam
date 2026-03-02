---
name: grahanam-check
description: Investigate and verify Grahanam (eclipse) timing calculations
---

Investigate the Grahanam (eclipse) start/peak/end timing calculations.

**Known issue:** Eclipse contact times appear to be off (flagged by Srikar, Mar 2 2026).

**Step 1 — Find the code:**
Grep for `grahanam`, `eclipse`, `Grahanam`, `EclipseCard`, `EclipseCalculator` in `app/lib/`

**Step 2 — Read the calculation logic:**
Look for:
- How first/fourth contact (external) are computed
- How second/third contact (internal, partial→total) are computed
- How maximum eclipse (peak) is computed
- Whether local circumstances corrections are applied for Hyderabad (17.385°N, 78.487°E)

**Step 3 — Identify the algorithm:**
- Is it using Meeus "Astronomical Algorithms" (the standard)?
- Is local parallax correction applied?
- Are Besselian elements used or a simpler approximation?

**Step 4 — Report findings:**
- What the code currently calculates (with example output for a known eclipse date)
- What reference values say (ask Srikar for NASA/USNO data if needed)
- The likely root cause of the discrepancy

**Hard Rule #5:** Do NOT write any fix until:
1. Root cause is clearly identified
2. Fix is proposed and explained
3. Srikar confirms → then implement
