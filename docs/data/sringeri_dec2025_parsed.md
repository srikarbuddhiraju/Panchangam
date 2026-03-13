# Sringeri Panchangam — December 2025 Parsed Amruthakalam

**Source:** sringeri_dec2025_raw.md
**Conversion:** G.VV → G×24 + VV×0.4 = minutes from sunrise (Di/She/tē) or sunset (Ra)
**Status:** 17 entries extracted (day 09 missing from OCR), all are NEW cells (no conflicts)

---

## Parsed Entries

| Day | Date | Vara (int) | Nakshatra | Row | Type | G.V | Minutes | Table action |
|-----|------|-----------|-----------|-----|------|-----|---------|--------------|
| 01 | Dec 1 | Mon=1 | Revati | 27 | Di | 27.29 | +660 | NEW — [27][1] |
| 02 | Dec 2 | Tue=2 | Ashwini | 1 | Di | 12.43 | +305 | NEW — [1][2] |
| 03 | Dec 3 | Wed=3 | Bharani | 2 | Di | 14.29 | +348 | NEW — [2][3] |
| 04 | Dec 4 | Thu=4 | Krittika | 3 | Di | 15.58 | +383 | NEW — [3][4] |
| 05 | Dec 5 | Fri=5 | Rohini | 4 | Di+Ra | 9.56 / 25.5 | +238 / −602 | NEW — [4][5]=+238 (Di stored; Ra also present) |
| 06 | Dec 6 | Sat=6 | Mrigashirsha | 5 | Ra | 18.36 | −446 | NEW — [5][6] |
| 07 | Dec 7 | Sun=0 | Ardra | 6 | None | — | 0 | NEW — [6][0]=0 (confirmed అమృతఘటికాభావః) |
| 08 | Dec 8 | Mon=1 | Punarvasu | 7 | Di+Ra | 1.14 / 21.39 | +30 / −520 | NEW — [7][1]=+30 (Di stored; Ra also present) |
| **09** | **Dec 9** | **Tue=2** | **Pushya** | **8** | **?** | **?** | **?** | **MISSING — needs manual check** |
| 10 | Dec 10 | Wed=3 | Ashlesha | 9 | tē+Ra† | 3.3 / 29.49 | +73† / −716 | NEW — [9][3]=+73† (tē.amṛta†; Ra also present) |
| 11 | Dec 11 | Thu=4 | Magha | 10 | She+Ra | 1.32 / 20.36 | +37 / −494 | NEW — [10][4]=+37 (She stored; Ra also present) |
| 12 | Dec 12 | Fri=5 | PurvaPhalguni | 11 | Ra | 20.37 | −495 | NEW — [11][5] |
| 13 | Dec 13 | Sat=6 | UttaraPhalguni | 12 | Ra | 27.2 | −649 | NEW — [12][6] |
| 14 | Dec 14 | Sun=0 | Hasta | 13 | Ra | 30.5 | −722 | NEW — [13][0] |
| 15 | Dec 15 | Mon=1 | Chitra | 14 | She+Ra | 2.23 / 29.16 | +57 / −702 | NEW — [14][1]=+57 (She stored; Ra also present) |
| 16 | Dec 16 | Tue=2 | Swati | 15 | She | 1.17 | +31 | NEW — [15][2] |
| 17 | Dec 17 | Wed=3 | Vishaka | 16 | Di | 2.58 | +71 | NEW — [16][3] |
| 18 | Dec 18 | Thu=4 | Anuradha | 17 | Di | 4.58 | +119 | NEW — [17][4] |

---

## Conversion notes

- `tē.amṛta` (తే.అమృత, day 10): "తే" = తెల్లవారు (dawn) — interpreted as She/Di type (early morning, offset from sunrise). Marked † pending clarification.
- `She.amṛta` (శే.అమృత): residual morning window, stored as +minutes from sunrise same as Di.
- Days with both Di/She and Ra: architecture allows only one window. Di/She stored, Ra noted here for future upgrade.
- Rounding: use `round()` on the floating-point result.

---

## Conflicts

None — all 17 entries are new cells in the 27×7 table.
