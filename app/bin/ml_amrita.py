#!/usr/bin/env python3
"""
ML pipeline for Amrita Kalam formula learning.

ML EXPLANATION (run before each stage):
  Stage 1 — Baseline: per-nakshatra mean fraction (current approach)
  Stage 2 — Linear regression: target_frac = a[nk] + b[nk] * moon_speed
             This adjusts for Moon's orbital speed variation (key insight).
  Stage 3 — Random Forest: non-linear, all features, best accuracy
  Stage 4 — Output: extract best parameters for Dart embedding

Input: features CSV from bin/compute_ml_features.dart output
       Columns: date, nk_idx, amrita_type, sringeri_time_min (offset from midnight),
                moon_speed_dph, time_frac, nk_duration_min, sunrise_min, nk_exit_min

Usage:
  python3 bin/ml_amrita.py <features_csv> [--output-dart]
"""

import sys, csv, json
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.model_selection import LeaveOneGroupOut
from sklearn.metrics import mean_absolute_error
from sklearn.preprocessing import OneHotEncoder
from collections import defaultdict

NAKSHATRA_NAMES = [
    "Ashwini", "Bharani", "Krttika", "Rohini", "Mrgasira", "Ardra",
    "Punarvasu", "Pushya", "Ashlesha", "Magha", "PvPhalguni", "UtPhalguni",
    "Hasta", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshtha",
    "Mula", "PvAshadha", "UtAshadha", "Shravana", "Dhanishtha",
    "Shatabhisha", "PvBhadra", "UtBhadra", "Revati"
]


def load_features(csv_path: str) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    print(f"Loaded {len(df)} entries from {csv_path}")
    print(f"Columns: {list(df.columns)}")
    # Drop rows with null features
    required = ['nk_idx', 'amrita_offset_min', 'moon_speed_dph',
                'nk_duration_min', 'nk_entry_lon', 'month_group']
    df = df.dropna(subset=[c for c in required if c in df.columns])
    print(f"After dropping nulls: {len(df)} entries")
    return df


def compute_frac_from_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Compute the longitudinal fraction and time fraction from features.
    target_lon_frac: what fraction through the nakshatra (0-1) corresponds to amrita
    target_time_frac: what fraction of nk_duration (0-1) has elapsed at amrita
    """
    if 'moon_lon_at_amrita' in df.columns and 'nk_entry_lon' in df.columns:
        nk_span = 13.3333
        df['lon_frac'] = ((df['moon_lon_at_amrita'] - df['nk_entry_lon']) % 360) / nk_span
        df['lon_frac'] = df['lon_frac'].clip(0, 1)
    if 'time_since_nk_entry_min' in df.columns and 'nk_duration_min' in df.columns:
        df['time_frac'] = df['time_since_nk_entry_min'] / df['nk_duration_min']
        df['time_frac'] = df['time_frac'].clip(0, 1)
    return df


def stage1_baseline(df: pd.DataFrame):
    """
    ML EXPLANATION — Stage 1 (Baseline):
    Simply average the target fraction per nakshatra.
    This is our current approach. Establishes the floor we need to beat.
    Expected accuracy: ~30-40% within 15 min (as seen in validation).
    """
    print("\n" + "="*60)
    print("STAGE 1 — Baseline: per-nakshatra mean fraction")
    print("="*60)
    print("Theory: amrita fires at fixed fraction F[nk] of nakshatra span.")
    print("Prediction: target_frac = mean(F[nk]) per nakshatra.")
    print("This IGNORES Moon speed variation — the root cause of error.\n")

    results = {}
    errors = []
    for nk_idx in range(27):
        subset = df[df['nk_idx'] == nk_idx]
        if len(subset) == 0:
            continue
        target_col = 'lon_frac' if 'lon_frac' in df.columns else 'time_frac'
        mean_frac = subset[target_col].mean()
        results[nk_idx] = mean_frac

        # Error: predict mean, compare to actual
        pred_offsets = subset['amrita_offset_min']  # actual
        # For baseline, we'd predict the same time for all entries of this nk
        # Error in minutes: if fraction changes by Δf, time error = Δf * nk_duration / 24h
        residuals = (subset[target_col] - mean_frac) * subset['nk_duration_min']
        errors.extend(residuals.abs().tolist())

    ok = sum(1 for e in errors if e <= 15)
    within30 = sum(1 for e in errors if e <= 30)
    total = len(errors)
    print(f"Within 15 min (OK): {ok}/{total} = {100*ok/total:.0f}%")
    print(f"Within 30 min: {within30}/{total} = {100*within30/total:.0f}%")
    print(f"Median error: {np.median(errors):.0f} min")
    return results


def stage2_linear_per_nk(df: pd.DataFrame):
    """
    ML EXPLANATION — Stage 2 (Per-nakshatra Linear Regression):

    Key insight: Moon's orbital speed varies ±15% due to eccentricity.
    When Moon moves FASTER, it covers the nakshatra span quicker.
    When Moon moves SLOWER, amrita fires at a different clock time.

    Model: target_frac = a[nk] + b[nk] * moon_speed_dph

    This is essentially: for each nakshatra, fit a line in (moon_speed, fraction) space.
    With 18+ data points per nakshatra (across months), this should capture the
    speed-dependent shift.

    Expected improvement: 50-65% within 15 min if speed is the dominant factor.
    """
    print("\n" + "="*60)
    print("STAGE 2 — Per-nakshatra Linear Regression on Moon Speed")
    print("="*60)
    print("Theory: fraction varies linearly with Moon's angular speed.")
    print("Model: target_frac = a[nk] + b[nk] * moon_speed")
    print("This accounts for Moon's orbital eccentricity.\n")

    target_col = 'lon_frac' if 'lon_frac' in df.columns else 'time_frac'
    params = {}  # nk_idx → (a, b)
    all_errors = []

    for nk_idx in range(27):
        subset = df[df['nk_idx'] == nk_idx].copy()
        if len(subset) < 3:
            if len(subset) > 0:
                params[nk_idx] = (subset[target_col].mean(), 0.0)
            continue

        X = subset[['moon_speed_dph']].values
        y = subset[target_col].values

        # Leave-one-month-out CV to test generalization
        if 'month_group' in subset.columns and subset['month_group'].nunique() > 1:
            groups = subset['month_group'].values
            logo = LeaveOneGroupOut()
            cv_errors = []
            for train_idx, test_idx in logo.split(X, y, groups):
                if len(train_idx) < 2:
                    continue
                model = LinearRegression()
                model.fit(X[train_idx], y[train_idx])
                pred = model.predict(X[test_idx])
                err_frac = np.abs(pred - y[test_idx])
                err_min = err_frac * subset.iloc[test_idx]['nk_duration_min'].values
                cv_errors.extend(err_min.tolist())
            if cv_errors:
                all_errors.extend(cv_errors)

        # Fit on all data for parameters
        model = LinearRegression()
        model.fit(X, y)
        params[nk_idx] = (float(model.intercept_), float(model.coef_[0]))

        nk_name = NAKSHATRA_NAMES[nk_idx] if nk_idx < 27 else f"nk{nk_idx}"
        print(f"  {nk_name:20s} n={len(subset):3d}  a={model.intercept_:.3f}  b={model.coef_[0]:+.4f}  R²={model.score(X,y):.3f}")

    if all_errors:
        ok = sum(1 for e in all_errors if e <= 15)
        within30 = sum(1 for e in all_errors if e <= 30)
        total = len(all_errors)
        print(f"\nLeave-one-month-out CV:")
        print(f"  Within 15 min: {ok}/{total} = {100*ok/total:.0f}%")
        print(f"  Within 30 min: {within30}/{total} = {100*within30/total:.0f}%")
        print(f"  Median error: {np.median(all_errors):.0f} min")

    return params


def stage3_global_model(df: pd.DataFrame):
    """
    ML EXPLANATION — Stage 3 (Global Random Forest):

    Random Forest captures non-linear relationships and interactions.
    Features used:
      - nk_idx (one-hot encoded) — which nakshatra
      - moon_speed_dph — orbital speed
      - sunrise_min — time of sunrise (proxy for season/latitude effect)
      - nk_duration_min — how long Moon stays in this nakshatra
      - time_frac (if available) — already normalized for duration

    Leave-one-month-out CV tells us how well it generalizes to unseen months.
    This is the gold standard for accuracy estimate.

    Expected: 75-90% within 15 min with 500+ entries.
    """
    print("\n" + "="*60)
    print("STAGE 3 — Global Random Forest (all features)")
    print("="*60)
    print("Model captures non-linear interactions between nakshatra,")
    print("Moon speed, and season. Leave-one-month-out CV shows")
    print("true generalization performance.\n")

    target_col = 'amrita_offset_min'  # predict offset in minutes directly
    feature_cols = ['nk_idx', 'moon_speed_dph', 'nk_duration_min']
    if 'sunrise_min' in df.columns:
        feature_cols.append('sunrise_min')
    if 'time_frac' in df.columns:
        feature_cols.append('time_frac')

    available = [c for c in feature_cols if c in df.columns]
    X = df[available].values
    y = df[target_col].values

    if 'month_group' not in df.columns:
        print("  No month_group column — running train/test split instead")
        from sklearn.model_selection import cross_val_score
        rf = RandomForestRegressor(n_estimators=200, max_depth=6, random_state=42)
        scores = cross_val_score(rf, X, y, cv=5, scoring='neg_mean_absolute_error')
        print(f"  5-fold CV MAE: {-scores.mean():.1f} ± {scores.std():.1f} min")
        rf.fit(X, y)
        return rf, available

    groups = df['month_group'].values
    logo = LeaveOneGroupOut()
    all_errors = []

    for train_idx, test_idx in logo.split(X, y, groups):
        rf = RandomForestRegressor(n_estimators=200, max_depth=8, random_state=42)
        rf.fit(X[train_idx], y[train_idx])
        pred = rf.predict(X[test_idx])
        all_errors.extend(np.abs(pred - y[test_idx]).tolist())

    ok = sum(1 for e in all_errors if e <= 15)
    within30 = sum(1 for e in all_errors if e <= 30)
    total = len(all_errors)
    print(f"Leave-one-month-out CV:")
    print(f"  Within 15 min: {ok}/{total} = {100*ok/total:.0f}%")
    print(f"  Within 30 min: {within30}/{total} = {100*within30/total:.0f}%")
    print(f"  Median error: {np.median(all_errors):.0f} min")
    print(f"\nFeature importances:")
    rf_final = RandomForestRegressor(n_estimators=200, max_depth=8, random_state=42)
    rf_final.fit(X, y)
    for feat, imp in sorted(zip(available, rf_final.feature_importances_), key=lambda x: -x[1]):
        print(f"  {feat:25s}: {imp:.3f}")

    return rf_final, available


def stage4_output_dart_params(linear_params: dict):
    """
    Output the learned linear parameters as Dart const arrays.
    These replace the current _amritFrac[] with a 2-param model:
      targetFrac = a + b * moonSpeed
    """
    print("\n" + "="*60)
    print("STAGE 4 — Dart Parameters")
    print("="*60)
    print("// Replace _amritFrac[] with these two arrays in muhurtha.dart:")
    print()

    a_vals = []
    b_vals = []
    for nk_idx in range(27):
        if nk_idx in linear_params:
            a, b = linear_params[nk_idx]
        else:
            a, b = 0.7, 0.0  # fallback
        a_vals.append(a)
        b_vals.append(b)

    print("  static const List<double> _amritFracBase = [")
    for i, (a, name) in enumerate(zip(a_vals, NAKSHATRA_NAMES)):
        print(f"    {a:.3f}, // {i+1:2d} {name}")
    print("  ];")
    print()
    print("  static const List<double> _amritFracSlope = [")
    for i, (b, name) in enumerate(zip(b_vals, NAKSHATRA_NAMES)):
        print(f"    {b:+.4f}, // {i+1:2d} {name}")
    print("  ];")
    print()
    print("  // Usage: frac = _amritFracBase[nk] + _amritFracSlope[nk] * moonSpeed;")
    print("  // where moonSpeed = Moon's angular speed in degrees/hour")
    return a_vals, b_vals


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 ml_amrita.py <features_csv> [--output-dart]")
        sys.exit(1)

    csv_path = sys.argv[1]
    output_dart = '--output-dart' in sys.argv

    df = load_features(csv_path)

    if df.empty:
        print("No data loaded. Check CSV format.")
        sys.exit(1)

    # Compute derived features
    df = compute_frac_from_features(df)

    # Stage 1: Baseline
    stage1_baseline(df)

    # Stage 2: Linear regression per nakshatra
    linear_params = stage2_linear_per_nk(df)

    # Stage 3: Random Forest (only if enough data)
    if len(df) >= 100:
        stage3_global_model(df)
    else:
        print(f"\nSkipping Stage 3 (need ≥100 entries, have {len(df)})")

    # Stage 4: Output Dart params
    if output_dart or True:
        stage4_output_dart_params(linear_params)


if __name__ == "__main__":
    main()
