# Panchangam Concepts — Calendar Context, Eclipses & Events

Telugu months, Samvatsara, Adhika Maasa, eclipse calculations, special yogas, tithi-based events.

---

## CALENDAR CONTEXT (కాల గణన)

### Telugu Months (తెలుగు మాసాలు)

The Telugu calendar follows the **Amavasyant system** (month ends on Amavasya/New Moon).

| # | Telugu | Sanskrit | Approx. Gregorian |
|---|--------|----------|-------------------|
| 1 | చైత్రం | Chaitra | Mar–Apr |
| 2 | వైశాఖం | Vaisakha | Apr–May |
| 3 | జ్యేష్ఠం | Jyeshtha | May–Jun |
| 4 | ఆషాఢం | Ashadha | Jun–Jul |
| 5 | శ్రావణం | Shravana | Jul–Aug |
| 6 | భాద్రపదం | Bhadrapada | Aug–Sep |
| 7 | ఆశ్వయుజం | Ashvayuja | Sep–Oct |
| 8 | కార్తీకం | Kartika | Oct–Nov |
| 9 | మార్గశిరం | Margashira | Nov–Dec |
| 10 | పుష్యం | Pushya | Dec–Jan |
| 11 | మాఘం | Magha | Jan–Feb |
| 12 | ఫాల్గుణం | Phalguna | Feb–Mar |

**Adhika Masa (అధిక మాసం):** Leap month — occurs approximately every 3 years when there is no Purnima in a solar month. The entire month is considered inauspicious for major events.

---

### Paksha (పక్షం) — Lunar Fortnight

| Paksha | Telugu | Period | Moon |
|--------|--------|--------|------|
| Shukla Paksha | శుక్ల పక్షం | Pratipada → Purnima | Waxing (growing) |
| Krishna Paksha | కృష్ణ పక్షం | Pratipada → Amavasya | Waning (shrinking) |

---

### Samvatsara (సంవత్సరం) — 60-Year Cycle

The Telugu/Hindu calendar operates on a 60-year cycle. Each year has a unique name.
The cycle restarts after 60 years.

**Current and recent Samvatsaras:**
| Telugu Year | Samvatsara | Gregorian |
|-------------|------------|-----------|
| — | విజయ (Vijaya) | 2024–25 |
| — | జయ (Jaya) | 2025–26 |
| — | మన్మథ (Manmatha) | 2026–27 |

Full 60 names: Prabhava, Vibhava, Shukla, Pramoda, Prajapati, Angirasa, Shrimukha, Bhava, Yuva, Dhata, Ishvara, Bahudhanya, Pramadhi, Vikrama, Vrisha, Chitrabhanu, Subhanu, Tarana, Parthiva, Vyaya, Sarvajit, Sarvadhari, Virodhi, Vikruti, Khara, Nandana, Vijaya, Jaya, Manmatha, Durmukhi, Hevilambi, Vilambi, Vikari, Sharvari, Plava, Shubhakrut, Shobhakrut, Krodhi, Vishvavasu, Parabhava, Plavanga, Kilaka, Saumya, Sadharana, Virodhakrut, Paridhavi, Pramadicha, Ananda, Rakshasa, Nala, Pingala, Kalayukti, Siddharthi, Raudra, Durmati, Dundubhi, Rudhirodgari, Raktakshi, Krodhana, Akshaya.

---

### Shaka Samvat (శక సంవత్)
Official Indian national calendar era.
```
Shaka year = Gregorian year − 78  (after March 22)
           = Gregorian year − 79  (before March 22)
```

### Kali Yuga Era (కలి యుగం)
```
Kali year = Gregorian year + 3101  (approximately)
```

---

### Ayanam (అయనం) — Solar Transit

The Sun's position relative to the equinoxes divides the year into two Ayanams:

| Ayanam | Period | Sun enters | Significance |
|--------|--------|-----------|--------------|
| ఉత్తరాయణం (Uttarayana) | ~Jan 14 – Jul 14 | Capricorn (Makara) | Auspicious — "journey north" |
| దక్షిణాయనం (Dakshinayana) | ~Jul 14 – Jan 14 | Cancer (Karka) | Less auspicious |

**Makara Sankranti** (January 14) marks the start of Uttarayana — major Telugu festival.

---

### Ritu (ఋతువు) — Seasons

Hindu calendar has 6 seasons of 2 months each:
| # | Telugu | Sanskrit | Months | Gregorian approx |
|---|--------|----------|--------|-----------------|
| 1 | వసంత | Vasanta | Chaitra–Vaisakha | Mar–May |
| 2 | గ్రీష్మ | Grishma | Jyeshtha–Ashadha | May–Jul |
| 3 | వర్ష | Varsha | Shravana–Bhadrapada | Jul–Sep |
| 4 | శరత్ | Sharad | Ashvayuja–Kartika | Sep–Nov |
| 5 | హేమంత | Hemanta | Margashira–Pushya | Nov–Jan |
| 6 | శిశిర | Shishira | Magha–Phalguna | Jan–Mar |

---

### Rashi (రాశి) — Moon Sign

The zodiac divided into 12 signs of 30° each.
Moon sign = which Rashi the Moon occupies at a given moment.

| # | Telugu | Sanskrit | Symbol | Ruling Planet |
|---|--------|----------|--------|---------------|
| 1 | మేషం | Mesha | Aries | Mars |
| 2 | వృషభం | Vrishabha | Taurus | Venus |
| 3 | మిథునం | Mithuna | Gemini | Mercury |
| 4 | కర్కాటకం | Karkataka | Cancer | Moon |
| 5 | సింహం | Simha | Leo | Sun |
| 6 | కన్య | Kanya | Virgo | Mercury |
| 7 | తుల | Tula | Libra | Venus |
| 8 | వృశ్చికం | Vrishchika | Scorpio | Mars |
| 9 | ధనస్సు | Dhanus | Sagittarius | Jupiter |
| 10 | మకరం | Makara | Capricorn | Saturn |
| 11 | కుంభం | Kumbha | Aquarius | Saturn |
| 12 | మీనం | Meena | Pisces | Jupiter |

```
Rashi number = floor(Moon sidereal longitude / 30) + 1
```

---

## ECLIPSE CALCULATIONS (గ్రహణాలు)

### Types
| Type | Telugu | When |
|------|--------|------|
| Solar Eclipse | సూర్య గ్రహణం | Amavasya — Sun, Moon, Earth aligned |
| Lunar Eclipse | చంద్ర గ్రహణం | Purnima — Earth between Sun and Moon |

### Sutak (సూతక కాలం)
Ritual inauspicious period before an eclipse:
- **Solar eclipse**: Sutak begins 12 hours before
- **Lunar eclipse**: Sutak begins 9 hours before
- No eating, worship paused, temples closed during Sutak in traditional practice

### Visibility
Eclipses are only visible from certain parts of Earth.
Only eclipses visible from India / user's location should be highlighted prominently.
Partial vs total eclipse distinction important.

### Calculation approach
Eclipse prediction requires:
- Precise Sun, Moon, and lunar node (Rahu/Ketu) positions
- Rahu/Ketu are the mathematical points where Moon's orbit crosses the ecliptic
- Eclipse occurs when Sun or Moon is near Rahu/Ketu on Amavasya or Purnima

---

## SPECIAL YOGAS & COMBINATIONS

### Auspicious Yogas (Panchangam level)

**Amrit Siddhi Yoga**
Formed when specific Vara + Nakshatra combinations occur:
| Vara | Nakshatra |
|------|-----------|
| Sunday | Hasta |
| Monday | Mrigashira |
| Tuesday | Ashwini |
| Wednesday | Anuradha |
| Thursday | Pushyami |
| Friday | Revati |
| Saturday | Rohini |

**Sarvartha Siddhi Yoga**
Another highly auspicious combination of Vara + Nakshatra — good for all new beginnings.

**Ravi Yoga**: Sun in specific Nakshatra + specific Vara = auspicious for travel.

**Siddha Yoga**: Certain Tithi + Vara + Nakshatra combinations.

### Inauspicious Combinations

**Vishti (Bhadra)**: Certain Karana — avoid auspicious activities
**Dagdha Yoga**: Specific Tithi + Vara = inauspicious
**Shula Yoga (day-specific):** Each day of week has a specific direction that is inauspicious for travel
**Gandanta**: Junction between water and fire signs/Nakshatras — inauspicious transition period

---

## TITHI-BASED EVENTS (App Feature — Premium)

### Janma Tithi (జన్మ తిథి) — Tithi Birthday
Many Telugu families celebrate birthdays on the Tithi of birth, not the Gregorian date.
- The Tithi repeats every lunar month (~29.5 days)
- Janma Tithi falls in a different Gregorian month each year
- The app must calculate when the Janma Tithi falls each year for the user's city

### Tithi Anniversary / Death Anniversary
Death anniversaries (పితృ కార్యక్రమాలు / వర్ధంతి) are also tracked by Tithi.
- Shraddha (ancestor ritual) is performed on the same Tithi each year
- In Krishna Paksha typically
- App should send reminder based on Tithi, not fixed date

### Algorithm for Tithi-based reminders
```
Given: Tithi number T, Paksha P, approximate Gregorian date range
Find all dates in the upcoming year where Tithi = T and Paksha = P
Return the date(s) for the user's location (sunrise-to-sunrise)
```

---

