# Surya Siddhanta and Sringeri Panchangam Calculations: Complete Implementation Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Sringeri Panchangam Basis](#sringeri-panchangam-basis)
3. [Surya Siddhanta Astronomical Framework](#surya-siddhanta-astronomical-framework)
4. [Time Base: Mahayuga and Ahargana](#time-base-mahayuga-and-ahargana)
5. [Mean Longitudes Computation](#mean-longitudes-computation)
6. [True Longitudes: Manda and Sighra Corrections](#true-longitudes-manda-and-sighra-corrections)
7. [Nirayana Frame and Ayanamsa](#nirayana-frame-and-ayanamsa)
8. [Five Limbs of Panchanga: Formulas](#five-limbs-of-panchanga-formulas)
9. [Vakya vs Drik Panchanga](#vakya-vs-drik-panchanga)
10. [Step-by-Step Implementation Blueprint](#step-by-step-implementation-blueprint)
11. [Important Considerations and Limitations](#important-considerations-and-limitations)
12. [References and Sources](#references-and-sources)

---

## Introduction

This document provides an explicit, implementation-ready guide to calculating a traditional **Surya Siddhanta-based (vakya) panchanga** as used by institutions like **Sringeri Sharada Peetham**. It covers:

- The underlying astronomical model from Surya Siddhanta
- Mathematical formulas for ahargana, mean longitudes, and true longitudes
- Exact geometric rules for deriving vara, tithi, nakshatra, yoga, and karana
- Practical considerations for implementation

Traditional South Indian panchangas published by Sringeri and similar institutions are based on **Surya Siddhanta** rather than modern observational (drik) methods. This guide explains how to reproduce those calculations.

---

## Sringeri Panchangam Basis

### What Sringeri Uses

Multiple independent sources confirm that **Sringeri Sharada Peetham** publishes **Surya Siddhanta-based (vakya) panchangams** in regional languages:

- The Sringeri Kannada panchanga is explicitly described by traditional practitioners as a "Surya Siddhanta panchanga" with a separate drik-gaṇita section for detailed jyotiṣa calculations
- Hindu Blog distributes the "Sringeri Telugu Surya Siddhanta Panchangam" for 2025–2026
- Traditional guidance: Use vakya/Surya Siddhanta panchanga for dharmaśāstra observances (vratas, nitya karmas) and drik panchanga for high-precision astronomical work

### Key Principle

**For ritual observances (ekadashi, amavasya, etc.), Sringeri follows Surya Siddhanta computational methods, NOT modern numerical ephemerides.**

---

## Surya Siddhanta Astronomical Framework

### Core Concept

Surya Siddhanta works with:

1. A **Mahayuga** of 4,320,000 sidereal years
2. Fixed integer **revolution counts** for each celestial body in one Mahayuga
3. A **sidereal (nirayana) zodiac** where 0° Aries is fixed to stellar positions
4. **Epicycle corrections** (manda and sighra) to refine mean positions into true positions
5. **Ahargana** (days elapsed since epoch) as the fundamental time variable

### Workflow Overview

```
Civil Date
    ↓
Ahargana (days since Kali epoch)
    ↓
Mean Longitudes (from Mahayuga revolutions)
    ↓
Manda Correction (equation of centre)
    ↓
Sighra Correction (for planets)
    ↓
True Nirayana Longitudes (Sun, Moon, planets)
    ↓
Five Panchanga Limbs (vara, tithi, nakshatra, yoga, karana)
```

---

## Time Base: Mahayuga and Ahargana

### Mahayuga Constants

Surya Siddhanta defines a **Mahayuga** as:

- **Duration**: 4,320,000 sidereal years
- **Civil days**: 1,577,917,828 savana (civil) days (modern recension)
  - Older Varāhamihira version: 1,577,917,800 days

At the start and end of a Mahayuga, all celestial bodies conjunct at **0° sidereal Aries**.

### Mahayuga Revolution Counts

| Body | Revolutions per Mahayuga |
|------|--------------------------|
| Sun | 4,320,000 |
| Moon | 57,753,336 |
| Mars | 2,296,832 |
| Jupiter | 364,220 |
| Saturn | 146,568 |
| Venus | 7,022,376 |
| Mercury | 17,937,060 |
| Moon's Apogee | 448,203 |
| Moon's Node | 232,238 |

These are from the "modern" Surya Siddhanta recension (Burgess-Gangooly translation).

### Ahargana Definition

**Ahargana (A)** = Total number of civil (savana) days elapsed from a fixed epoch to the desired date.

**Standard epoch**: Beginning of **Kali Yuga**
- Date: Midnight preceding 18 February 3102 BCE (Julian calendar)
- Ahargana at this moment: 0 (by convention)

### Ahargana Calculation Steps

```
1. Choose epoch date and its ahargana value (e.g., Kali epoch = 0)
2. Convert target civil date to Julian Day Number (JDN)
3. Convert epoch date to Julian Day Number (JDN_epoch)
4. Ahargana = JDN - JDN_epoch
```

**Example**:
```python
# Pseudocode
def compute_ahargana(gregorian_date):
    JDN_target = gregorian_to_julian_day(gregorian_date)
    JDN_kali_epoch = gregorian_to_julian_day(-3101, 2, 18)  # Kali epoch
    ahargana = JDN_target - JDN_kali_epoch
    return ahargana
```

### Julian Day Number Conversion

Use standard astronomical formulas (e.g., Meeus algorithm) or library functions to convert Gregorian/Julian dates to JDN.

---

## Mean Longitudes Computation

### Mean Daily Motion Formula

For any celestial body with:
- **R** = revolutions per Mahayuga
- **D** = total civil days per Mahayuga (1,577,917,828)

Mean daily motion **m** in degrees per day:

\[
m = 360 \times \frac{R}{D}
\]

**Example for Sun**:
\[
m_{\text{Sun}} = 360 \times \frac{4{,}320{,}000}{1{,}577{,}917{,}828} \approx 0.985647°/\text{day}
\]

This corresponds to a sidereal year of approximately 365.256 days.

### Mean Longitude at Ahargana A

Given:
- **L₀** = mean longitude at epoch (usually 0° for Mahayuga/Kali start)
- **A** = ahargana (days since epoch)
- **m** = mean daily motion

Mean longitude **L̄**:

\[
\bar{L} = (L_0 + m \times A) \bmod 360°
\]

**Explicit calculation**:
```python
def mean_longitude(revolutions, mahayuga_days, ahargana, epoch_longitude=0):
    """
    Calculate mean longitude for a celestial body.
    
    Args:
        revolutions: Revolutions per Mahayuga for the body
        mahayuga_days: Total civil days per Mahayuga (1577917828)
        ahargana: Days elapsed since epoch
        epoch_longitude: Longitude at epoch (default 0)
    
    Returns:
        Mean longitude in degrees (0-360)
    """
    mean_daily_motion = 360.0 * revolutions / mahayuga_days
    mean_longitude = (epoch_longitude + mean_daily_motion * ahargana) % 360.0
    return mean_longitude
```

### Mean Longitudes for All Bodies

```python
# Constants from Surya Siddhanta
MAHAYUGA_DAYS = 1_577_917_828
REVOLUTIONS = {
    'sun': 4_320_000,
    'moon': 57_753_336,
    'mars': 2_296_832,
    'jupiter': 364_220,
    'saturn': 146_568,
    'venus': 7_022_376,
    'mercury': 17_937_060,
    'moon_apogee': 448_203,
    'moon_node': 232_238
}

def compute_mean_longitudes(ahargana):
    """Compute mean longitudes for all bodies at given ahargana."""
    longitudes = {}
    for body, revs in REVOLUTIONS.items():
        longitudes[body] = mean_longitude(revs, MAHAYUGA_DAYS, ahargana)
    return longitudes
```

---

## True Longitudes: Manda and Sighra Corrections

Surya Siddhanta refines mean longitudes using **epicycle models** to account for orbital eccentricity and relative motion.

### Surya Siddhanta Sine Table (Jya)

Surya Siddhanta uses a **24-entry sine table** with radius **3438 arcminutes**.

**Properties**:
- Covers 0° to 90° (one quadrant)
- First sine = 225′ (corresponding to 3°45′)
- Successive sines computed by recursive rule

**Sine table values** (in arcminutes, radius 3438):

| Index | Angle | Sine (arcmin) |
|-------|-------|---------------|
| 1 | 3°45′ | 225 |
| 2 | 7°30′ | 449 |
| 3 | 11°15′ | 671 |
| 4 | 15° | 890 |
| 5 | 18°45′ | 1105 |
| 6 | 22°30′ | 1315 |
| 7 | 26°15′ | 1520 |
| 8 | 30° | 1719 |
| ... | ... | ... |
| 24 | 90° | 3438 |

For implementation, you can either:
1. Use these tabulated values with linear interpolation, OR
2. Use modern `sin()` function scaled to match the 3438 radius

**Modern approximation**:
```python
def surya_siddhanta_sine(angle_degrees):
    """
    Compute Surya Siddhanta sine (jya) for given angle.
    Returns value in arcminutes with radius 3438.
    """
    import math
    radius = 3438  # arcminutes
    return radius * math.sin(math.radians(angle_degrees))
```

### Epicycle Radii (Manda and Sighra)

Surya Siddhanta specifies epicycle radii for each body. **Example values** (approximate, from comparative studies):

| Body | Manda Epicycle Radius |
|------|-----------------------|
| Sun | 13°40′ (≈ 13.67°) |
| Moon | 31°40′ (≈ 31.67°) |
| Mars | ~70° |
| Mercury | ~29° |

(Exact values vary by recension; consult Burgess translation for precise constants.)

### Manda Correction (Equation of Centre)

**Purpose**: Account for elliptical orbit (eccentricity effect).

**Steps**:

1. **Compute mean anomaly**:
   \[
   M = (\bar{L} - a) \bmod 360°
   \]
   where:
   - **L̄** = mean longitude of body
   - **a** = longitude of apsis (mandocca/apogee)

2. **Compute sine of anomaly** using Surya Siddhanta sine table:
   \[
   S = \sin(M) \times 3438
   \]

3. **Compute equation of centre**:
   \[
   \Delta_m = \arcsin\left(\frac{P°}{360°} \times \frac{S}{3438}\right)
   \]
   where **P°** = manda epicycle radius in degrees.

4. **Apply correction**:
   \[
   L' = \bar{L} \pm \Delta_m
   \]
   
   **Sign rule**:
   - **Negative (−)**: From apogee to perigee (anomaly 0° to 180°)
   - **Positive (+)**: From perigee to apogee (anomaly 180° to 360°)

**Implementation**:
```python
import math

def manda_correction(mean_longitude, apsis_longitude, epicycle_radius):
    """
    Apply manda (equation of centre) correction.
    
    Args:
        mean_longitude: Mean longitude in degrees
        apsis_longitude: Longitude of apsis (mandocca) in degrees
        epicycle_radius: Manda epicycle radius in degrees
    
    Returns:
        True longitude after manda correction
    """
    # Mean anomaly
    mean_anomaly = (mean_longitude - apsis_longitude) % 360.0
    
    # Sine of anomaly (using modern sin, scaled to match Surya Siddhanta)
    sin_M = math.sin(math.radians(mean_anomaly))
    
    # Equation of centre (in degrees)
    # Original uses epicycle ratio; approximate via small-angle formula
    equation_of_centre = epicycle_radius * sin_M
    
    # Determine sign: negative from apogee to perigee (0-180°), positive otherwise
    if 0 <= mean_anomaly <= 180:
        sign = -1
    else:
        sign = +1
    
    true_longitude = (mean_longitude + sign * equation_of_centre) % 360.0
    return true_longitude
```

### Sighra Correction (for Planets)

**Purpose**: Account for Earth's motion relative to planet (heliocentric-to-geocentric conversion in epicycle form).

**Applied to**: Mars, Jupiter, Saturn, Venus, Mercury (NOT Sun or Moon)

**Steps**:

1. **Compute sighra anomaly**:
   - **Superior planets** (Mars, Jupiter, Saturn):
     \[
     S_{\text{anom}} = (\text{Sun's mean longitude} - L') \bmod 360°
     \]
   - **Inferior planets** (Venus, Mercury):
     \[
     S_{\text{anom}} = (L' - \text{sighrocca longitude}) \bmod 360°
     \]
   (Sighrocca is an auxiliary point moving with solar speed for inferior planets)

2. **Compute sine of sighra anomaly** using sine table

3. **Compute sighra equation**:
   \[
   \Delta_s = \arcsin\left(\frac{Q°}{360°} \times \sin(S_{\text{anom}})\right)
   \]
   where **Q°** = sighra epicycle radius

4. **Apply correction**:
   \[
   L = L' \pm \Delta_s
   \]
   (Sign conventions differ for superior vs inferior planets; see Surya Siddhanta text)

**Note**: For panchanga purposes, you primarily need **Sun and Moon true longitudes**. Planetary sighra corrections are included here for completeness but are not required for the five limbs.

### Summary of Correction Process

```
Mean Longitude (L̄)
    ↓
Apply Manda Correction
    ↓
Manda-Corrected Longitude (L')
    ↓
Apply Sighra Correction (planets only)
    ↓
True Longitude (L)
```

**For Sun and Moon**:
- Only manda correction applies (no sighra)
- Use their respective epicycle radii

**For Planets**:
- Apply both manda and sighra corrections sequentially

---

## Nirayana Frame and Ayanamsa

### Sidereal vs Tropical Zodiac

**Surya Siddhanta uses a sidereal (nirayana) zodiac**:
- 0° Aries is fixed relative to stellar positions
- The vernal equinox is allowed to oscillate (trepidation model), NOT linearly precess
- This differs fundamentally from:
  - Modern tropical zodiac (0° Aries = vernal equinox point)
  - Modern linear-precession models (Lahiri ayanamsa)

### Ayanamsa in Surya Siddhanta Context

**Key point**: Surya Siddhanta's sidereal zero is **inherent to its model**. When computing longitudes via Surya Siddhanta formulas, you are already in the Surya Siddhanta nirayana frame—no additional ayanamsa subtraction is needed.

**If using external ephemerides** (e.g., Swiss Ephemeris tropical positions):
1. Compute tropical longitudes from modern ephemeris
2. Subtract a **Surya Siddhanta-style ayanamsa** (NOT Lahiri) to convert to nirayana
3. This ayanamsa must account for Surya Siddhanta's trepidation model

**For pure Surya Siddhanta implementation**:
- Compute longitudes directly via Surya Siddhanta formulas (mean + corrections)
- These are already nirayana by construction
- No ayanamsa adjustment required

### Surya Siddhanta vs Lahiri Ayanamsa

| Aspect | Surya Siddhanta | Lahiri (Modern) |
|--------|-----------------|-----------------|
| Precession model | Trepidation (oscillating) | Linear precession |
| Zero point | Fixed stellar reference | Derived from Spica |
| Current ayanamsa (2026) | ~22°–23° (varies by interpretation) | ~24°11′ |
| Usage | Traditional panchangas | Government panchanga, modern astrology |

**Important**: Mixing Surya Siddhanta longitudes with Lahiri ayanamsa creates inconsistencies. Choose one system and stick to it.

---

## Five Limbs of Panchanga: Formulas

Once you have **true nirayana longitudes** of Sun (λₛ) and Moon (λₘ), the five panchanga limbs follow from pure geometric rules.

### Required Angles

Define:
- **λₛ** = Sun's true sidereal longitude (0°–360°)
- **λₘ** = Moon's true sidereal longitude (0°–360°)
- **θ** = (λₘ − λₛ) mod 360° = elongation (Moon ahead of Sun)
- **σ** = (λₛ + λₘ) mod 360° = sum of longitudes

---

### 1. Vara (Weekday)

**Definition**: Civil weekday, reckoned from sunrise to next sunrise.

**Formula**:
\[
\text{Vara} = (A + C) \bmod 7
\]

where:
- **A** = ahargana
- **C** = constant offset to align epoch with known weekday

**Weekday mapping** (Sunday = 0):

| Index | Vara |
|-------|------|
| 0 | Sunday (Ravivara) |
| 1 | Monday (Somavara) |
| 2 | Tuesday (Mangalavara) |
| 3 | Wednesday (Budhavara) |
| 4 | Thursday (Guruvara) |
| 5 | Friday (Shukravara) |
| 6 | Saturday (Shanivara) |

**Implementation**:
```python
def compute_vara(ahargana, epoch_weekday=5):
    """
    Compute vara (weekday) from ahargana.
    
    Args:
        ahargana: Days since epoch
        epoch_weekday: Weekday of epoch (default 5 = Friday for Kali epoch)
    
    Returns:
        Weekday index (0=Sunday, 1=Monday, ..., 6=Saturday)
    """
    vara_index = (ahargana + epoch_weekday) % 7
    return vara_index

VARA_NAMES = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 
              'Thursday', 'Friday', 'Saturday']
```

---

### 2. Tithi (Lunar Day)

**Definition**: One tithi = 12° of elongation between Moon and Sun. There are 30 tithis per lunar month.

**Formula**:
\[
\text{Tithi index} = \left\lfloor \frac{\theta}{12°} \right\rfloor + 1
\]

where θ = (λₘ − λₛ) mod 360°

**Tithi numbering** (1–30):
- Shukla paksha (bright fortnight): Pratipad (1) to Purnima (15)
- Krishna paksha (dark fortnight): Pratipad (16) to Amavasya (30)

**Implementation**:
```python
def compute_tithi(moon_longitude, sun_longitude):
    """
    Compute tithi from Moon and Sun longitudes.
    
    Args:
        moon_longitude: Moon's true nirayana longitude (degrees)
        sun_longitude: Sun's true nirayana longitude (degrees)
    
    Returns:
        Tithi index (1-30)
    """
    elongation = (moon_longitude - sun_longitude) % 360.0
    tithi_index = int(elongation / 12.0) + 1
    return tithi_index

# Tithi names
TITHI_NAMES = [
    'Pratipad', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima',
    'Pratipad', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Amavasya'
]

def tithi_name(tithi_index):
    """Get name of tithi with paksha."""
    paksha = 'Shukla' if tithi_index <= 15 else 'Krishna'
    name = TITHI_NAMES[tithi_index - 1]
    return f"{paksha} {name}"
```

**Fractional progress**:
```python
def tithi_fraction(moon_longitude, sun_longitude):
    """Return fractional progress through current tithi (0.0 to 1.0)."""
    elongation = (moon_longitude - sun_longitude) % 360.0
    return (elongation % 12.0) / 12.0
```

---

### 3. Nakshatra (Lunar Mansion)

**Definition**: The ecliptic is divided into 27 equal segments of 13°20′ (= 800 arcminutes) each.

**Formula**:
\[
\text{Nakshatra index} = \left\lfloor \frac{\lambda_m}{13°20'} \right\rfloor + 1 = \left\lfloor \frac{\lambda_m \times 60}{800} \right\rfloor + 1
\]

**Implementation**:
```python
def compute_nakshatra(moon_longitude):
    """
    Compute nakshatra from Moon's longitude.
    
    Args:
        moon_longitude: Moon's true nirayana longitude (degrees)
    
    Returns:
        Nakshatra index (1-27)
    """
    # Convert to arcminutes and divide by 800
    arcminutes = moon_longitude * 60.0
    nakshatra_index = int(arcminutes / 800.0) + 1
    return nakshatra_index

# Nakshatra names (27)
NAKSHATRA_NAMES = [
    'Ashvini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Svati', 'Vishakha',
    'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha',
    'Shravana', 'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada',
    'Uttara Bhadrapada', 'Revati'
]
```

**Pada (quarter) calculation**:
```python
def nakshatra_pada(moon_longitude):
    """Return pada (1-4) within current nakshatra."""
    arcminutes = moon_longitude * 60.0
    remainder = arcminutes % 800.0
    pada = int(remainder / 200.0) + 1
    return pada
```

---

### 4. Yoga

**Definition**: 27 equal segments of 13°20′ based on the **sum** of Sun and Moon longitudes.

**Formula**:
\[
\text{Yoga index} = \left\lfloor \frac{\sigma}{13°20'} \right\rfloor + 1 = \left\lfloor \frac{\sigma \times 60}{800} \right\rfloor + 1
\]

where σ = (λₛ + λₘ) mod 360°

**Implementation**:
```python
def compute_yoga(moon_longitude, sun_longitude):
    """
    Compute yoga from Moon and Sun longitudes.
    
    Args:
        moon_longitude: Moon's true nirayana longitude (degrees)
        sun_longitude: Sun's true nirayana longitude (degrees)
    
    Returns:
        Yoga index (1-27)
    """
    longitude_sum = (moon_longitude + sun_longitude) % 360.0
    arcminutes = longitude_sum * 60.0
    yoga_index = int(arcminutes / 800.0) + 1
    return yoga_index

# Yoga names (27)
YOGA_NAMES = [
    'Vishkambha', 'Priti', 'Ayushman', 'Saubhagya', 'Shobhana',
    'Atiganda', 'Sukarma', 'Dhriti', 'Shula', 'Ganda',
    'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
    'Siddhi', 'Vyatipata', 'Variyan', 'Parigha', 'Shiva',
    'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma',
    'Indra', 'Vaidhriti'
]
```

---

### 5. Karana

**Definition**: Half of a tithi (6° of elongation). There are 11 named karanas in a repeating pattern.

**Formula**:
\[
\text{Karana index} = \left\lfloor \frac{\theta}{6°} \right\rfloor + 1
\]

where θ = (λₘ − λₛ) mod 360°

**Karana sequence** (60 half-tithis per lunar month):
- Fixed karanas (4): Shakuni, Chatushpada, Naga, Kimstughna
- Movable karanas (7, repeating): Bava, Balava, Kaulava, Taitila, Gara, Vanija, Vishti

**Implementation**:
```python
def compute_karana(moon_longitude, sun_longitude):
    """
    Compute karana from Moon and Sun longitudes.
    
    Args:
        moon_longitude: Moon's true nirayana longitude (degrees)
        sun_longitude: Sun's true nirayana longitude (degrees)
    
    Returns:
        Karana name
    """
    elongation = (moon_longitude - sun_longitude) % 360.0
    karana_index = int(elongation / 6.0)  # 0-59
    
    # Karana sequence mapping
    # First half-tithi (Shukla Pratipad 1st half): Kimstughna
    # Last two half-tithis (Amavasya): Shakuni, Chatushpada
    # Remaining 57: 8 cycles of 7 movable karanas + 1 extra
    
    if karana_index == 0:
        return 'Kimstughna'
    elif karana_index >= 58:
        return ['Shakuni', 'Chatushpada'][karana_index - 58]
    else:
        # Movable karanas cycle
        movable_karanas = ['Bava', 'Balava', 'Kaulava', 'Taitila', 
                           'Gara', 'Vanija', 'Vishti (Bhadra)']
        return movable_karanas[(karana_index - 1) % 7]
```

---

### Summary Table: Five Limbs Formulas

| Limb | Depends On | Formula | Range |
|------|------------|---------|-------|
| **Vara** | Ahargana | (A + C) mod 7 | 0–6 (Sun–Sat) |
| **Tithi** | θ = λₘ − λₛ | ⌊θ / 12°⌋ + 1 | 1–30 |
| **Nakshatra** | λₘ | ⌊λₘ / 13°20′⌋ + 1 | 1–27 |
| **Yoga** | σ = λₘ + λₛ | ⌊σ / 13°20′⌋ + 1 | 1–27 |
| **Karana** | θ = λₘ − λₛ | ⌊θ / 6°⌋ + 1 (with special mapping) | 11 named types |

---

## Vakya vs Drik Panchanga

### Key Differences

| Aspect | Vakya / Surya Siddhanta | Drik (Modern) |
|--------|------------------------|---------------|
| **Basis** | Surya Siddhanta formulas + vakya tables | NASA JPL / Swiss Ephemeris |
| **Longitude type** | Mean + epicycle corrections | True observational positions |
| **Ayanamsa** | Built-in sidereal frame (trepidation) | Lahiri or other linear precession |
| **Accuracy** | Accumulates ~1° error over centuries | Matches observations to arcsecond |
| **Usage** | Traditional dharmaśāstra observances | Government panchanga, astrology |
| **Computation** | Simpler, hand-calculable | Requires numerical integration |
| **Regional variants** | Tamil vakya, Kerala vakya, etc. | Uniform modern standard |

### When to Use Which

**Use Vakya / Surya Siddhanta when**:
- Following traditional ritual calendar (Sringeri, other mathas)
- Computing vratas, ekadashis, festival dates for dharmic practice
- Replicating historical panchangas
- Maintaining continuity with traditional lineage

**Use Drik when**:
- Need high astronomical accuracy for eclipse timing, planetary positions
- Preparing astrological charts requiring precision
- Official government panchanga compliance
- Scientific astronomical work

**Sringeri approach**: Publish Surya Siddhanta panchanga as primary, with drik supplement for jyotiṣa practitioners.

---

## Step-by-Step Implementation Blueprint

### Complete Workflow

```
Input: Civil date (e.g., 2026-03-15)
    ↓
Step 1: Compute Ahargana
    ↓
Step 2: Compute Mean Longitudes (Sun, Moon, planets)
    ↓
Step 3: Apply Manda Corrections
    ↓
Step 4: Apply Sighra Corrections (planets only)
    ↓
Step 5: Determine Local Sunrise Time
    ↓
Step 6: Compute λₛ, λₘ at Sunrise
    ↓
Step 7: Derive Five Panchanga Limbs
    ↓
Step 8: Compute End Times (optional)
    ↓
Output: Vara, Tithi, Nakshatra, Yoga, Karana + end times
```

---

### Step 1: Initialize Constants

```python
# Mahayuga constants
MAHAYUGA_DAYS = 1_577_917_828
KALI_EPOCH_JDN = 588465.5  # JDN of Kali epoch (18 Feb 3102 BCE, midnight)

# Revolutions per Mahayuga
REVOLUTIONS = {
    'sun': 4_320_000,
    'moon': 57_753_336,
    'moon_apogee': 448_203,
}

# Epicycle radii (degrees)
MANDA_EPICYCLES = {
    'sun': 13.67,   # ~13°40′
    'moon': 31.67,  # ~31°40′
}

# Apsis longitudes at epoch (example values, adjust per recension)
APSIS_LONGITUDES = {
    'sun': 78.0,    # Sun's aphelion
    'moon': 0.0,    # Moon's apogee (varies, compute dynamically)
}
```

---

### Step 2: Compute Ahargana

```python
def gregorian_to_jdn(year, month, day):
    """
    Convert Gregorian date to Julian Day Number.
    Uses standard Meeus algorithm.
    """
    a = (14 - month) // 12
    y = year + 4800 - a
    m = month + 12 * a - 3
    
    jdn = day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045
    return jdn

def compute_ahargana(year, month, day):
    """Compute ahargana from Gregorian date."""
    jdn = gregorian_to_jdn(year, month, day)
    ahargana = jdn - KALI_EPOCH_JDN
    return int(ahargana)
```

---

### Step 3: Compute Mean Longitudes

```python
def compute_mean_longitudes(ahargana):
    """Compute mean longitudes for Sun and Moon."""
    longitudes = {}
    
    for body in ['sun', 'moon', 'moon_apogee']:
        revs = REVOLUTIONS[body]
        mean_daily_motion = 360.0 * revs / MAHAYUGA_DAYS
        mean_longitude = (mean_daily_motion * ahargana) % 360.0
        longitudes[body] = mean_longitude
    
    return longitudes
```

---

### Step 4: Apply Manda Corrections

```python
import math

def apply_manda_correction(mean_long, apsis_long, epicycle_radius):
    """
    Apply manda (equation of centre) correction.
    
    Returns true longitude after manda correction.
    """
    # Mean anomaly
    mean_anomaly = (mean_long - apsis_long) % 360.0
    
    # Equation of centre (simplified using sine)
    sin_M = math.sin(math.radians(mean_anomaly))
    equation = epicycle_radius * sin_M
    
    # Sign: negative from apogee to perigee (0-180°)
    if 0 <= mean_anomaly <= 180:
        sign = -1
    else:
        sign = +1
    
    true_longitude = (mean_long + sign * equation) % 360.0
    return true_longitude

def compute_true_longitudes(mean_longitudes):
    """Apply manda corrections to get true longitudes."""
    true_long = {}
    
    # Sun
    true_long['sun'] = apply_manda_correction(
        mean_longitudes['sun'],
        APSIS_LONGITUDES['sun'],
        MANDA_EPICYCLES['sun']
    )
    
    # Moon (using dynamically computed apogee)
    true_long['moon'] = apply_manda_correction(
        mean_longitudes['moon'],
        mean_longitudes['moon_apogee'],  # Moon's apogee is moving
        MANDA_EPICYCLES['moon']
    )
    
    return true_long
```

---

### Step 5: Compute Local Sunrise

For panchanga, you need **local sunrise time** at your reference location.

**Simple approximation** (for precise timing, use astronomical libraries):

```python
def compute_sunrise_time(latitude, longitude, date):
    """
    Compute approximate sunrise time for given location and date.
    
    Args:
        latitude: Latitude in degrees (positive = North)
        longitude: Longitude in degrees (positive = East)
        date: Date tuple (year, month, day)
    
    Returns:
        Sunrise hour (decimal, 0-24)
    """
    # Use a library like ephem, pytz, or astronomical algorithms
    # This is a placeholder
    import ephem
    
    observer = ephem.Observer()
    observer.lat = str(latitude)
    observer.lon = str(longitude)
    observer.date = ephem.Date(date)
    
    sunrise = observer.next_rising(ephem.Sun())
    sunrise_hour = float(sunrise) % 1.0 * 24.0  # Convert to hour of day
    
    return sunrise_hour
```

For **Sringeri** (Karnataka):
- Latitude: ~13.42° N
- Longitude: ~75.25° E

---

### Step 6: Compute Longitudes at Sunrise

Since longitudes change throughout the day, interpolate between midnight and noon values:

```python
def longitudes_at_time(ahargana, time_fraction):
    """
    Compute Sun/Moon longitudes at fractional day.
    
    Args:
        ahargana: Ahargana at midnight
        time_fraction: Fraction of day (0.0 = midnight, 0.5 = noon, 1.0 = next midnight)
    
    Returns:
        dict with 'sun' and 'moon' true longitudes
    """
    ahargana_precise = ahargana + time_fraction
    
    mean_longs = compute_mean_longitudes(ahargana_precise)
    true_longs = compute_true_longitudes(mean_longs)
    
    return true_longs

def panchanga_at_sunrise(date, latitude, longitude):
    """
    Compute panchanga elements at local sunrise.
    
    Args:
        date: (year, month, day)
        latitude, longitude: Observer location
    
    Returns:
        dict with panchanga elements
    """
    year, month, day = date
    ahargana = compute_ahargana(year, month, day)
    
    # Compute sunrise time (as fraction of day)
    sunrise_hour = compute_sunrise_time(latitude, longitude, date)
    sunrise_fraction = sunrise_hour / 24.0
    
    # Compute longitudes at sunrise
    longs = longitudes_at_time(ahargana, sunrise_fraction)
    sun_long = longs['sun']
    moon_long = longs['moon']
    
    # Compute five limbs
    panchanga = {
        'vara': compute_vara(ahargana),
        'tithi': compute_tithi(moon_long, sun_long),
        'nakshatra': compute_nakshatra(moon_long),
        'yoga': compute_yoga(moon_long, sun_long),
        'karana': compute_karana(moon_long, sun_long),
        'sun_longitude': sun_long,
        'moon_longitude': moon_long,
        'sunrise_hour': sunrise_hour
    }
    
    return panchanga
```

---

### Step 7: Compute End Times (Advanced)

To find when tithi/yoga/nakshatra end during the day:

```python
def find_tithi_end(ahargana, tithi_start, sunrise_fraction):
    """
    Find time when current tithi ends.
    
    Args:
        ahargana: Ahargana at midnight
        tithi_start: Starting tithi index (1-30)
        sunrise_fraction: Sunrise time as fraction of day
    
    Returns:
        End time as hour of day (or None if tithi doesn't end today)
    """
    target_elongation = tithi_start * 12.0  # Target angle
    
    # Search from sunrise forward in small steps
    for time_frac in np.arange(sunrise_fraction, sunrise_fraction + 1.0, 0.01):
        longs = longitudes_at_time(ahargana, time_frac)
        elongation = (longs['moon'] - longs['sun']) % 360.0
        
        if elongation >= target_elongation:
            return time_frac * 24.0  # Convert to hour
    
    return None  # Tithi extends to next day
```

---

### Step 8: Complete Example

```python
def compute_panchanga(year, month, day, latitude=13.42, longitude=75.25):
    """
    Complete panchanga computation for a given date at Sringeri.
    
    Args:
        year, month, day: Gregorian date
        latitude, longitude: Location (default = Sringeri)
    
    Returns:
        Dictionary with all panchanga elements
    """
    date = (year, month, day)
    panchanga = panchanga_at_sunrise(date, latitude, longitude)
    
    # Add human-readable names
    panchanga['vara_name'] = VARA_NAMES[panchanga['vara']]
    panchanga['tithi_name'] = tithi_name(panchanga['tithi'])
    panchanga['nakshatra_name'] = NAKSHATRA_NAMES[panchanga['nakshatra'] - 1]
    panchanga['yoga_name'] = YOGA_NAMES[panchanga['yoga'] - 1]
    panchanga['karana_name'] = panchanga['karana']  # Already a string
    
    return panchanga

# Example usage
if __name__ == '__main__':
    # Compute panchanga for March 15, 2026
    result = compute_panchanga(2026, 3, 15)
    
    print("Panchanga for March 15, 2026 (Sringeri)")
    print(f"Vara: {result['vara_name']}")
    print(f"Tithi: {result['tithi_name']}")
    print(f"Nakshatra: {result['nakshatra_name']}")
    print(f"Yoga: {result['yoga_name']}")
    print(f"Karana: {result['karana_name']}")
    print(f"Sunrise: {result['sunrise_hour']:.2f} hours")
    print(f"Sun longitude: {result['sun_longitude']:.2f}°")
    print(f"Moon longitude: {result['moon_longitude']:.2f}°")
```

---

## Important Considerations and Limitations

### 1. Recensional Differences

**Issue**: Different versions of Surya Siddhanta have slightly different constants.

**Solution**:
- Choose one authoritative source (e.g., Burgess-Gangooly translation)
- Document which version you're using
- Use consistent constants throughout

### 2. Accumulated Positional Error

**Issue**: Surya Siddhanta's mean motions and epicycle corrections deviate from modern observations by ~1° over centuries.

**Impact**:
- Tithi/nakshatra boundaries may differ from drik panchanga by several hours
- Eclipses cannot be accurately predicted with Surya Siddhanta alone
- For dates far from present era, errors compound

**Mitigation**:
- Acceptable for traditional dharmic observances (Sringeri approach)
- Cross-reference with drik for astronomical accuracy needs

### 3. Ayanamsa Consistency

**Issue**: Surya Siddhanta's sidereal frame differs from Lahiri and other modern ayanamsas.

**Solution**:
- If using Surya Siddhanta formulas → no ayanamsa adjustment needed
- If mixing with modern ephemerides → use Surya Siddhanta-compatible ayanamsa
- Never mix Surya Siddhanta longitudes with Lahiri ayanamsa

### 4. Vakya Tables vs Direct Computation

**Issue**: Traditional vakya panchangas use precomputed verse tables rather than computing from first principles every time.

**Sringeri approach**: Likely uses vakya tables derived from Surya Siddhanta, not direct computation daily.

**For implementation**:
- Direct computation (as shown here) is more transparent
- Vakya tables would require obtaining specific regional vakya texts
- Results should match within small margins

### 5. Regional Variations

Different regions use slight variations:
- **Tamil Nadu**: Tamil vakya tradition with specific corrections
- **Kerala**: Kollam era, different epoch handling
- **Karnataka**: Sringeri follows Surya Siddhanta with regional longitude

**Solution**: Fix reference longitude (e.g., Sringeri at 75.25°E) and compute for that location.

### 6. Sunrise Definition

**Traditional**: Sunrise is when Sun's disc touches horizon.
**Modern**: Upper limb or center crossing horizon.

**For panchanga**: Use traditional definition (first light touching horizon), or be consistent with your astronomical library's definition.

### 7. Kshaya and Adhika Tithis

**Kshaya tithi**: Skipped tithi (two tithis end between sunrises)
**Adhika tithi**: Repeated tithi (one tithi spans two sunrises)

**For dharmaśāstra**: Need additional rules (from texts like Dharmasindhu) to determine which tithi to observe for vratas.

**Implementation**: Compare tithi at today's sunrise vs tomorrow's sunrise to detect kshaya/adhika.

### 8. Testing and Validation

**Validate against**:
- Published Sringeri panchangas (if available)
- Other traditional Surya Siddhanta panchangas
- Historical almanac data

**Expected differences from drik**:
- Tithi boundaries: ±2–6 hours typical
- Nakshatra boundaries: ±1–3 hours typical
- Vara: Should match exactly (weekday is unambiguous)

---

## References and Sources

### Primary Texts

1. **Surya Siddhanta** (Burgess-Gangooly English translation)
   - Available: Internet Archive
   - Complete Sanskrit text with English translation
   - Mathematical chapters (1-4, 13-14) contain all formulas

2. **Panchasiddhantika** by Varāhamihira
   - Contains earlier version of Surya Siddhanta constants
   - Historical comparison valuable

### Academic Studies

3. **Bag, A.K. (2001)** - "Ahargana and Weekdays as per Modern Suryasiddhanta"
   - Repository: Indian Academy of Sciences
   - Details epoch calculations and weekday formulas

4. **Reingold & Dershowitz** - "Indian Calendrical Calculations"
   - Paper: Available online (reingold.co)
   - Comparative study of Hindu calendar algorithms

### Implementation Resources

5. **Drik Panchang** (drikpanchang.com)
   - Modern reference for comparison
   - Explains drik vs vakya differences

6. **VedicDateTime R Package** (CRAN)
   - Open-source implementation
   - Useful for algorithm verification

### Traditional Sources

7. **Sringeri Sharada Peetham** official panchangas
   - Website: sringeri.net
   - Annual panchangas in Kannada, Tamil, Telugu
   - Check "Peethika" (introduction) for stated basis

8. **Dharmasindhu** and similar dharmaśāstra texts
   - Rules for kshaya/adhika tithis
   - Festival date determination

### Technical Notes

9. **Telugupanchang.com** - Mathematical methods article
   - Compares vakya vs drik approaches
   - Regional variations documented

10. **Astrobix.com** - Calculation of a Panchanga
    - Step-by-step tutorial
    - Useful for cross-validation

---

## Appendix: Quick Reference Tables

### Mahayuga Constants

| Parameter | Value |
|-----------|-------|
| Mahayuga years | 4,320,000 |
| Mahayuga civil days | 1,577,917,828 |
| Sun revolutions | 4,320,000 |
| Moon revolutions | 57,753,336 |
| Moon apogee revolutions | 448,203 |

### Angular Divisions

| Element | Angular width | Count per cycle |
|---------|--------------|-----------------|
| Tithi | 12° | 30 per month |
| Nakshatra | 13°20′ (800′) | 27 per zodiac |
| Yoga | 13°20′ (800′) | 27 per zodiac |
| Karana | 6° | 60 per month (11 types) |
| Rashi (sign) | 30° | 12 per zodiac |

### Epochal Reference

| Epoch | Date (Julian) | JDN | Ahargana |
|-------|---------------|-----|----------|
| Kali Yuga start | 18 Feb 3102 BCE | 588465.5 | 0 |
| Vikrama Samvat | 58 BCE | ~1720994 | ~1132529 |
| Saka Era | 78 CE | ~1770995 | ~1182530 |

### Typical Epicycle Radii (Surya Siddhanta)

| Body | Manda Radius |
|------|--------------|
| Sun | ~13°40′ |
| Moon | ~31°40′ |
| Mars | ~70° |
| Mercury | ~29° |
| Jupiter | ~33° |
| Venus | ~12° |
| Saturn | ~49° |

---

## Conclusion

This document provides a complete, explicit guide to implementing a **Surya Siddhanta-based panchanga** following the traditional methods used by institutions like **Sringeri Sharada Peetham**.

Key points:

1. **Ahargana** from Kali epoch is the fundamental time variable
2. **Mean longitudes** derived from Mahayuga revolution counts
3. **Manda and sighra corrections** applied via sine tables and epicycle geometry
4. **Five limbs** computed from simple angular rules once true Sun/Moon longitudes known
5. **Nirayana frame** built into Surya Siddhanta; no separate ayanamsa needed
6. **Sunrise** is the key temporal anchor for determining daily panchanga

For **actual production use**, consider:
- Testing against published Sringeri panchangas
- Obtaining exact vakya tables if available
- Implementing dharmaśāstra rules for kshaya/adhika handling
- Using robust astronomical libraries for sunrise calculations

This framework provides the mathematical foundation; regional traditions may have additional conventions that should be documented and incorporated as needed.