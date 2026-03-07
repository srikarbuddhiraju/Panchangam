# Session 14 — To Do

**Branch:** feature/amrita-moon-fraction-formula
**Goal:** Run ML pipeline → update muhurtha.dart → validate → APK

---

## Step 1 — Compute ML features
```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
dart run bin/compute_ml_features.dart \
  docs/data/amrita_2526.csv docs/data/amrita_2627.csv \
  docs/data/ml_features.csv
```
Expected: ~443 rows in docs/data/ml_features.csv

## Step 2 — Run ML pipeline
```bash
python3 bin/ml_amrita.py docs/data/ml_features.csv --output-dart
```
Expected output:
- Stage 1 baseline (~30% within 15 min)
- Stage 2 linear regression per nakshatra → `_amritFracBase[]` + `_amritFracSlope[]` arrays
- Stage 3 Random Forest accuracy (target ≥90% within 15 min)
- Stage 4 Dart arrays printed to stdout — copy into muhurtha.dart

## Step 3 — Update muhurtha.dart
File: `app/lib/core/calculations/muhurtha.dart`
- Replace `_amritFrac[]` (single array) with:
  - `_amritFracBase[]` (27 doubles, intercept a)
  - `_amritFracSlope[]` (27 doubles, slope b)
- Update `amritKalam()` to use: `frac = _amritFracBase[nk] + _amritFracSlope[nk] * moonSpeed`

## Step 4 — Re-validate
```bash
dart run bin/validate_amrita_formula.dart
```
Target: ≥90% within 15 min (was 15/69 = 22%)

## Step 5 — Build + Install APK
```bash
flutter build apk --release
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk
```

## Step 6 — Verify on device
- Open app → check amrita kalam for today and next few days
- Compare with Sringeri Panchangam
- [ ] Device confirmed ≥90% accurate

## Step 7 — Merge
```bash
git checkout main
git merge feature/amrita-moon-fraction-formula
git push
```
