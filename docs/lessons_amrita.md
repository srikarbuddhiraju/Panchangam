# Claude Lessons — Amrita Kalam & OCR

Specific to amrita kalam calibration work and Sarvam OCR processing.
Read this only when working on amrita lookup, formula validation, or OCR ingestion.

**General lessons** → [lessons.md](lessons.md)

---

## Amrita Kalam Calibration (Sessions 18–24)

### Sringeri uses Drik Moon, not Surya Siddhanta Moon
- **Mistake**: Session 18 concluded Sringeri uses SS Moon because PDF title says "Surya Siddhanta Panchangam"
- **Correction**: SS Moon is ~25° behind Drik Moon. Sringeri's nakshatra labels match Drik Moon in ~111/116 entries. SS Moon matches only ~5/120.
- **Rule**: "Surya Siddhanta Panchangam" = *tradition*, not the ephemeris. Always verify empirically against published nakshatra labels.

### Lahiri vs True Chitra Paksha — difference is negligible for amrit kalam
- **Finding**: True Chitra Paksha = Mean Lahiri + nutation term (±17.2" × sin(Ω)) = ±0.5 min of amrita time. Completely negligible.
- **Sweep result (Sessions 18–22)**: Lahiri (0°) is the MINIMUM mean error (123.6 min). Any other offset makes accuracy worse.
- **Root cause of ~121 min mean error**: NOT ayanamsha. NOT Moon model. Unknown internal calibration in Sringeri's software (likely Astro-Vision). Cannot be closed without reverse-engineering.
- **Rule**: Do NOT chase ayanamsha changes to improve amrit accuracy.

### SuryaSiddhantaMoon.siderealLongitude() is ~25° off — do NOT use for amrit bisection
- **Mistake (Session 22)**: Swapped `LunarPosition` for `SuryaSiddhantaMoon` in `_bisectLon()`. Accuracy collapsed from 40% to 8% within 30 min.
- **Root cause**: SS Moon applies Lahiri ayanamsha on top of SS tropical longitude — double conversion → ~25° position error.
- **Rule**: Never substitute SS Moon for Drik Moon in the bisection without first verifying positions match known nakshatra labels (run validate_ss_moon.dart first).

### Amrit Kalam formula ceiling — use lookup-only, no formula fallback
- **Finding (Sessions 18–23, 464 validated data points)**: Best formula (Ramakumar X table + Drik Moon) has mean error ~131 min. Only 23% within 30 min.
- **Root cause**: Amrita fraction within a nakshatra varies day-to-day due to additional inputs (tithi, vara, proprietary corrections) not in the public domain.
- **Decision**: `amritKalam()` returns null outside lookup range. No formula fallback shown to users.
- **Update path**: OCR each new annual Sringeri edition → extend `amrita_lookup.dart`.
- **Rule**: Do NOT re-introduce a formula fallback without validated accuracy ≤30 min on 90%+ of dates.

### Ramakumar NK-selection rule: 1h threshold at sunrise
- **Source**: Karanam Ramakumar, *Panchangam Calculations*
- **Rule**: Use the NEXT nakshatra if the sunrise nakshatra ends within 60 minutes of sunrise.
- **Bug**: Was always using the nakshatra AT sunrise, even if it ended in 5 minutes.
- **Fix**: In `_amritKalamRamakumar()`, check `nkExit.difference(sunrise).inMinutes < 60` and advance if true.

### Fixed Moon-longitude fraction is the wrong formula for Amrit Kalam
- **Mistake**: Used `amrita when Moon.lon = nkStart + frac × nkSpan` (fixed longitude fraction within nakshatra)
- **Why wrong**: Moon speed varies (perigee vs apogee). Same angular fraction = different time offset depending on speed.
- **Correct formula** (Karanam Ramakumar): `amrita_start = nkStartTime + (X/24) × nkDuration`
  where X = per-nakshatra constant, nkDuration = nakshatra duration in hours
- **Rule**: For any timing derived from nakshatra, use time-from-entry, not longitude-fraction.

---

## Sarvam OCR API (Session 13)

### API v2 format (verified working)
- Header: `api-subscription-key: <key>` (NOT `Authorization: Bearer`)
- Create job: `{"job_parameters": {"language": "te-IN", "output_format": "md"}}`
- Upload files: `{"job_id": "...", "files": ["page.pdf"]}` (strings, not objects)
- Upload URL: `upload_resp['upload_urls']['page.pdf']['file_url']`
- Download URL: `list(dl_resp['download_urls'].values())[0]['file_url']`
- Rate limit: 429 after ~3 concurrent requests — run sequentially with 10s inter-page delay + 60s backoff retry

### PDF Page Offsets (Sringeri Panchangams)
- **2025-26**: `pdf_page = printed_page + 2` (PDF 69 = printed 67, April 2025 Chaitra)
- **2026-27**: `pdf_page = printed_page + 3` (PDF 58 = printed 55, March 2026 Ugadi)
- Always confirm offset from first page content before running batch

### Panchangam Format Differences
- **2025-26**: per-day HTML table, `ది.అమృత <frac> <period>॥<H>.<MM>మొ॥`
- **2026-27**: bi-weekly compact, `అ:<period>.<H>.<MM>-<period>.<H>.<MM>`, Gregorian date in col 2

### Telugu Period-to-24h Conversion (CRITICAL)
- ఉ॥ (udayam/morning): keep as-is (5-12 AM)
- ప॥ (pagalu/daytime): h 1-6 → +12 (PM), h 7-11 → keep (AM morning)
- సా॥ (saayam/evening): h < 12 → +12 (17-20 PM)
- రా॥ (raatri/night): h=12 → 0 (midnight!), h 7-11 → +12 (19-23), h 0-6 → keep (early AM)
- తె॥ (pre-dawn): keep as-is
