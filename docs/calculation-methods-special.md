# Panchangam App — Calculation Methods (Special & Timing)

Amrit Kalam, Eclipse detection, Samvatsara, Telugu Month, and accuracy summary.

**Core element methods** (Tithi, Nakshatra, etc.) → [calculation-methods.md](calculation-methods.md)

---

## Amrit Kalam

**Implementation**: Sringeri Panchangam lookup table only. No formula fallback.
**File**: `app/lib/core/data/amrita_lookup.dart` + `app/lib/core/calculations/muhurtha.dart`

### Why lookup-only (no formula)?

We exhaustively tested all known formula approaches across 464 validated data points (Sessions 18–23):

| Formula approach | Mean error | Within 30 min |
|---|---|---|
| Ramakumar (Drik Moon, X table) | **131 min** | 23% |
| Empirically calibrated X values | **166 min** | 19% |
| Surya Siddhanta Moon variants | **400+ min** | <8% |
| Ayanamsha sweep ±2° from Lahiri | **>130 min** | <25% |

Root cause: Sringeri's amrita fraction varies significantly day-to-day — additional inputs
(likely tithi, vara, proprietary corrections) are not in the public domain.
Showing ~2h-off formula results would mislead users.

### Lookup table

- Source: OCR of Sringeri Suvarnamukhya Panchangam, 2025-26 and 2026-27 editions
- Coverage: Mar 2025 – Apr 2027 (~464 entries, ~100% accurate vs published times)
- All times stored for **Kondavidu (80.5°E)**; deshantar correction applied per user location
- Outside coverage: `amritKalam()` returns null → UI shows "Data not available for this date"
- Update path: OCR each new Sringeri annual edition, extend `amrita_lookup.dart`

### Deshantar correction

From Sringeri Panchangam p.66:
```dart
correctionMinutes = ((userLon − 80.5) × 4).round()
amritStart = tableTime.add(Duration(minutes: correctionMinutes))
```
Verified: Bengaluru (77.6°E) correction = −12 min ✓

### Ramakumar X table (archived — not used in production)

Source: Karanam Ramakumar, *Panchangam Calculations* p.26+
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
| Sun position | ~0.001° | VSOP87 |
| Moon position | ~0.01° | Meeus Ch. 47 full series |
| Sunrise/Sunset | ~30 sec | Standard refraction model |
| Tithi | ~1–2 min | Limited by Moon position |
| Nakshatra | ~1–2 min | Lahiri Ayanamsa, matches Sringeri 85%+ |
| Yoga | ~1–2 min | Ayanamsa dependent |
| Karana | ~1–2 min | Derived from tithi |
| Vara (weekday) | Exact | Calendar arithmetic |
| Rahu/Gulika/Yamaganda | ~1–2 min | Standard table; limited by sunrise |
| Abhijit Muhurtham | ~1–2 min | Solar noon formula |
| Dur Muhurta | ~1–2 min | Standard weekday table |
| **Amrit Kalam (2025–2027)** | **~0 min** | **Exact Sringeri published times** |
| **Amrit Kalam (other years)** | **Not shown** | **No accurate formula exists** |
| Lunar eclipse contact | ~2–3 min | Shadow geometry (Meeus) |
| Solar eclipse contact | ~5–10 min | Geocentric geometry |
| Festival dates | ~0 days | Derived from accurate tithi/nakshatra |

**Summary**: All five Panchangam limbs, Kalam timings, festival dates, and eclipse timings
are computed from first-principles astronomy and are accurate for any year.
Amrit Kalam is the sole exception — shown only when exact Sringeri data is available
(currently Mar 2025–Apr 2027), blank outside that window.
