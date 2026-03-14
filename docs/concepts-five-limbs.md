# Panchangam Concepts — Foundation & Five Limbs (Part 1)

Tithi and Vara. For Nakshatra, Yoga, Karana → [concepts-nakshatra-yoga-karana.md](concepts-nakshatra-yoga-karana.md)

**Index of all concepts files:**
- This file: Foundation + Tithi + Vara
- [concepts-nakshatra-yoga-karana.md](concepts-nakshatra-yoga-karana.md): Nakshatra + Yoga + Karana
- [concepts-timings.md](concepts-timings.md): Daily Timings (Sunrise, Kalams, Muhurthas, Amrit)
- [concepts-calendar-eclipse.md](concepts-calendar-eclipse.md): Calendar Context + Eclipses + Special Yogas + Events
- [concepts-festivals.md](concepts-festivals.md): Festivals + Calculation Libraries + City Coordinates

---

## Primary Sources
- *Panchangam Calculations* — archive.org/details/PanchangamCalculations
- *Astronomical Algorithms* — Jean Meeus, 2nd ed.
- Sringeri Suvarnamukhya Panchangam (ground truth for Amrita Kalam, eclipse times)

Panchangam (పంచాంగం) = "Pancha" (five) + "Anga" (limb).
Five elements calculated for every single day, specific to a geographic location.

---

## Astronomical Foundation

All Panchangam calculations are based on:
- **Positions of the Sun and Moon** (primary drivers)
- **Geographic location** (latitude + longitude) — affects sunrise, moonrise, Kalam timings
- **Time zone** — IST (UTC+5:30) for India
- **Ayanamsa** — the correction angle between tropical (Western) and sidereal (Hindu) zodiac

### Ayanamsa (అయనాంశ)
Western astronomy measures positions from the Spring Equinox (tropical).
Hindu astronomy measures from a fixed star background (sidereal).
The difference = **Ayanamsa** (~23.5° currently, increasing ~50 arc-seconds/year).

```
Sidereal longitude = Tropical longitude − Ayanamsa
```

Most Panchangam software uses **Lahiri Ayanamsa** (official, govt of India standard).

---

## THE FIVE LIMBS (పంచాంగ అంగాలు)

---

### 1. TITHI (తిథి) — Lunar Day

A Tithi is defined by the angular separation between the Moon and the Sun.
Every 12° of separation = 1 Tithi. One lunar month = 30 Tithis = 360°.

```
Tithi number = floor((Moon longitude − Sun longitude) mod 360 / 12) + 1
```

A Tithi ranges from ~19 to ~26 hours (Moon varies in speed with distance from Earth).

**The 30 Tithis — Shukla Paksha (Waxing)**
| # | Telugu | Sanskrit | Lord |
|---|--------|----------|------|
| 1 | పాడ్యమి | Pratipada | Agni |
| 2 | విదియ | Dwitiya | Brahma |
| 3 | తదియ | Tritiya | Gauri |
| 4 | చవితి | Chaturthi | Ganesha |
| 5 | పంచమి | Panchami | Saraswati / Naga |
| 6 | షష్ఠి | Shashthi | Karttikeya |
| 7 | సప్తమి | Saptami | Surya |
| 8 | అష్టమి | Ashtami | Shiva |
| 9 | నవమి | Navami | Durga |
| 10 | దశమి | Dashami | Yama |
| 11 | ఏకాదశి | Ekadashi | Vishnu (fasting day) |
| 12 | ద్వాదశి | Dwadashi | Vishnu |
| 13 | త్రయోదశి | Trayodashi | Kamadeva |
| 14 | చతుర్దశి | Chaturdashi | Shiva |
| 15 | పౌర్ణమి | Purnima | Chandra |

**Krishna Paksha (Waning)**: same names 1–14, then 15 = అమావాస్య (Amavasya, New Moon).

**Key Tithis**: Ekadashi (11) = Vaishnava fasting; Amavasya = ancestor rituals; Purnima = major festivals.

---

### 2. VARA (వారం) — Day of the Week

Vara starts at sunrise (not midnight) in the Panchangam system.

| # | Telugu | English | Planet | Deity |
|---|--------|---------|--------|-------|
| 1 | ఆదివారం | Sunday | Surya | Surya |
| 2 | సోమవారం | Monday | Chandra | Shiva |
| 3 | మంగళవారం | Tuesday | Mangala | Hanuman |
| 4 | బుధవారం | Wednesday | Budha | Vishnu |
| 5 | గురువారం | Thursday | Guru (Jupiter) | Vishnu |
| 6 | శుక్రవారం | Friday | Shukra (Venus) | Lakshmi |
| 7 | శనివారం | Saturday | Shani (Saturn) | Shani |

```
Day of week = (Julian Day Number + 1) mod 7   // 0=Sunday
```

---
