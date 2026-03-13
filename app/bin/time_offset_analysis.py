#!/usr/bin/env python3
"""
time_offset_analysis.py

Statistical analysis: lon_frac (fixed-fraction model) vs
time_since_nk_entry_min (time-offset model) for amrita kalam.

Hypothesis: if time_since_nk_entry_min has lower coefficient of variation
(CV = std/mean) than lon_frac across most nakshatras, the time-offset model
is a better predictor.
"""

import csv
import math
from collections import defaultdict

CSV_PATH = "docs/data/ml_features.csv"
OUT_PATH = "docs/data/time_offset_analysis.txt"


# ── helpers ──────────────────────────────────────────────────────────────────

def mean(vals):
    return sum(vals) / len(vals) if vals else float("nan")

def std(vals):
    if len(vals) < 2:
        return float("nan")
    m = mean(vals)
    return math.sqrt(sum((v - m) ** 2 for v in vals) / (len(vals) - 1))

def cv(vals):
    """Coefficient of variation in %: (std/mean)*100. Lower = more consistent."""
    m = mean(vals)
    s = std(vals)
    if m == 0 or math.isnan(m) or math.isnan(s):
        return float("nan")
    return (s / m) * 100.0

def pearson(xs, ys):
    """Pearson correlation between two equal-length lists."""
    if len(xs) < 3:
        return float("nan")
    mx, my = mean(xs), mean(ys)
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    dxs = math.sqrt(sum((x - mx) ** 2 for x in xs))
    dys = math.sqrt(sum((y - my) ** 2 for y in ys))
    if dxs == 0 or dys == 0:
        return float("nan")
    return num / (dxs * dys)

def fmt(v, decimals=2):
    if math.isnan(v):
        return "  n/a  "
    return f"{v:8.{decimals}f}"


# ── load data ─────────────────────────────────────────────────────────────────

rows = []
with open(CSV_PATH, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        try:
            rows.append({
                "date":          row["date"],
                "nk_name":       row["nk_name"],
                "nk_idx":        int(row["nk_idx"]),
                "amrita_type":   row["amrita_type"],   # "Di" or "Ra"
                "lon_frac":      float(row["lon_frac"]),
                "time_min":      float(row["time_since_nk_entry_min"]),
                "speed":         float(row["moon_speed_dph"]),
            })
        except (ValueError, KeyError):
            continue  # skip header or malformed rows

print(f"Loaded {len(rows)} rows from {CSV_PATH}")


# ── group data ────────────────────────────────────────────────────────────────

# All entries per nakshatra
by_nk = defaultdict(list)
# Entries split by Di / Ra per nakshatra
by_nk_type = defaultdict(lambda: defaultdict(list))  # nk → type → list

for r in rows:
    by_nk[r["nk_name"]].append(r)
    by_nk_type[r["nk_name"]][r["amrita_type"]].append(r)


# Nakshatra order (traditional 1-27, Ashwini first)
NK_ORDER = [
    "Ashwini", "Bharani", "Krttika", "Rohini", "Mrgasira", "Ardra",
    "Punarvasu", "Pushya", "Aslesha", "Magha", "PurvaPhalguni",
    "UttaraPhalguni", "Hasta", "Chitra", "Svati", "Vishakha",
    "Anuradha", "Jyeshtha", "Mula", "PurvaAshadha", "UttaraAshadha",
    "Shravana", "Dhanishtha", "Shatabhisha", "PurvaBhadra",
    "UttaraBhadra", "Revati",
]

# Collect nakshatras present in data, in traditional order
present_nks = [nk for nk in NK_ORDER if nk in by_nk]
# Add any nk names in data but not in our order list
for nk in sorted(by_nk.keys()):
    if nk not in present_nks:
        present_nks.append(nk)


# ── compute per-nakshatra stats ───────────────────────────────────────────────

def stats_for(entry_list):
    if not entry_list:
        return None
    fracs  = [e["lon_frac"]  for e in entry_list]
    times  = [e["time_min"]  for e in entry_list]
    speeds = [e["speed"]     for e in entry_list]
    return {
        "n":            len(entry_list),
        "frac_mean":    mean(fracs),
        "frac_std":     std(fracs),
        "frac_cv":      cv(fracs),
        "time_mean":    mean(times),
        "time_std":     std(times),
        "time_cv":      cv(times),
        "speed_mean":   mean(speeds),
        "speed_std":    std(speeds),
        "r_speed_frac": pearson(speeds, fracs),
        "r_speed_time": pearson(speeds, times),
    }


# ── output builder ────────────────────────────────────────────────────────────

lines = []
def out(s=""):
    lines.append(s)
    print(s)


out("=" * 90)
out("AMRITA KALAM  —  lon_frac vs time_since_nk_entry_min  —  Statistical Analysis")
out(f"Data: {CSV_PATH}   |   Total rows: {len(rows)}")
out("=" * 90)

out()
out("LEGEND")
out("  frac     = lon_frac   (fixed-fraction model: Moon is at X% of nakshatra span)")
out("  time_min = time_since_nk_entry_min  (time-offset model: X min after NK entry)")
out("  CV       = coefficient of variation = (std/mean)×100  — LOWER IS BETTER")
out("  r_spd_f  = Pearson(moon_speed, lon_frac)   — if high, speed predicts frac")
out("  r_spd_t  = Pearson(moon_speed, time_since_entry) — if high, speed predicts time")
out()


# ── section 1: ALL entries (Di + Ra combined) ─────────────────────────────────

out("─" * 90)
out("SECTION 1 — COMBINED (Di + Ra)")
out("─" * 90)
hdr = (
    f"{'Nakshatra':<18} {'N':>3}  "
    f"{'frac_mean':>9} {'frac_std':>8} {'frac_CV%':>8}  "
    f"{'time_mean':>9} {'time_std':>8} {'time_CV%':>8}  "
    f"{'spd_mean':>8} {'r_spd_f':>7} {'r_spd_t':>7}  "
    f"{'winner':>6}"
)
out(hdr)
out("─" * 90)

all_frac_cvs  = []
all_time_cvs  = []
time_wins = 0
frac_wins = 0
tie_count = 0

per_nk_stats = {}
for nk in present_nks:
    s = stats_for(by_nk[nk])
    if s is None:
        continue
    per_nk_stats[nk] = s

    if not math.isnan(s["frac_cv"]):
        all_frac_cvs.append(s["frac_cv"])
    if not math.isnan(s["time_cv"]):
        all_time_cvs.append(s["time_cv"])

    if not math.isnan(s["frac_cv"]) and not math.isnan(s["time_cv"]):
        if s["time_cv"] < s["frac_cv"] - 1:
            winner = "TIME"
            time_wins += 1
        elif s["frac_cv"] < s["time_cv"] - 1:
            winner = "FRAC"
            frac_wins += 1
        else:
            winner = "tie"
            tie_count += 1
    else:
        winner = "n/a"

    row_str = (
        f"{nk:<18} {s['n']:>3}  "
        f"{fmt(s['frac_mean'])  } {fmt(s['frac_std'])  } {fmt(s['frac_cv'])  }  "
        f"{fmt(s['time_mean'],1)} {fmt(s['time_std'],1)} {fmt(s['time_cv'])  }  "
        f"{fmt(s['speed_mean'],3)} {fmt(s['r_speed_frac'])} {fmt(s['r_speed_time'])}  "
        f"{winner:>6}"
    )
    out(row_str)

out("─" * 90)

mean_frac_cv = mean(all_frac_cvs) if all_frac_cvs else float("nan")
mean_time_cv = mean(all_time_cvs) if all_time_cvs else float("nan")
out(f"{'MEAN CV across nakshatras':<40} frac_CV={mean_frac_cv:.2f}%   time_CV={mean_time_cv:.2f}%")
out()
out(f"  Nakshatras where TIME-offset wins (CV lower by >1%): {time_wins}")
out(f"  Nakshatras where FRAC wins         (CV lower by >1%): {frac_wins}")
out(f"  Nakshatras tied (within 1%):                          {tie_count}")
out()
if mean_time_cv < mean_frac_cv:
    out(f"  >> CONCLUSION: TIME-OFFSET model has lower mean CV ({mean_time_cv:.2f}% vs {mean_frac_cv:.2f}%)")
    out(f"     Hypothesis SUPPORTED: fixed-time-offset model is more consistent than fixed-fraction.")
else:
    out(f"  >> CONCLUSION: FRACTION model has lower mean CV ({mean_frac_cv:.2f}% vs {mean_time_cv:.2f}%)")
    out(f"     Hypothesis NOT supported by this data.")
out()


# ── section 2: Di vs Ra separately ───────────────────────────────────────────

for atype in ["Di", "Ra"]:
    out("─" * 90)
    out(f"SECTION 2{'' if atype == 'Di' else 'b'} — {atype} ONLY")
    out("─" * 90)
    out(hdr)
    out("─" * 90)

    a_frac_cvs = []
    a_time_cvs = []
    a_time_wins = 0
    a_frac_wins = 0
    a_ties = 0

    for nk in present_nks:
        entries = by_nk_type[nk].get(atype, [])
        s = stats_for(entries)
        if s is None:
            out(f"{nk:<18} {'0':>3}  (no {atype} entries)")
            continue

        if not math.isnan(s["frac_cv"]):
            a_frac_cvs.append(s["frac_cv"])
        if not math.isnan(s["time_cv"]):
            a_time_cvs.append(s["time_cv"])

        if not math.isnan(s["frac_cv"]) and not math.isnan(s["time_cv"]):
            if s["time_cv"] < s["frac_cv"] - 1:
                winner = "TIME"
                a_time_wins += 1
            elif s["frac_cv"] < s["time_cv"] - 1:
                winner = "FRAC"
                a_frac_wins += 1
            else:
                winner = "tie"
                a_ties += 1
        else:
            winner = "n/a"

        row_str = (
            f"{nk:<18} {s['n']:>3}  "
            f"{fmt(s['frac_mean'])  } {fmt(s['frac_std'])  } {fmt(s['frac_cv'])  }  "
            f"{fmt(s['time_mean'],1)} {fmt(s['time_std'],1)} {fmt(s['time_cv'])  }  "
            f"{fmt(s['speed_mean'],3)} {fmt(s['r_speed_frac'])} {fmt(s['r_speed_time'])}  "
            f"{winner:>6}"
        )
        out(row_str)

    out("─" * 90)
    mfc = mean(a_frac_cvs) if a_frac_cvs else float("nan")
    mtc = mean(a_time_cvs) if a_time_cvs else float("nan")
    out(f"{'MEAN CV — ' + atype:<40} frac_CV={mfc:.2f}%   time_CV={mtc:.2f}%")
    out(f"  TIME wins: {a_time_wins}  |  FRAC wins: {a_frac_wins}  |  Ties: {a_ties}")
    out()


# ── section 3: speed correlation summary ─────────────────────────────────────

out("─" * 90)
out("SECTION 3 — MOON SPEED CORRELATION SUMMARY (combined Di+Ra)")
out("─" * 90)
out(f"  r(speed, lon_frac)           — if near ±1, speed determines where in NK Moon fires")
out(f"  r(speed, time_since_entry)   — if near ±1, slower Moon = more time to hit amrita")
out()

r_spd_frac_all  = []
r_spd_time_all  = []
for nk in present_nks:
    s = per_nk_stats.get(nk)
    if s is None:
        continue
    entries = by_nk[nk]
    speeds = [e["speed"]    for e in entries]
    fracs  = [e["lon_frac"] for e in entries]
    times  = [e["time_min"] for e in entries]
    r_sf = pearson(speeds, fracs)
    r_st = pearson(speeds, times)
    if not math.isnan(r_sf):
        r_spd_frac_all.append(r_sf)
    if not math.isnan(r_st):
        r_spd_time_all.append(r_st)
    out(f"  {nk:<18}  r(spd,frac)={fmt(r_sf)}   r(spd,time)={fmt(r_st)}  n={s['n']}")

out()
out(f"  Mean |r(speed,frac)| across nakshatras : {mean([abs(r) for r in r_spd_frac_all]):.3f}")
out(f"  Mean |r(speed,time)| across nakshatras : {mean([abs(r) for r in r_spd_time_all]):.3f}")
out()
mean_r_sf = mean([abs(r) for r in r_spd_frac_all])
mean_r_st = mean([abs(r) for r in r_spd_time_all])
if mean_r_sf > 0.3:
    out("  >> Moon speed is moderately/strongly correlated with lon_frac.")
    out("     Speed-adjusted fraction formula may further improve accuracy.")
if mean_r_st > 0.3:
    out("  >> Moon speed is moderately/strongly correlated with time_since_entry.")
    out("     A time formula that includes speed as a factor may help.")
if mean_r_sf < 0.2 and mean_r_st < 0.2:
    out("  >> Speed shows weak correlation with both models — speed is not a useful predictor.")


# ── section 4: overall recommendation ────────────────────────────────────────

out()
out("=" * 90)
out("OVERALL RECOMMENDATION")
out("=" * 90)
out(f"  Combined mean CV  — lon_frac model     : {mean_frac_cv:.2f}%")
out(f"  Combined mean CV  — time-offset model  : {mean_time_cv:.2f}%")
out()
gap = mean_frac_cv - mean_time_cv
if gap > 2:
    out(f"  TIME-OFFSET model wins by {gap:.1f}% mean CV margin.")
    out(f"  RECOMMENDATION: Adopt time_since_nk_entry_min as the primary predictor.")
    out(f"  Next step: fit a per-nakshatra mean time-offset and use that as the formula.")
elif gap < -2:
    out(f"  LON_FRAC model wins by {abs(gap):.1f}% mean CV margin.")
    out(f"  RECOMMENDATION: Keep the current fraction-based approach.")
    out(f"  Next step: refine per-nakshatra fraction constants.")
else:
    out(f"  Models are roughly equivalent (gap = {gap:.1f}%).")
    out(f"  Consider checking Di vs Ra split — one type may favour a different model.")

out()
out(f"Saved to: {OUT_PATH}")
out("=" * 90)


# ── write output file ─────────────────────────────────────────────────────────

with open(OUT_PATH, "w") as f:
    f.write("\n".join(lines) + "\n")

print(f"\nDone. Results written to {OUT_PATH}")
