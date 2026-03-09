# Latest Task — Session 20 Complete (Knowledge Base + Formula Found)

**Last updated:** Mar 9, 2026
**Branch:** `feature/ayanamsha-calibration`

---

## What was done this session

### Jan 7–28 gap filled
- Parsed `docs/data/sringeri_jan2026.txt` (was incorrectly dismissed earlier)
- Added 22 entries (Jan 7–28, excl. Jan 21 = no amrita) to `_table2526`
- Jan 21: confirmed అమృతఘటికాభావ
- Coverage now: Mar 30 2025 – Mar 18 2026 (195 entries), Mar 19 2026 – Apr 5 2027 (234 entries)

### Knowledge base created
- `docs/panchangam-concepts.md` — updated with:
  - Nakshatra absolute zodiac spans table (all 27 with degree-minute boundaries)
  - Nakshatra ending time formula (RD/DMC × 24)
  - Amrit Kalam / Varjyam section with Ramakumar formula
  - Yoga Ayanamsa dependency note
  - Primary sources section
- `docs/calculation-methods.md` — NEW: how app calculates every element, algorithms,
  justifications, accuracy table, complete Amrit Kalam X table (27 nakshatras)

### Amrit Kalam formula FOUND (major breakthrough)
Source: Karanam Ramakumar, *Panchangam Calculations* (archive.org/details/PanchangamCalculations)
Full text: `docs/data/PanchangamCalculations_fulltext.txt`

```
amrita_start    = nkStartTime + (X / 24) × nkDuration
amrita_duration = nkDuration / 15
```

X table: 27 values (Ashwini=16.8h, Bharani=19.2h, ...) — full table in `calculation-methods.md`

**Key finding**: Formula uses Nakshatra START TIME + time-fraction offset.
Our current `_amritFrac[]` approach was equivalent in concept but had wrong calibration.
Sringeri divergence is NOT a wrong formula — it's SS Moon nakshatra times vs Drik Moon times.

---

## Accuracy by date range

| Period | Source | Accuracy |
|---|---|---|
| Mar 30 2025 – Jan 6 2026 | Sringeri 2526 lookup | ~100% |
| Jan 7–28 2026 | Sringeri (sringeri_jan2026.txt, now added) | ~100% |
| Jan 29 – Mar 18 2026 | Sringeri gap-fill (parsed files) | ~100% |
| Mar 19 2026 – Apr 5 2027 | Sringeri 2627 lookup | ~100% |
| Outside all ranges | Ramakumar Drik formula (fallback) | ~Drik-accurate, ~133min off Sringeri |

---

## Next session

1. **Release build** — required before merging (Rule #8)
2. **Merge** `feature/ayanamsha-calibration` → `main` once release passes
3. **New feature branch**: Implement Ramakumar formula properly
   - `amrita_start = nkStartTime + (X/24) × nkDuration` with Drik Moon nakshatra times
   - Replace fixed 96-min duration with `nkDuration / 15`
   - Validate: apply to all 2026-27 lookup dates → should match within ~133 min (Drik vs SS)
   - **Then** try SS Moon for nakshatra times → should match Sringeri within ~5 min
4. **Optional**: Read more of Ramakumar book (PanchangamCalculations_fulltext.txt) for
   Varjyam and any other kalam formulas
