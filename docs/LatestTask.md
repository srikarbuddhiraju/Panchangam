# Latest Task — Session 13 Complete (Paused at ML Features Step)

**Last updated:** Mar 7, 2026
**Branch:** feature/amrita-moon-fraction-formula

---

## What's Done (Sessions 1–12)
See git log. Session 12: amrita formula rewrote with Moon-fraction bisection, 69 validated entries.

---

## Session 13 — ML Pipeline (Data Collection + Parsing Complete)

### Decision
Option B: Gather 24 months of data → ML model (per-nakshatra linear regression on Moon speed).

### Completed This Session

**OCR (Sarvam AI, te-IN):**
- [x] API key `sk_etukp5zu_...` in `.env` (gitignored, NOT in memory)
- [x] Fixed `ocr_batch.py`: retry-on-429 (60s backoff), 10s inter-page delay, sequential runs
- [x] 2025-26 PDF: PDF pages 69–110 (printed 67–108) = Apr–Nov 2025 → `docs/data/ocr_raw/2526/` (42 pages)
- [x] 2026-27 PDF: PDF pages 58–83 (printed 55–80) = Mar 2026–Apr 2027 → `docs/data/ocr_raw/2627/` (26 pages)

**PDF Page Offsets (IMPORTANT — corrected this session):**
- 2025-26: `printed_page = pdf_page − 2` → use PDF pages 69–110 for Apr–Nov 2025
- 2026-27: `printed_page = pdf_page − 3` → use PDF pages 58–83 for Mar 2026–Apr 2027
- 2026-27: page 58 starts March 19, 2026 (Ugadi 2026 = Chaitra Shukla 1)

**Parsing:**
- [x] Rewrote `parse_amrita_ocr.py` for 2025-26 format (2-col HTML table, `ది.అమృత <frac> <period>॥<H>.<MM>మొ॥`)
- [x] New `parse_amrita_2627.py` for 2026-27 format (bi-weekly, `అ:<period>.<H>.<MM>`, explicit Gregorian date in col 2)
- [x] Period-to-24h conversion (both parsers):
  - ఉ॥: keep as-is (morning AM)
  - ప॥: h 1-6 → +12 (PM afternoon), h 7-11 → keep (AM)
  - సా॥: h < 12 → +12 (evening PM)
  - రా॥: h=12 → 0 (midnight), h 7-11 → +12 (PM night), h 0-6 → keep (early AM)
- [x] Parsed CSVs saved:
  - `docs/data/amrita_2526.csv` — 189 entries (Apr 2025–Jan 2026)
  - `docs/data/amrita_2627.csv` — 254 entries (Mar 2026–Apr 2027)
  - **Total: 443 new entries** (plus 69 existing = 512 total eventually)

**ML Pipeline Scripts Written:**
- [x] `bin/compute_ml_features.dart` — reads CSVs → computes Moon speed, nk_duration, lon_frac, sunrise → outputs `docs/data/ml_features.csv`
- [x] `bin/ml_amrita.py` — 4-stage ML: baseline → linear reg (frac = a + b×moonSpeed) → Random Forest → Dart params

### Blocked / To Do Next Session

1. **Run `compute_ml_features.dart`** (needs `dart analyze` first):
   ```bash
   cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
   dart run bin/compute_ml_features.dart \
     docs/data/amrita_2526.csv docs/data/amrita_2627.csv \
     docs/data/ml_features.csv
   ```
2. **Run ML pipeline**:
   ```bash
   python3 bin/ml_amrita.py docs/data/ml_features.csv --output-dart
   ```
3. **Update `muhurtha.dart`**: replace `_amritFrac[]` with `_amritFracBase[]` + `_amritFracSlope[]`
4. **Re-validate**: target ≥90% within 15 min
5. **Build + install APK**, verify on device `10BDAH07CM000MQ`
6. **Merge** `feature/amrita-moon-fraction-formula` → main

### Key Files This Session
| File | Purpose |
|------|---------|
| `app/bin/ocr_batch.py` | Sarvam OCR batch (with retry) |
| `app/bin/parse_amrita_ocr.py` | Parse 2025-26 OCR → CSV |
| `app/bin/parse_amrita_2627.py` | Parse 2026-27 OCR → CSV |
| `app/bin/compute_ml_features.dart` | CSV → ML features (Moon speed, nk_duration) |
| `app/bin/ml_amrita.py` | 4-stage ML training |
| `docs/data/amrita_2526.csv` | 189 parsed entries |
| `docs/data/amrita_2627.csv` | 254 parsed entries |
| `docs/data/ocr_raw/2526/` | 42 raw OCR pages |
| `docs/data/ocr_raw/2627/` | 26 raw OCR pages |

### Validation Status (before ML update)
15/69 OK (≤15 min) — inherent limit of 1D fraction model.
Target after ML: ≥90% within 15 min.

---

## Rebuild + Reinstall APK
```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```
