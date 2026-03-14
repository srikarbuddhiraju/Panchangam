# Panchangam App — Calculation Methods (Core Elements)

How the app computes each Panchangam element, why each algorithm was chosen.

**Special calculations** (Amrit Kalam, Eclipse, Samvatsara) → [calculation-methods-special.md](calculation-methods-special.md)

**Primary references:**
- Karanam Ramakumar, *Panchangam Calculations* — archive.org/details/PanchangamCalculations
- Jean Meeus, *Astronomical Algorithms* 2nd ed.
- drik-panchanga (Python reference impl): github.com/webresh/drik-panchanga
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

Upgraded from Meeus Ch. 25 (~0.01°) to Ch. 27 VSOP87 (~0.001°) to fix Adhika Masa
detection — the difference matters when a solar month is borderline.

**Ayanamsa**: Lahiri (official GoI standard).

---

## Lunar Position (Moon)

**Algorithm**: Meeus Ch. 47 (ELP2000-82 truncated series)
**Accuracy**: ~0.01° longitude, ~0.001° latitude
**File**: `app/lib/core/calculations/lunar_position.dart`

Moon longitude corrections include all major periodic terms from Meeus Table 47.A/47.B,
plus latitude corrections from 47.2 (all six terms — missing terms caused bugs in session 12).

**Note on Surya Siddhanta Moon**: Sringeri Panchangam is titled "Surya Siddhanta" but
empirically uses Drik (Meeus) Moon — verified by matching 111/116 nakshatra labels.
We use Drik Moon. (See lessons_amrita.md for details.)

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

Nakshatra ending time **is Ayanamsa-dependent**.

---

## Yoga

```dart
yogaNum = ((sunLon + moonLon) % 360 / 13.3333).floor() + 1
```

Ending time: same formula as Nakshatra but using (Sun+Moon) combined motion (~14°/day combined DMC).
Yoga ending time is also Ayanamsa-dependent.

---

## Karana

```dart
// Each Tithi has 2 Karanas (first/second half)
tithiSeq = tithi × 2 − (isFirstHalf ? 1 : 0)
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
Yama:    3   6   2   5   1   4   7   // Sat=7 = P6 (position 6), verified session 8
```

---

## Abhijit Muhurtham

```dart
solarNoon    = (sunrise + sunset) / 2
abhijitStart = solarNoon − 12min
abhijitEnd   = solarNoon + 12min
// Exception: not auspicious on Wednesday
```
