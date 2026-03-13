# Panchangam App — Calculation Methods & Justifications

How the app computes each Panchangam element, why each algorithm was chosen,
and known accuracy characteristics.

**Primary references:**
- Karanam Ramakumar, *Panchangam Calculations* — archive.org/details/PanchangamCalculations
  (Also cited by drik-panchanga as primary source. Contains exact calculation formulae.)
- Jean Meeus, *Astronomical Algorithms* 2nd ed. — Sun/Moon position algorithms
- drik-panchanga (Python reference impl): github.com/webresh/drik-panchanga
  → Uses Swiss Ephemeris + Lagrange interpolation for tithi/nakshatra boundaries
  → Does NOT implement Amrit Kalam — useful for the 5 core elements only
- Sringeri Suvarnamukhya Panchangam — ground truth for Amrit Kalam, eclipse times

---

## Solar Position

**Algorithm**: VSOP87 (via Meeus Ch. 27)
**Accuracy**: ~0.001° (~3 arc-seconds)
**File**: `app/lib/core/calculations/solar_position.dart`

```
tropical_lon = VSOP87_series_sum(JDE)
sidereal_lon = tropical_lon − ayanamsa(JDE)
```

We upgraded from Meeus Ch. 25 (~0.01°) to Ch. 27 VSOP87 (~0.001°) to fix Adhika Masa
detection — the difference matters when a solar month is borderline.

**Ayanamsa**: Lahiri (official GoI standard).
```
ayanamsa ≈ 23° + correction_for_JDE   // computed via Meeus formula
```

---

## Lunar Position (Moon)

**Algorithm**: Meeus Ch. 47 (ELP2000-82 truncated series)
**Accuracy**: ~0.01° longitude, ~0.001° latitude
**File**: `app/lib/core/calculations/lunar_position.dart`

Moon longitude corrections include all major periodic terms from Meeus Table 47.A/47.B,
plus latitude corrections from 47.2 (all six terms — missing terms caused bugs in session 12).

**Note on Surya Siddhanta Moon**: Sringeri Panchangam is titled "Surya Siddhanta" but
empirically uses Drik (Meeus) Moon — verified by matching 111/116 nakshatra labels.
SS Moon equation of center (~5.02° × sin(M)) vs Drik (~6.29° × sin(M')) → ~1.2° difference
= ~133 min timing error. We use Drik Moon.

---

## Sunrise / Sunset

**Algorithm**: Standard solar hour angle formula
**File**: `app/lib/core/calculations/sunrise.dart`

```
H = arccos((sin(−0.833°) − sin(lat)×sin(dec)) / (cos(lat)×cos(dec)))
sunrise_UTC = 12 − H/15 − (lon/15 − tz_offset)
sunset_UTC  = 12 + H/15 − (lon/15 − tz_offset)
```

The −0.833° accounts for atmospheric refraction + solar disc radius (standard value).
All Kalam timings derive from this; accuracy of sunrise directly affects all derived timings.

---

## Tithi

```dart
tithiNum = ((moonLon - sunLon + 360) % 360 / 12).floor() + 1
if (tithiNum == 0) tithiNum = 30  // Amavasya
```

**Ending time**: bisect to find when (moonLon − sunLon) mod 360 reaches next multiple of 12°.
Tithi ending is **Ayanamsa-independent** (relative distance cancels absolute offset).

---

## Nakshatra

```dart
nakshatraNum = (moonSiderealLon / 13.3333).floor() + 1
pada         = ((moonSiderealLon % 13.3333) / 3.3333).floor() + 1
```

**Ending time formula** (from *Panchangam Calculations* p.25):
```
RD  = nakshatra_end_lon − moon_current_lon   // Remaining Degrees
DMC = moon_daily_motion                       // Daily Motion of Chandra (~13.17°/day)
hours_remaining = (RD / DMC) × 24
ending_time = reference_time + hours_remaining
```

Nakshatra ending time **is Ayanamsa-dependent** — different Ayanamsa → different sidereal Moon position.

---

## Yoga

```dart
yogaNum = ((sunLon + moonLon) % 360 / 13.3333).floor() + 1
```

Ending time: same formula as Nakshatra but using (Sun+Moon) combined motion (~1°/day Sun + ~13°/day Moon = ~14°/day combined DMC).
Yoga ending time is also Ayanamsa-dependent.

---

## Karana

```dart
// Each Tithi has 2 Karanas (first/second half)
tithiSeq = tithi × 2 − (isFirstHalf ? 1 : 0)   // 1-indexed position in month
// Fixed Karanas: positions 1, 58, 59, 60
// Repeating Karanas: positions 2–57 → (pos - 2) % 7
```

Known bug fixed (session 12): formula is `(seq−2)%7` not `(seq−1)%7`.
Kimstughna (seq=1) is fixed; the cycle of 7 starts from seq=2.

---

## Rahu / Gulika / Yamaganda Kalam

```dart
period = (sunset − sunrise) / 8
rahuStart   = sunrise + period × rahuMultiplier[vara]
gulikaStart = sunrise + period × gulikaMultiplier[vara]
yamaStart   = sunrise + period × yamaMultiplier[vara]
```

Multiplier tables (verified against Pillai's reference):
```
        Sun Mon Tue Wed Thu Fri Sat
Rahu:    7   1   6   4   5   3   2
Gulika:  6   5   4   3   2   1   0
Yama:    3   6   2   5   1   4   7   // Sat=7 = P6 (position 6), verified in session 8
```

---

## Abhijit Muhurtham

```dart
solarNoon  = (sunrise + sunset) / 2
abhijitStart = solarNoon − 12min
abhijitEnd   = solarNoon + 12min
// Exception: not auspicious on Wednesday
```

---

## Amrit Kalam

**Implementation**: Sringeri Panchangam lookup table only. No formula fallback.
**File**: `app/lib/core/data/amrita_lookup.dart` + `app/lib/core/calculations/muhurtha.dart`

### Why lookup-only (no formula)?

Amrit Kalam is computed by Sringeri using proprietary astronomical software with internal
calibration parameters that are not published. We exhaustively tested all known formula
approaches across 464 validated data points (Sessions 18–23):

| Formula approach | Mean error | Within 30 min |
|---|---|---|
| Ramakumar (Drik Moon, X table) | **131 min** | 23% |
| Empirically calibrated X values | **166 min** | 19% |
| Surya Siddhanta Moon variants | **400+ min** | <8% |
| Ayanamsha sweep ±2° from Lahiri | **>130 min** | <25% |

**Root cause**: Sringeri's amrita fraction within a nakshatra varies significantly day-to-day
(StdDev 0.5–3.4 X-units = 30–200 min variance). This is not a Moon model or formula
constant problem — it reflects additional inputs (likely tithi, vara, and/or proprietary
corrections) that are not in the public domain. No formula can achieve 5-10 min accuracy
without Sringeri's exact algorithm. Showing ~2h-off formula results would mislead users.

### Lookup table

- Source: OCR of Sringeri Suvarnamukhya Panchangam (Surya Siddhanta edition), 2025-26 and 2026-27 printed editions
- Coverage: Mar 2025 – Apr 2027 (~464 date entries, ~100% accurate vs published times)
- All times stored for **Kondavidu (80.5°E)**; deshantar correction applied per user location
- Outside coverage: `amritKalam()` returns null → UI shows "Data not available for this date"
- Update path: OCR each new Sringeri annual edition when released, extend `amrita_lookup.dart`

### Deshantar correction

From Sringeri Panchangam p.66 (దేశాంతర సంస్కార నిర్ణయము):
```dart
correctionMinutes = ((userLon − 80.5) × 4).round()
amritStart = tableTime.add(Duration(minutes: correctionMinutes))
```
Verified: Bengaluru (77.6°E) correction = −12 min ✓

### Ramakumar X table (archived — not used in production)

Source: Karanam Ramakumar, *Panchangam Calculations* p.26+ (archive.org)
Full text: `docs/data/PanchangamCalculations_fulltext.txt`
Used only in `amritKalamFormulaOnly()` for validation/diagnostic scripts.

```
amrita_start = nkStartTime + (X / 24) × nkDuration   // ~131 min mean error vs Sringeri
```

---

## Eclipse Detection

**Lunar eclipse**: Moon near Rahu/Ketu on Purnima. Shadow geometry (Meeus).
```
miss_distance = sqrt(delta_lon² + beta²)
threshold = umbralR + moonR = 1.0°   // NOT detection threshold (9.5°)
```
Contact times (Sparsha/Moksha) found by bisection on miss_distance = threshold.

**Solar eclipse**: Sun near Rahu/Ketu on Amavasya. Geocentric Moon-Sun separation.
```
miss = sqrt((moonLon−sunLon)² + (moonLat)²)
threshold = 1.566°   // Meeus solar ecliptic limit
```

**Sutak**: Solar = 12h before Sparsha. Lunar = 9h before Sparsha.

**India visibility**: Daytime check (solar max IST between 06:00–18:30) is necessary
but not sufficient. Full ground-track geometry deferred to future session.

---

## Samvatsara

**Anchor**: Visvavasu = Shaka 1947 (index 38 in 60-name cycle). Calibrated from known reference.
```dart
shakaYear = gregorianYear − 78  // after Mar 22
index = (shakaYear − 1947 + 38) % 60
```

---

## Telugu Month (Amavasyant)

Telugu months are lunar, not solar.
```
Find next Amavasya from given date
Read Sun's sidereal Rashi at that Amavasya
monthNumber = sunRashi + 1   // Rashi 0 (Mesha) = Chaitra = month 1
```

For Adhika Masa: if two Amavasyas occur in the same solar month (same Rashi both times),
the first lunar month = Adhika. Adhika month takes the name of the *following* Nija month
(nextNextAmavasya's Rashi).

---

## Known Accuracy Limits

| Element | Accuracy | Notes |
|---------|---------|-------|
| Sun position | ~0.001° | VSOP87 — highly accurate for all years |
| Moon position | ~0.01° | Meeus Ch. 47 full series — highly accurate |
| Sunrise/Sunset | ~30 sec | Standard refraction model |
| Tithi | ~1–2 min | Limited by Moon position accuracy |
| Nakshatra | ~1–2 min | Lahiri Ayanamsa — matches Sringeri 85%+ |
| Yoga | ~1–2 min | Lahiri Ayanamsa dependent |
| Karana | ~1–2 min | Derived from tithi |
| Vara (weekday) | Exact | Calendar arithmetic |
| Rahu/Gulika/Yamaganda | ~1–2 min | Standard table; limited by sunrise |
| Abhijit Muhurtham | ~1–2 min | Solar noon formula |
| Dur Muhurta | ~1–2 min | Standard weekday table; limited by sunrise |
| **Amrit Kalam (2025–2027)** | **~0 min** | **Exact Sringeri published times** |
| **Amrit Kalam (other years)** | **Not shown** | **No accurate formula exists** |
| Lunar eclipse contact | ~2–3 min | Shadow geometry (Meeus) |
| Solar eclipse contact | ~5–10 min | Geocentric geometry |
| Festival dates | ~0 days | Derived from accurate tithi/nakshatra |

**Summary**: All five Panchangam limbs (Vara, Tithi, Nakshatra, Yoga, Karana), Kalam timings,
festival dates, and eclipse timings are computed from first-principles astronomy and are
highly accurate for any year, past or present. Amrit Kalam is the sole exception — it is
shown only when exact Sringeri published data is available (currently Mar 2025–Apr 2027)
and is blank outside that window rather than showing an inaccurate approximation.
