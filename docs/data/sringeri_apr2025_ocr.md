# Sringeri Panchangam — April 2025 OCR Data
Source: Sringeri PDF printed pages 67, 68, 69, 71
Location: Bengaluru (12.9716°N, 77.5946°E)
Extracted: Session 17, Mar 7 2026

## Format
- `Di`: ది.అమృత — daytime amrita, offset = minutes after sunrise
- `Ra`: రా.అమృత — nighttime amrita, offset = -(minutes after sunset)
- `SKIP`: అమృతఘటికాభావ — no amrita
- `?`: time read from image but uncertain

## Our Computed Nakshatras at Sunrise (Bengaluru)
(from bin/compute_feb_offsets.dart — may differ from Sringeri by 1 nakshatra on boundary days)
```
Apr 01 Tue  NK2  Bharani           SR=06:15 SS=18:31
Apr 02 Wed  NK3  Krittika          SR=06:14 SS=18:31
Apr 03 Thu  NK4  Rohini            SR=06:14 SS=18:31
Apr 04 Fri  NK6  Ardra             SR=06:13 SS=18:31  ← Sringeri=NK5 Mrigashirsha
Apr 05 Sat  NK7  Punarvasu         SR=06:12 SS=18:31
Apr 06 Sun  NK8  Pushya            SR=06:12 SS=18:31  ← Sringeri=NK7 Punarvasu
Apr 07 Mon  NK8  Pushya            SR=06:11 SS=18:31
Apr 08 Tue  NK9  Ashlesha          SR=06:11 SS=18:31
Apr 09 Wed  NK10 Magha             SR=06:10 SS=18:31
Apr 10 Thu  NK11 PurvaPhalguni     SR=06:09 SS=18:31
Apr 11 Fri  NK12 UttaraPhalguni    SR=06:09 SS=18:31
Apr 12 Sat  NK13 Hasta             SR=06:08 SS=18:32
Apr 13 Sun  NK14 Chitra            SR=06:08 SS=18:32
Apr 14 Mon  NK15 Swati             SR=06:07 SS=18:32
Apr 15 Tue  NK16 Vishakha          SR=06:06 SS=18:32
Apr 16 Wed  NK17 Anuradha          SR=06:06 SS=18:32
Apr 17 Thu  NK18 Jyeshtha          SR=06:05 SS=18:32
Apr 18 Fri  NK18 Jyeshtha          SR=06:05 SS=18:32
Apr 19 Sat  NK19 Mula              SR=06:04 SS=18:32
Apr 20 Sun  NK20 PurvaAshadha      SR=06:04 SS=18:32
Apr 21 Mon  NK21 UttaraAshadha     SR=06:03 SS=18:33
Apr 22 Tue  NK22 Shravana          SR=06:02 SS=18:33
Apr 23 Wed  NK23 Dhanishtha        SR=06:02 SS=18:33
Apr 24 Thu  NK24 Shatabhisha       SR=06:01 SS=18:33
Apr 25 Fri  NK25 PurvaBhadrapada   SR=06:01 SS=18:33
Apr 26 Sat  NK26 UttaraBhadrapada  SR=06:00 SS=18:33
Apr 27 Sun  NK1  Ashwini           SR=06:00 SS=18:33
Apr 28 Mon  NK2  Bharani           SR=06:00 SS=18:34
Apr 29 Tue  NK3  Krittika          SR=05:59 SS=18:34
Apr 30 Wed  NK4  Rohini            SR=05:59 SS=18:34
```

## Extracted Amrita Times (from OCR of pages 67-71)

### Page 67 (entries 1-7):
| Date | Vara | Sringeri NK | Amrita | IST Time | Offset |
|------|------|-------------|--------|----------|--------|
| Apr 01 | Tue | NK2 Bharani | Di | ప10:41 = 10:41 AM | +266 min |
| Apr 02 | Wed | NK3 Krittika | Di | ప11:20 = 11:20 AM | +306 min |
| Apr 03 | Thu | NK4 Rohini | Di | ఉ9:10 = 9:10 AM | +176 min |
| Apr 03 | Thu | NK5 Mrgshr | Ra | రా2:39 = 2:39 AM (Apr4) | -482 min |
| Apr 04 | Fri | NK5 Mrgshr* | Ra | రా12:33 = 0:33 AM | -362 min |
| Apr 05 | Sat | NK7 Punarvasu | SKIP | అమృతఘటికాభావ | — |
| Apr 06 | Sun | NK7 Punarvasu* | Di | ఉ7:23 = 7:23 AM | +71 min |
| Apr 06 | Sun | NK8 Pushya | Ra | రా3:21 = 3:21 AM (Apr7) | -525 min |
| Apr 07 | Mon | NK8 Pushya | SKIP | అమృతఘటికాభావ | — |

*Sringeri nakshatra differs from our computed value (boundary day)

### Page 68 (entries 8-18):
| Date | Vara | Sringeri NK | Amrita | IST Time | Offset |
|------|------|-------------|--------|----------|--------|
| Apr 08 | Tue | NK9 Ashlesha | Di | ఉ8:35 = 8:35 AM | +144 min |
| Apr 09 | Wed | NK10 Magha | Di | ఉ8:42 = 8:42 AM | +152 min |
| Apr 09 | Wed | NK10 Magha | Ra | తె5:53 = 5:53 AM (Apr10) | -677 min |
| Apr 10 | Thu | NK11 PvPhg | ? | శే.అమృత ఉ7:34వా (END=7:34AM) — skip | — |
| Apr 11 | Fri | NK12 UtPhg | Di | ఉ6:49 = 6:49 AM | +40 min |
| Apr 12 | Sat | NK13 Hasta | Di | ప10:18 = 10:18 AM | +250 min |
| Apr 13 | Sun | NK14 Chitra | Di | ప12:19 = 12:19 PM | +371 min |
| Apr 14 | Mon | NK15 Swati | Di | ప12:15 = 12:15 PM | +368 min |
| Apr 15 | Tue | NK16 Vishakha | Di | ప2:49 = 14:49 PM | +523 min |
| Apr 16 | Wed | NK17 Anuradha | ? | ఉ5:27 AM pre-sunrise — uncertain | — |
| Apr 17 | Thu | NK18 Jyeshtha | Ra | రా7:18 = 19:18 PM? — verify | ? |
| Apr 18 | Fri | NK18 Jyeshtha | Ra | రా11:32 = 23:32? — verify | ? |

### Page 69 (entries 19-27):
| Date | Vara | Sringeri NK | Amrita | IST Time | Offset |
|------|------|-------------|--------|----------|--------|
| Apr 19 | Sat | NK19 Mula | Ra | రా2:20 = 2:20 AM (Apr20) | ? |
| Apr 20 | Sun | NK20 PvAsh | Ra | రా1:19 = 1:19 AM (Apr21) | ? |
| Apr 21 | Mon | NK21 UtAsh | Ra | రా9:28 = 21:28 PM | ? |
| Apr 22 | Tue | NK22 Shravana | Ra | రా9:14 = 21:14 PM | ? |
| Apr 23 | Wed | NK23 Dhanishtha | Ra | రా11:42 = 23:42 PM | ? |
| Apr 24 | Thu | NK24 Shatabhisha | Ra | రా9:55 = 21:55 PM | ? |
| Apr 25 | Fri | NK25 PvBhd | Ra | రా11:37 = 23:37 PM | ? |
| Apr 26 | Sat | NK26 UtBhd | Ra | రా12:19 = 0:19 AM (Apr27) | ? |
| Apr 27 | Sun | NK1 Ashwini | Di | సా6:13 = 18:13 PM | ? |

### Page 71 (entries 28-30):
| Date | Vara | Sringeri NK | Amrita | IST Time | Offset |
|------|------|-------------|--------|----------|--------|
| Apr 28 | Mon | NK2 Bharani | Ra | సా6:46 = 18:46 PM | ? |
| Apr 29 | Tue | NK3 Krittika | Ra | రా7:24 = 19:24 PM | ? |
| Apr 30 | Wed | NK4 Rohini | Di | సా5:12 = 17:12 PM? | ? |

## TODO for Next Session
1. Verify uncertain times (marked ?) by re-reading page 69, 71 images
2. Compute exact offsets using sunrise/sunset from script output above
3. Add confirmed entries to validate_amrita_formula.dart
