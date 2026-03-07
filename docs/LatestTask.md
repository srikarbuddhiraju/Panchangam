# Latest Task — Session 13 Done, Session 14 Ready

**Last updated:** Mar 7, 2026
**Branch:** feature/amrita-moon-fraction-formula

---

## Session 13 Summary (Complete)

OCR'd 68 pages across both PDFs, parsed 443 amrita entries, wrote full ML pipeline.

**Data collected:**
- `docs/data/amrita_2526.csv` — 189 entries (Apr 2025–Jan 2026)
- `docs/data/amrita_2627.csv` — 254 entries (Mar 2026–Apr 2027)
- Raw OCR: `docs/data/ocr_raw/2526/` (42 pages) + `docs/data/ocr_raw/2627/` (26 pages)

**PDF offsets (critical):**
- 2025-26: `pdf_page = printed_page + 2`
- 2026-27: `pdf_page = printed_page + 3` (PDF 58 = printed 55 = March 19, 2026 Ugadi)

**Scripts written:**
- `app/bin/ocr_batch.py` — Sarvam OCR with retry/backoff
- `app/bin/parse_amrita_ocr.py` — 2025-26 format parser
- `app/bin/parse_amrita_2627.py` — 2026-27 format parser
- `app/bin/compute_ml_features.dart` — CSV → Moon speed + nk_duration features
- `app/bin/ml_amrita.py` — 4-stage ML training pipeline

---

## Session 14 — Next Steps (see docs/todo.md for full commands)

### Step 1 — Compute ML features
```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
dart run bin/compute_ml_features.dart \
  docs/data/amrita_2526.csv docs/data/amrita_2627.csv \
  docs/data/ml_features.csv
```

### Step 2 — Run ML
```bash
python3 bin/ml_amrita.py docs/data/ml_features.csv --output-dart
```
Copy Stage 4 output (`_amritFracBase[]` + `_amritFracSlope[]`) into `muhurtha.dart`.

### Step 3 — Validate
```bash
dart run bin/validate_amrita_formula.dart
```
Target: ≥90% within 15 min (currently 22%).

### Step 4 — Build + Install + Verify
```bash
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```
- [ ] Device confirmed accurate (hard blocker before merge)

### Step 5 — Merge to main

---

## Rebuild + Reinstall APK
```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```
