# Sringeri Panchangam Feb 2026 — Parsed Amrita Entries

**Source**: Sarvam AI OCR (te-IN) of PDF pages 110–113 (printed) / pypdf 109–112
**Month**: Māgha + Phalguna overlap, Visvavasu Samvatsara
**Location**: Hyderabad (lat=17.385, lng=78.487) for offset computation
**Extracted**: Session 12, Mar 6 2026

Offset convention: `+N` = Di (minutes after sunrise), `-N` = Ra (minutes after sunset, sign flipped)

---

## Jan 29 – Feb 17 (from pages 110–111 printed, Sarvam OCR pages 1–2)

| Date    | Vara | Nakshatra (nk#) | Type | IST Time | Offset |
|---------|------|-----------------|------|----------|--------|
| Jan 29  | Thu  | Mrigashirsha (5) | Ra  | 20:03    | -113   |
| Jan 30  | Fri  | Ardra (6)        | Di  | 17:23    | +634   |
| Jan 31  | Sat  | Punarvasu (7)    | Ra  | 23:12    | -301   |
| Feb 01  | Sun  | Pushyami (8)     | Ra  | 18:20    | -8     |
| Feb 02  | Mon  | Ashlesha (9)     | Ra  | 22:16    | -244   |
| Feb 03  | Tue  | Magha (10)       | Ra  | 21:12    | -179   |
| Feb 04  | Wed  | PvPhalguni (11)  | Di  | 17:21    | +633   |
| Feb 05  | Thu  | UtPhalguni (12)  | Di  | 17:05    | +618   |
| Feb 06  | Fri  | Hasta (13)       | Ra  | 19:25    | -71    |
| Feb 07  | Sat  | Chitra (14)      | Ra  | 20:33    | -138   |
| Feb 08  | Sun  | Swati (15)       | Ra  | 19:56    | -101   |
| Feb 09  | Mon  | Vishaka (16)     | Ra  | 22:14    | -238   |
| Feb 10  | Tue  | Vishaka (16)     | Ra  | 23:01    | -285   |
| Feb 11  | Wed  | Anuradha (17)    | Ra  | 03:23+1  | -546   |
| Feb 12  | Thu  | Jyeshtha (18)    | —   | —        | NO AMRITA (అమృతఘటికాభావ) |
| Feb 13  | Fri  | Mula (19)        | Di  | 08:30    | +106   |
| Feb 14  | Sat  | PvAshadha (20)   | Di  | 12:28    | +344   |
| Feb 15  | Sun  | UtAshadha (21)   | Di  | 12:35    | +352   |
| Feb 16  | Mon  | Shravana (22)    | Di  | 09:46    | +183   |
| Feb 17  | Tue  | Dhanishtha (23)  | Di  | 10:49    | +247   |

## Feb 18 – Feb 28 (from pages 111–112 printed, Sarvam OCR pages 1–2 of second batch)

| Date    | Vara | Nakshatra (nk#)    | Type | IST Time   | Offset |
|---------|------|--------------------|------|------------|--------|
| Feb 18  | Wed  | Shatabhisha (24)   | Di   | 14:31      | +469   |
| Feb 19  | Thu  | PvBhadrapada (25)  | Di   | 13:39      | +418   |
| Feb 20  | Fri  | UtBhadrapada (26)  | Di   | 16:19      | +579   |
| Feb 21  | Sat  | Revati (27)        | Di   | 17:43      | +663   |
| Feb 22  | Sun  | Ashwini (1)        | Di   | 11:56      | +317   |
| Feb 23  | Mon  | Bharani (2)        | Di   | 12:47      | +368   |
| Feb 24  | Tue  | Krittika (3)       | Di   | 13:27      | +409   |
| Feb 25  | Wed  | Rohini (4)         | Di   | 11:02      | +265   |
| Feb 25  | Wed  | Rohini (4)         | Ra   | 04:10+1    | -588   |
| Feb 26  | Thu  | Mrigashirsha (5)   | Ra   | 01:28+1    | -426   |
| Feb 27  | Fri  | Ardra (6)          | —    | —          | NO AMRITA (అమృతఘటికాభావ) |
| Feb 28  | Sat  | Punarvasu (7)      | Di   | 07:13      | +38    |
| Feb 28  | Sat  | Punarvasu (7)      | Ra   | 02:17+1    | -474   |

---

## Notes

- **Feb 12 & Feb 27**: `అమృతఘటికాభావ` = no amrita that day
- **Feb 25 & Feb 28**: Both Di and Ra amrita exist; formula returns Di (first) only
- **Feb 21 Revati**: Di at 17:43 = 663 min from sunrise — very late in day, near sunset
- **Feb 18 Shatabhisha**: First confirmed data point for nk=24 (previously null in _amritFrac)
- Nakshatra numbers are from Dart `Nakshatra.number(jdSunrise)` — may differ slightly from Sringeri near boundaries
