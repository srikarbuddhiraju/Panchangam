---
name: accuracy-check
description: Verify Panchangam calculation accuracy against known references
---

## Accuracy Check — Panchangam Calculations

Run a full accuracy audit against known-good reference values.

### Step 1 — Run validate script
```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
dart run bin/validate.dart
```
Capture all output.

### Step 2 — Check core calculations for a known date
Use Hyderabad, IST (UTC+5:30). Reference date: **Nov 1 2024** (Amavasya).

Known-good values (Sringeri Panchangam is the authority):
- Tithi #30 (Amavasya) at sunrise ✓
- Samvatsara: Krodhi (Shaka 1946), Visvavasu (Shaka 1947) ✓
- Saturday Yamaganda: multiplier 5 per Pillai table [4,3,2,1,0,7,5]

### Step 3 — Spot-check eclipse timings (if eclipse.dart was touched)
Reference eclipses (UTC):
- **Sep 7 2025** lunar: Sparsha ~15:27, Moksha ~18:55, Duration ~208 min (NASA)
- **Mar 3 2026** lunar: Sparsha ~21:57, Moksha ~01:49 (+1d), Duration ~212 min (NASA)

Compare with `_checkLunarEclipse` output. Duration error > 10 min = investigate.

### Step 4 — Check algorithm sources
For any calculation, verify against (priority order):
1. Sringeri Panchangam (highest authority)
2. TTD Panchangam
3. DrikPanchang
4. Jean Meeus "Astronomical Algorithms" (for solar/lunar position formulae)

### Step 5 — Report findings
For each check: PASS / FAIL / WARN with specific values.
Flag any discrepancy > 2 minutes for Tithi/Nakshatra, > 10 min for eclipse contacts.
