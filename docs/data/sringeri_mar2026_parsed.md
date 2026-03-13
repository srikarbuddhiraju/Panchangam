# Sringeri Panchangam — March 2026 Parsed Amruthakalam

**Source:** sringeri_mar2026_raw.md
**Conversion:** G.VV → G×24 + VV×0.4 = minutes from sunrise (Di/She) or sunset (Ra)
**Status:** 19 entries (Feb 27–Mar 19); days 1–8 conflict with Feb data; days 10–19 are all NEW cells

---

## Parsed Entries

| Day | Date | Vara (int) | Nakshatra | Row | Type | G.V | Minutes | Table action |
|-----|------|-----------|-----------|-----|------|-----|---------|--------------|
| 27 | Feb 27 | Fri=5 | Ardra | 6 | None | — | 0 | CONFIRMS existing [6][5]=0 |
| 28 | Feb 28 | Sat=6 | Punarvasu | 7 | Di+Ra | 1.55 / 20.55 | +46 / −502 | CONFLICT — existing [7][6]=47; +46 vs +47 (rounding diff, treat as same) |
| 01 | Mar 1 | Sun=0 | Pushya | 8 | Ra | 29.52 | −717 | CONFLICT — existing [8][0]=−123 (Feb01 Ra5.8) |
| 02 | Mar 2 | Mon=1 | Ashlesha | 9 | She | 2.58 | +71 | CONFLICT — existing [9][1]=−258 (Feb02 Ra10.46) |
| 03 | Mar 3 | Tue=2 | Magha | 10 | She | 0.12 | +5 | CONFLICT — existing [10][2]=−194 (Feb03 Ra8.5) |
| 04 | Mar 4 | Wed=3 | PurvaPhalguni | 11 | Ra | 16.11 | −388 | CONFLICT — existing [11][3]=626 (Feb04 Di26.6) |
| 05 | Mar 5 | Thu=4 | UttaraPhalguni | 12 | Ra | 21.2 | −505 | CONFLICT — existing [12][4]=648 (Feb05 Di26.59) |
| 06 | Mar 6 | Fri=5 | Hasta | 13 | Ra | 25.17 | −607 | CONFLICT — existing [13][5]=−90 (Feb06 Ra3.75†) |
| 07 | Mar 7 | Sat=6 | Chitra | 14 | None? | — | 0? | CONFLICT — existing [14][6]=−153 (Feb07 Ra6.23). Day 07 shows no amrita in OCR. |
| 08 | Mar 8 | Sun=0 | Swati | 15 | Ra | 28.5 | −674 | CONFLICT — existing [15][0]=−116 (Feb08 Ra4.50) |
| **09** | **Mar 9** | **Mon=1** | **Vishaka** | **16** | **?** | **?** | **?** | **MISSING from OCR** — existing [16][1]=−254 (‡) |
| 10 | Mar 10 | Tue=2 | Anuradha | 17 | She | 3.51 | +92 | NEW — [17][2] |
| 11 | Mar 11 | Wed=3 | Jyeshtha | 18 | Di | 10.20 | +248 | NEW — [18][3] |
| 12 | Mar 12 | Thu=4 | Mula | 19 | Di | 23.21 | +560 | NEW — [19][4] |
| 13 | Mar 13 | Fri=5 | PurvaAshadha | 20 | Ra | 3.58 | −95 | NEW — [20][5] |
| 14 | Mar 14 | Sat=6 | UttaraAshadha | 21 | Ra | 4.20 | −104 | NEW — [21][6] |
| 15 | Mar 15 | Sun=0 | Shravana | 22 | Di | 27.19 | +656 | NEW — [22][0] |
| 16 | Mar 16 | Mon=1 | Dhanishtha | 23 | Ra | 0.19 | −8 | NEW — [23][1] |
| 17 | Mar 17 | Tue=2 | Shatabhisha | 24 | Ra | 9.4 | −218 | NEW — [24][2] |
| 18 | Mar 18 | Wed=3 | PurvaBhadra | 25 | Ra | 8.4 | −194 | NEW — [25][3] |
| 19 | Mar 19 | Thu=4 | UttaraBhadra | 26 | Ra | 14.56 | −358 | NEW — [26][4] |

---

## Conflict analysis (days 01–08, nakshatras 8–15)

Same nakshatra+vara cell gives different values in Feb vs March. Root cause: the nakshatra's position relative to sunrise/sunset shifts monthly, so the amrita hora changes. This reveals the 27×7 fixed-offset table is fundamentally incorrect for the amrita calculation. Correct approach: traditional nakshatra→hora table (per ConvoQAClaude.md Q4).

**Action**: Mark all 8 conflict cells with ‡ in muhurtha.dart. Do NOT overwrite Feb entries with March values.

---

## New entries ready for muhurtha.dart (days 10–19, no conflicts)

10 new cells: [17][2]=+92, [18][3]=+248, [19][4]=+560, [20][5]=−95, [21][6]=−104, [22][0]=+656, [23][1]=−8, [24][2]=−218, [25][3]=−194, [26][4]=−358
