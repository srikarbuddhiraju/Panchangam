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

**Current implementation**: Date-keyed Sringeri lookup table + Moon-bisection formula fallback.
**File**: `app/lib/core/data/amrita_lookup.dart` + `app/lib/core/calculations/muhurtha.dart`

### Lookup table (Sessions 18–20)

- `_table2526`: 195 unique dates, Mar 30 2025 – Mar 18 2026 (~100% accurate)
- `_table2627`: 234 unique dates, Mar 19 2026 – Apr 5 2027 (~100% accurate)
- Outside range → formula fallback (~15% accurate within 15 min)
- Source: OCR of Sringeri Suvarnamukhya Panchangam PDFs (2025-26 and 2026-27 editions)
- All times stored for **Kondavidu (80.5°E)**

### Deshantar correction (regional time adjustment)

From Sringeri Panchangam p.66 (దేశాంతర సంస్కార నిర్ణయము):
```dart
correctionMinutes = ((userLon − 80.5) × 4).round()
amritStart = tableTime.add(Duration(minutes: correctionMinutes))
```
Reference point: Kondavidu = 80.5°E. Works for any city algorithmically.
Verified: Bengaluru (77.6°E) correction = −12 min ✓

### Ramakumar Formula (FOUND — Session 20)

Source: Karanam Ramakumar, *Panchangam Calculations* p.26+
Full text saved: `docs/data/PanchangamCalculations_fulltext.txt`

```
amrita_start    = nkStartTime + (X / 24) × nkDuration
amrita_duration = nkDuration × (1.6 / 24)    // 1/15th of nakshatra duration
```

Where:
- `nkStartTime` = time when Moon's sidereal longitude first crosses into this Nakshatra
- `nkDuration` = nkEndTime − nkStartTime (in hours; varies ~19–26h)
- `X` = per-Nakshatra constant (hours, for a 24h reference nakshatra)

**X table** (Amrit Gadiyas offset, hours from Nakshatra start, for 24h duration):

| # | Nakshatra | X (Amrit) | X (Varjyam) |
|---|-----------|-----------|-------------|
| 1 | Ashwini | 16.8 | 20.0 |
| 2 | Bharani | 19.2 | 9.6 |
| 3 | Krittika | 21.6 | 12.0 |
| 4 | Rohini | 20.8 | 16.0 |
| 5 | Mrigasira | 15.2 | 5.6 |
| 6 | Ardra | 14.0 | 8.4 |
| 7 | Punarvasu | 21.6 | 12.0 |
| 8 | Pushyami | 17.6 | 8.0 |
| 9 | Ashlesha | 22.4 | 12.8 |
| 10 | Makha | 21.6 | 12.0 |
| 11 | Pubba | 17.6 | 8.0 |
| 12 | Uttara | 16.8 | 7.2 |
| 13 | Hasta | 18.0 | 8.4 |
| 14 | Chitra | 17.6 | 8.0 |
| 15 | Swati | 15.2 | 5.6 |
| 16 | Vishakha | 15.2 | 5.6 |
| 17 | Anuradha | 13.6 | 4.0 |
| 18 | Jyeshtha | 15.2 | 5.6 |
| 19 | Moola | 17.6 | 8.0 / 22.4 |
| 20 | Purvashadha | 19.2 | 9.6 |
| 21 | Uttarashadha | 17.6 | 8.0 |
| 22 | Shravana | 13.6 | 4.0 |
| 23 | Dhanishtha | 13.6 | 4.0 |
| 24 | Shatabhisha | 16.8 | 7.2 |
| 25 | Purvabhadra | 16.0 | 6.4 |
| 26 | Uttarabhadra | 19.2 | 9.6 |
| 27 | Revati | 21.6 | 12.0 |

**Equivalence to our `_amritFrac[]`**: `frac = X / 24`
(The time-fraction and longitude-fraction are equivalent under uniform Moon motion.)

**Duration note**: Duration is NOT a fixed 96 min. It scales with nakshatra duration:
- 24h nakshatra → 96 min amrit window
- 19h nakshatra → 76 min window
- 26h nakshatra → 104 min window

### Why Sringeri still diverges from this formula

The Ramakumar formula is **Drik Ganitha** (uses observed/ephemeris Moon).
Sringeri Panchangam uses **Surya Siddhanta Moon** for nakshatra start/end times.
SS Moon is ~1.2° behind Drik Moon → ~133 min difference in nakshatra boundary timing
→ same X fraction applied to different nkStartTime/nkDuration gives different amrita times.

**To match Sringeri for all years**: Implement SS nakshatra start/end times, apply X table.
→ This was the Session 19 plan (`SuryaSiddhantaMoon` class). Now we have the X table too.

### Long-term accuracy roadmap
| Period | Source | Accuracy |
|--------|--------|---------|
| Mar 2025 – Apr 2027 | Sringeri lookup table | ~100% |
| All other years | Ramakumar Drik formula | Good for Drik; ~133min off Sringeri |
| All years (future) | Ramakumar formula + SS Moon | ~100% Sringeri-equivalent |

**Next session goal**: Implement `amrita_start = nkStartTime + (X/24) × nkDuration` with
SS Moon nakshatra times → validate against 2025-26/2026-27 lookup table → if match within
5 min for >90% of dates, replace formula fallback with this for all years.

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
| Sun position | ~0.001° | VSOP87 |
| Moon position | ~0.01° | Meeus Ch. 47 full series |
| Sunrise | ~30 sec | Standard refraction model |
| Tithi end | ~1–2 min | Limited by Moon accuracy |
| Nakshatra end | ~1–2 min | Lahiri Ayanamsa dependent |
| Yoga end | ~1–2 min | Lahiri Ayanamsa dependent |
| Rahu/Gulika/Yama | ~1–2 min | Limited by sunrise accuracy |
| Amrit Kalam (lookup) | ~0 min | Exact Sringeri times |
| Amrit Kalam (formula) | ±100 min | ~15% within 15 min |
| Lunar eclipse contact | ~2–3 min | Shadow geometry (Meeus) |
| Solar eclipse contact | ~5–10 min | Geocentric geometry |
