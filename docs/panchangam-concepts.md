# Panchangam — Complete Reference & Calculation Guide

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
The difference between the two is called **Ayanamsa** (~23.5° currently, increasing ~50 arc-seconds/year).

```
Sidereal longitude = Tropical longitude − Ayanamsa
```

Most Panchangam software uses **Lahiri Ayanamsa** (official, govt of India standard).
Drikpanchang uses **Drik Ganita** (observation-based, Lahiri Ayanamsa).

---

## THE FIVE LIMBS (పంచాంగ అంగాలు)

---

### 1. TITHI (తిథి) — Lunar Day

#### What it is
A Tithi is defined by the angular separation between the Moon and the Sun.
Every 12° of separation = 1 Tithi.
One lunar month = 30 Tithis = 360° of Moon moving away from (and back to) the Sun.

#### Calculation
```
Tithi number = floor((Moon longitude − Sun longitude) mod 360 / 12) + 1
```
If the result is 0, Tithi = 30 (Amavasya).

#### Duration
- A Tithi is NOT 24 hours. It can range from ~19 hours to ~26 hours.
- The Moon moves faster when closer to Earth (Perigee) and slower at Apogee.
- A Tithi can start and end within the same calendar day (skipped Tithi),
  or span across two calendar days (two sunrises within one Tithi = repeated Tithi in some traditions).

#### The 30 Tithis

**Shukla Paksha — శుక్ల పక్షము (Waxing Moon)**
| # | Telugu Name | Sanskrit | Meaning / Lord |
|---|-------------|----------|----------------|
| 1 | పాడ్యమి | Pratipada | First day — Lord Agni |
| 2 | విదియ | Dwitiya | Second — Lord Brahma |
| 3 | తదియ | Tritiya | Third — Goddess Gauri |
| 4 | చవితి | Chaturthi | Fourth — Lord Ganesha |
| 5 | పంచమి | Panchami | Fifth — Goddess Saraswati / Naga |
| 6 | షష్ఠి | Shashthi | Sixth — Lord Karttikeya |
| 7 | సప్తమి | Saptami | Seventh — Lord Surya |
| 8 | అష్టమి | Ashtami | Eighth — Lord Shiva |
| 9 | నవమి | Navami | Ninth — Goddess Durga |
| 10 | దశమి | Dashami | Tenth — Lord Yama / Dharmaraja |
| 11 | ఏకాదశి | Ekadashi | Eleventh — Lord Vishnu (fasting day) |
| 12 | ద్వాదశి | Dwadashi | Twelfth — Lord Vishnu |
| 13 | త్రయోదశి | Trayodashi | Thirteenth — Lord Kamadeva |
| 14 | చతుర్దశి | Chaturdashi | Fourteenth — Lord Shiva |
| 15 | పౌర్ణమి | Purnima | Full Moon — Lord Chandra |

**Krishna Paksha — కృష్ణ పక్షము (Waning Moon)**
| # | Telugu Name | Sanskrit | Notes |
|---|-------------|----------|-------|
| 1-14 | Same names as above | Pratipada–Chaturdashi | Same names, waning moon |
| 15 | అమావాస్య | Amavasya | New Moon — ancestors (Pitrus) |

#### Significance
- **Ekadashi (11th)**: Fasting day for Vaishnavas — no food grains
- **Chaturdashi (14th)**: Associated with Lord Shiva
- **Amavasya**: Ancestor rituals (Pitru Tarpana)
- **Purnima**: Major festivals — Holi, Guru Purnima, Raksha Bandhan
- **Chaturthi**: Ganesh worship — Vinayaka Chaturthi

---

### 2. VARA (వారం) — Day of the Week

#### What it is
The weekday, each ruled by a planet and a deity.
Vara starts at sunrise (not midnight) in the Panchangam system.

#### The 7 Varas
| # | Telugu | Sanskrit | English | Ruling Planet | Deity |
|---|--------|----------|---------|---------------|-------|
| 1 | ఆదివారం | Ravivara | Sunday | Surya (Sun) | Surya |
| 2 | సోమవారం | Somavara | Monday | Chandra (Moon) | Shiva |
| 3 | మంగళవారం | Mangalavara | Tuesday | Mangala (Mars) | Hanuman / Kartikeya |
| 4 | బుధవారం | Budhavara | Wednesday | Budha (Mercury) | Vishnu |
| 5 | గురువారం | Guruvara | Thursday | Guru (Jupiter) | Vishnu / Brihaspati |
| 6 | శుక్రవారం | Shukravara | Friday | Shukra (Venus) | Lakshmi |
| 7 | శనివారం | Shanivara | Saturday | Shani (Saturn) | Shani / Yama |

#### Calculation
```
Day of week = (Julian Day Number + 1) mod 7
// 0=Sunday, 1=Monday, ..., 6=Saturday
```

#### Significance
- **Monday**: Best day to worship Shiva
- **Tuesday**: Hanuman worship, auspicious for new beginnings (per some traditions)
- **Wednesday**: Budha Hora — good for travel, business
- **Thursday**: Guru (Jupiter) day — worship teachers and Vishnu
- **Friday**: Lakshmi worship — prosperity prayers
- **Saturday**: Shani remedies, Saturn worship, avoid new ventures

---

### 3. NAKSHATRA (నక్షత్రం) — Lunar Mansion / Star

#### What it is
The sky is divided into 27 equal segments of 13°20' each.
The Nakshatra is the segment where the Moon is currently positioned.
The Moon takes approximately 27.3 days to complete one cycle — roughly one Nakshatra per day.

#### Calculation
```
Nakshatra number = floor(Moon sidereal longitude / 13.3333°) + 1
Pada (quarter) = floor((Moon longitude mod 13.3333°) / 3.3333°) + 1
```
Each Nakshatra has 4 Padas (quarters) of 3°20' each = 108 Padas total (sacred number).

#### The 27 Nakshatras
| # | Telugu | Sanskrit | Star(s) | Ruling Planet | Deity | Quality |
|---|--------|----------|---------|---------------|-------|---------|
| 1 | అశ్వని | Ashwini | β Arietis | Ketu | Ashwini Kumaras | Auspicious |
| 2 | భరణి | Bharani | 41 Arietis | Shukra | Yama | Fierce |
| 3 | కృత్తిక | Krittika | Pleiades | Surya | Agni | Mixed |
| 4 | రోహిణి | Rohini | Aldebaran | Chandra | Brahma | Auspicious |
| 5 | మృగశిర | Mrigashira | λ Orionis | Mangala | Soma | Soft |
| 6 | ఆర్ద్ర | Ardra | Betelgeuse | Rahu | Rudra | Fierce |
| 7 | పునర్వసు | Punarvasu | Pollux | Guru | Aditi | Auspicious |
| 8 | పుష్యమి | Pushyami | δ Cancri | Shani | Brihaspati | Auspicious |
| 9 | ఆశ్లేష | Ashlesha | ε Hydrae | Budha | Sarpa | Fierce |
| 10 | మఖ | Makha | Regulus | Ketu | Pitru | Fierce |
| 11 | పుబ్బ | Pubba (P.Phalguni) | δ Leonis | Shukra | Bhaga | Auspicious |
| 12 | ఉత్తర | Uttara (U.Phalguni) | β Leonis | Surya | Aryaman | Auspicious |
| 13 | హస్త | Hasta | δ Corvi | Chandra | Savitar | Auspicious |
| 14 | చిత్త | Chitra | Spica | Mangala | Vishvakarma | Soft |
| 15 | స్వాతి | Swati | Arcturus | Rahu | Vayu | Auspicious |
| 16 | విశాఖ | Vishakha | α Librae | Guru | Indra-Agni | Mixed |
| 17 | అనూరాధ | Anuradha | δ Scorpii | Shani | Mitra | Auspicious |
| 18 | జ్యేష్ఠ | Jyeshtha | Antares | Budha | Indra | Fierce |
| 19 | మూల | Moola | λ Scorpii | Ketu | Niritti | Fierce |
| 20 | పూర్వాషాఢ | Purvashadha | δ Sagittarii | Shukra | Apas | Fierce |
| 21 | ఉత్తరాషాఢ | Uttarashadha | σ Sagittarii | Surya | Vishvadevas | Auspicious |
| 22 | శ్రవణం | Shravana | Altair | Chandra | Vishnu | Auspicious |
| 23 | ధనిష్ఠ | Dhanishtha | β Delphini | Mangala | Ashta Vasus | Mixed |
| 24 | శతభిషం | Shatabhisha | λ Aquarii | Rahu | Varuna | Mixed |
| 25 | పూర్వాభాద్ర | Purvabhadra | α Pegasi | Guru | Aja Ekapad | Fierce |
| 26 | ఉత్తరాభాద్ర | Uttarabhadra | γ Pegasi | Shani | Ahir Budhnya | Auspicious |
| 27 | రేవతి | Revati | ζ Piscium | Budha | Pushan | Auspicious |

#### Nakshatra Gana (Nature)
- **Deva Gana** (Divine): Ashwini, Mrigashira, Punarvasu, Pushyami, Hasta, Swati, Anuradha, Shravana, Revati
- **Manushya Gana** (Human): Bharani, Rohini, Ardra, Pubba, Uttara, Purvashadha, Uttarashadha, Purvabhadra, Uttarabhadra
- **Rakshasa Gana** (Fierce): Krittika, Ashlesha, Makha, Chitra, Vishakha, Jyeshtha, Moola, Dhanishtha, Shatabhisha

#### Birth Nakshatra (జన్మ నక్షత్రం)
The Nakshatra occupied by the Moon at the time of birth. Used in:
- Naming children (first letter of name based on Nakshatra Pada)
- Marriage compatibility (Koota matching)
- Muhurtha selection

---

### 4. YOGA (యోగం) — Auspicious/Inauspicious Combination

#### What it is
Yoga is calculated from the combined longitudes of the Sun and Moon.
It measures the combined daily motion of both planets.

#### Calculation
```
Yoga number = floor((Sun longitude + Moon longitude) mod 360 / 13.3333°) + 1
```
Like Nakshatra, there are 27 Yogas of 13°20' each.

#### The 27 Yogas
| # | Name | Telugu | Nature |
|---|------|--------|--------|
| 1 | Vishkambha | విష్కంభ | Inauspicious |
| 2 | Priti | ప్రీతి | Auspicious |
| 3 | Ayushman | ఆయుష్మాన్ | Auspicious |
| 4 | Saubhagya | సౌభాగ్య | Auspicious |
| 5 | Shobhana | శోభన | Auspicious |
| 6 | Atiganda | అతిగండ | Inauspicious |
| 7 | Sukarma | సుకర్మ | Auspicious |
| 8 | Dhriti | ధృతి | Auspicious |
| 9 | Shoola | శూల | Inauspicious |
| 10 | Ganda | గండ | Inauspicious |
| 11 | Vriddhi | వృద్ధి | Auspicious |
| 12 | Dhruva | ధ్రువ | Auspicious |
| 13 | Vyaghata | వ్యాఘాత | Inauspicious |
| 14 | Harshana | హర్షణ | Auspicious |
| 15 | Vajra | వజ్ర | Mixed |
| 16 | Siddhi | సిద్ధి | Auspicious |
| 17 | Vyatipata | వ్యతీపాత | Highly Inauspicious |
| 18 | Variyana | వరీయాన్ | Auspicious |
| 19 | Parigha | పరిఘ | Inauspicious |
| 20 | Shiva | శివ | Auspicious |
| 21 | Siddha | సిద్ధ | Auspicious |
| 22 | Sadhya | సాధ్య | Auspicious |
| 23 | Shubha | శుభ | Auspicious |
| 24 | Shukla | శుక్ల | Auspicious |
| 25 | Brahma | బ్రహ్మ | Auspicious |
| 26 | Indra | ఇంద్ర | Auspicious |
| 27 | Vaidhriti | వైధృతి | Highly Inauspicious |

**Note**: Vyatipata (17) and Vaidhriti (27) are the most inauspicious Yogas — major events avoided.

---

### 5. KARANA (కరణం) — Half Tithi

#### What it is
A Karana is exactly half of a Tithi (6° of Moon-Sun angular separation).
There are 2 Karanas per Tithi = 60 Karanas per lunar month.

#### Types of Karanas
**Fixed Karanas (స్థిర కరణాలు)** — occur once per month at specific positions:
| # | Name | Telugu | Occurs |
|---|------|--------|--------|
| 1 | Kimstughna | కింస్తుఘ్న | 2nd half of Krishna Amavasya |
| 2 | Shakuni | శకుని | 1st half of Krishna Chaturdashi |
| 3 | Chatushpada | చతుష్పాద | 2nd half of Krishna Chaturdashi |
| 4 | Naga | నాగ | 1st half of Krishna Amavasya |

**Repeating Karanas (చర కరణాలు)** — cycle 8 times through the month:
| # | Name | Telugu | Nature |
|---|------|--------|--------|
| 1 | Bava | బవ | Auspicious |
| 2 | Balava | బాలవ | Auspicious |
| 3 | Kaulava | కౌలవ | Auspicious |
| 4 | Taitila | తైతిల | Auspicious |
| 5 | Garaja | గరజ | Auspicious |
| 6 | Vanija | వణిజ | Auspicious |
| 7 | Vishti (Bhadra) | విష్టి (భద్ర) | **Inauspicious** |

**Vishti/Bhadra** is the most important Karana to track — any auspicious work avoided during Bhadra.

---

## DAILY TIMINGS (దైనందిన కాలాలు)

### Sunrise & Sunset (సూర్యోదయం & సూర్యాస్తమయం)

The most fundamental inputs — everything else derives from these.

**Calculation inputs:**
- Date
- Latitude (°N)
- Longitude (°E)
- Time zone offset

**Formula (simplified):**
```
Hour angle H = arccos(
  (sin(−0.833°) − sin(lat) × sin(declination)) /
  (cos(lat) × cos(declination))
)

Sunrise = 12 − H / 15 − (longitude / 15 − timezone_offset)
Sunset  = 12 + H / 15 − (longitude / 15 − timezone_offset)
```
Where −0.833° accounts for atmospheric refraction and solar disc radius.

In Panchangam, **the day begins at sunrise**, not midnight.

---

### Moonrise & Moonset (చంద్రోదయం & చంద్రాస్తమయం)

Calculated similarly to sunrise but using the Moon's position instead of Sun.
The Moon rises approximately **50 minutes later each day** (due to its orbit around Earth).

---

### RAHU KALAM (రాహు కాలం)

#### What it is
An inauspicious 90-minute window each day, ruled by Rahu (shadow planet).
No auspicious work (marriage, travel, new ventures, pooja) should begin during Rahu Kalam.

#### Calculation
```
Day duration = Sunset time − Sunrise time
Period = Day duration / 8    (each period is 1/8 of the day)

Rahu Kalam start = Sunrise + (Period × rahu_multiplier)
Rahu Kalam end   = Rahu Kalam start + Period
```

**Rahu Multiplier by day of week:**
| Day | Multiplier | Approximate time (standard) |
|-----|-----------|----------------------------|
| Sunday | 7 | 16:30–18:00 |
| Monday | 1 | 07:30–09:00 |
| Tuesday | 6 | 15:00–16:30 |
| Wednesday | 4 | 12:00–13:30 |
| Thursday | 5 | 13:30–15:00 |
| Friday | 3 | 10:30–12:00 |
| Saturday | 2 | 09:00–10:30 |

*These are approximate for a 6 AM sunrise / 6 PM sunset location. Actual times shift with sunrise.*

**Memory aid (Telugu tradition):** "రావణ మామున్ కో శాపం" — first letters give the order:
ర(Ra-Sun/7), వ(Va-Mon/1), మా(Ma-Tue/6), ము(Mu-Wed/4), కో(Ko-Thu/5), శా(Sha-Fri/3), పం(Pa-Sat/2)

---

### GULIKA KALAM (గులిక కాలం)

Inauspicious period ruled by Gulika (son of Saturn/Shani).
Also called Manda Kalam in some regions.

```
Gulika Kalam start = Sunrise + (Period × gulika_multiplier)
```

**Gulika Multiplier by day:**
| Day | Multiplier |
|-----|-----------|
| Sunday | 6 |
| Monday | 5 |
| Tuesday | 4 |
| Wednesday | 3 |
| Thursday | 2 |
| Friday | 1 |
| Saturday | 0 |

---

### YAMAGANDA KALAM (యమగండ కాలం)

Inauspicious period associated with Yama (god of death).

```
Yamaganda start = Sunrise + (Period × yama_multiplier)
```

**Yamaganda Multiplier by day:**
| Day | Multiplier |
|-----|-----------|
| Sunday | 3 |
| Monday | 6 |
| Tuesday | 2 |
| Wednesday | 5 |
| Thursday | 1 |
| Friday | 4 |
| Saturday | 7 |

---

### ABHIJIT MUHURTHAM (అభిజిత్ ముహూర్తం)

The most auspicious window of every day.
Occurs at solar noon — approximately 24 minutes centered on the midpoint between sunrise and sunset.

```
Solar noon = (Sunrise + Sunset) / 2
Abhijit start = Solar noon − 12 minutes
Abhijit end   = Solar noon + 12 minutes
```

Exception: **Wednesday** — Abhijit is not considered auspicious on Wednesdays.

---

### DUR MUHURTA (దుర్ముహూర్తం)

Two inauspicious periods each day. One during the day, one near sunset.
Exact timings vary by weekday based on traditional calculations.

---

### AMRIT KALAM (అమృత కాలం)

Auspicious window derived from the Nakshatra of the day.
"Amrit" = nectar — anything started now is considered to flourish.
Duration and timing varies; calculated from the Nakshatra's start time.

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

## FESTIVALS (పండుగలు)

### Notes on Festival Dates
- All lunar festivals repeat on the same **Tithi + Paksha + Masa** each year
- Gregorian date shifts every year because the lunar calendar and solar calendar drift
- Solar festivals (Sankranti, Vishuvat) fall on a **fixed Gregorian date** (±1 day)
- Festival dates can vary by **tradition**: some follow Purnimant (North India), others follow Amavasyant (Telugu tradition)
- When a Tithi spans two sunrises, the festival date per Telugu tradition is the day on which the Tithi is present at **sunrise**

---

### TELUGU FESTIVALS — AP & Telangana (Common)

| Festival | Telugu | Tithi / Timing | Significance |
|----------|--------|----------------|--------------|
| **Ugadi** | ఉగాది | Chaitra Shukla Pratipada (1) | Telugu & Kannada New Year. New Samvatsara begins. Ugadi Pachadi eaten. |
| **Sri Rama Navami** | శ్రీ రామ నవమి | Chaitra Shukla Navami (9) | Birth of Lord Rama. Fasting, Sitarama Kalyanam performed. |
| **Hanuman Jayanti** | హనుమాన్ జయంతి | Chaitra Purnima (15) | Birth of Lord Hanuman. (North India observes on Chaitra Shukla Chaturdashi) |
| **Akshaya Tritiya** | అక్షయ తృతీయ | Vaisakha Shukla Tritiya (3) | Highly auspicious day — gold buying, new ventures, no Muhurtham needed. |
| **Narasimha Jayanti** | నరసింహ జయంతి | Vaisakha Shukla Chaturdashi (14) | Birth of Narasimha (Vishnu avatar). Fasting. |
| **Vat Savitri / Savitri Amavasya** | సావిత్రి అమావాస్య | Jyeshtha Amavasya | Women's vrat for husband's long life. Banyan tree worship. |
| **Rath Yatra** | రథ యాత్ర | Ashadha Shukla Dwitiya (2) | Lord Jagannath chariot procession. |
| **Guru Purnima** | గురు పౌర్ణమి | Ashadha Purnima (15) | Honoring gurus and teachers. Vyasa Purnima. |
| **Varalakshmi Vratam** | వరలక్ష్మి వ్రతం | Friday before Shravana Purnima | Women's vrat for Goddess Lakshmi. Major in AP & Telangana. Gold/silver idol worship. |
| **Naag Panchami** | నాగ పంచమి | Shravana Shukla Panchami (5) | Snake god worship. Milk offered to snake idols. |
| **Raksha Bandhan** | రక్షాబంధన్ | Shravana Purnima (15) | Brother-sister bond. Rakhi tied. |
| **Sri Krishna Janmashtami** | శ్రీ కృష్ణ జన్మాష్టమి | Shravana Krishna Ashtami (8) | Birth of Lord Krishna at midnight. Fasting until midnight. Dahi Handi. |
| **Vinayaka Chaturthi** | వినాయక చవితి | Bhadrapada Shukla Chaturthi (4) | Lord Ganesha's birthday. 10-day public festival. Clay idols immersed on Anant Chaturdashi. |
| **Anant Chaturdashi** | అనంత చతుర్దశి | Bhadrapada Shukla Chaturdashi (14) | Ganesh immersion (Nimarjan). End of 10-day Vinayaka festival. |
| **Atla Taddi** | అట్ల తద్ది | Ashvayuja Krishna Ashtami (8) | Telugu women's festival. Thaddi (snack) preparation, moon worship. Unique to Telugu culture. |
| **Mahalaya Amavasya** | మహాలయ అమావాస్య | Ashvayuja Amavasya | Last day of Pitru Paksha. Ancestor rituals. Most important Shraddha day. |
| **Dasara / Vijayadasami** | దసరా / విజయదశమి | Ashvayuja Shukla Dashami (10) | Victory of good over evil. Saraswati Puja, Ayudha Puja, Shami Puja. Starts new learning. |
| **Nagula Chaviti** | నాగుల చవితి | Kartika Shukla Chaturthi (4) | Snake god worship. Women's vrat. Anthill worship with milk. |
| **Dhanteras** | ధన్ తేరస్ | Kartika Krishna Trayodashi (13) | Gold/silver/utensil buying. Dhanvantari Jayanti. Lamp lighting begins. |
| **Naraka Chaturdashi** | నరక చతుర్దశి | Kartika Krishna Chaturdashi (14) | Victory of Krishna over Narakasura. Oil bath before sunrise. Firecrackers. |
| **Deepavali / Diwali** | దీపావళి | Kartika Krishna Amavasya | Festival of lights. Lakshmi Puja. Firecrackers. Biggest festival of the year. |
| **Govardhan Puja** | గోవర్ధన పూజ | Kartika Shukla Pratipada (1) | Krishna lifted Govardhan hill. Cow worship, Annakut (food mountain offering). |
| **Bhai Dooj / Yama Dwitiya** | భాయి దూజ్ | Kartika Shukla Dwitiya (2) | Brother-sister bond. Sisters invite brothers for meal. |
| **Tulasi Vivah** | తులసి వివాహం | Kartika Shukla Ekadashi or Dwadashi | Ceremonial marriage of Tulasi plant to Lord Vishnu. Wedding season begins. |
| **Vaikunta Ekadashi / Mukkoti** | వైకుంఠ ఏకాదశి / ముక్కోటి | Margashira Shukla Ekadashi (11) | Holiest Ekadashi. Vaikunta Dwara opens. Huge festival at Tirupati, Bhadrachalam. All-night vigil. |
| **Karthika Purnima** | కార్తీక పౌర్ణమి | Kartika Purnima (15) | Deep Daan (lamp donation). River/tank dip. Major for Shiva & Vishnu devotees. |
| **Karthika Somavaram** | కార్తీక సోమవారం | Every Monday in Kartika month | Month-long Shiva worship. Special significance in Karthika. |
| **Maha Shivaratri** | మహా శివరాత్రి | Phalguna Krishna Chaturdashi (14) | Night-long Shiva worship. Fasting. Abhishekam. Biggest Shaiva festival. |
| **Makara Sankranti** | మకర సంక్రాంతి | Solar — Sun enters Capricorn (~Jan 14) | Biggest Telugu festival. Harvest celebration. Kite flying. Sesame sweets. 3-4 day festival. |
| **Bhogi** | భోగి | Day before Sankranti | Old items burned in bonfire at dawn. Bhogi Pallu (flowers/coins showered on children). |
| **Kanuma** | కనుమ | Day after Sankranti | Cattle worship. Cockfighting (traditional). Farm animals rested. |
| **Mukkanuma** | ముక్కనుమ | Two days after Sankranti | Meat eating day. Family gatherings. Marks end of Sankranti. |
| **Vasant Panchami / Saraswati Puja** | సరస్వతి పూజ | Magha Shukla Panchami (5) | Goddess Saraswati worship. Books and instruments placed for puja. Yellow worn. |
| **Ratha Saptami** | రథ సప్తమి | Magha Shukla Saptami (7) | Sun worship. Surya Jayanti. Ritual bath at sunrise. |
| **Holi** | హోలీ | Phalguna Purnima (Holika Dahan), Phalguna Krishna Pratipada (Holi) | Festival of colors. Bonfire night before. |

---

### TELANGANA-SPECIFIC FESTIVALS

| Festival | Telugu | Timing | Significance |
|----------|--------|--------|--------------|
| **Bonalu** | బోనాలు | Ashadha–Shravana, consecutive Sundays | Offering of cooked rice (Bonam) to Goddess Mahakali. Urban festival — Hyderabad, Secunderabad, Warangal. 4-week celebration. |
| — Golconda Bonalu | గోల్కొండ బోనాలు | Ashadha Shukla Purnima Sunday | First Bonalu at Golconda fort's Mahakali temple. |
| — Secunderabad Bonalu | సికింద్రాబాద్ బోనాలు | Following Sunday (Shravana) | Ujjaini Mahankali temple, Secunderabad. Massive procession. |
| — Hyderabad Old City | లాల్ దర్వాజా బోనాలు | Following Sunday | Lal Darwaza Simhavahini Mahakali. |
| — Warangal Bonalu | వరంగల్ బోనాలు | Final Sunday | Warangal's Bhadrakali temple. Concludes Bonalu season. |
| **Bathukamma** | బతుకమ్మ | Bhadrapada Amavasya → Ashvayuja Shukla Navami (9 days) | Flower festival. Stack flowers in a cone shape, women sing and dance around it. Unique to Telangana. Ends with immersion in water. |
| — Engineeru Bathukamma | ఇంజనీరు బతుకమ్మ | Bhadrapada Krishna Ashtami | First day |
| — Saddula Bathukamma | సద్దుల బతుకమ్మ | Ashvayuja Shukla Navami | Final grand day — immersion in tanks/lakes |
| **Sammakka Saralamma Jatara** | సమ్మక్క సారలమ్మ జాతర | Magha Shukla Purnima (biennial — once every 2 years) | World's largest tribal fair. Medaram, Jayashankar Bhupalpally. Lakhs of devotees. Goddess Sammakka and Saralamma worshipped. |
| **Peerla Panduga** | పీర్ల పండుగ | Muharram (Islamic calendar) | Unique Telangana tradition — Hindus and Muslims celebrate together. Shows syncretic culture. |

---

### ANDHRA PRADESH-SPECIFIC FESTIVALS

| Festival | Telugu | Timing | Significance |
|----------|--------|--------|--------------|
| **Tirupati Brahmotsavam** | తిరుపతి బ్రహ్మోత్సవం | Bhadrapada Shukla Pratipada → Dashami (10 days) | Annual festival of Lord Venkateswara at TTD, Tirupati. Millions of pilgrims. Garuda Seva most spectacular day. |
| **Kanaka Durga Navaratri** | కనక దుర్గ నవరాత్రులు | Ashvayuja Shukla Pratipada → Navami | Goddess Kanaka Durga, Vijayawada. Different alankaram (decoration) each day. |
| **Godavari Pushkaralu** | గోదావరి పుష్కరాలు | Once every 12 years — when Jupiter (Guru) enters Mithuna Rashi | 12-day sacred dip in Godavari. Rajamahendravaram. Millions attend. |
| **Krishna Pushkaralu** | కృష్ణా పుష్కరాలు | Once every 12 years — when Jupiter enters Kanya Rashi | Similar to Godavari Pushkaralu but on Krishna river. Vijayawada. |
| **Sri Rama Navami (Bhadrachalam)** | భద్రాచలం శ్రీ రామ నవమి | Chaitra Shukla Navami | Sitarama Kalyanam at Bhadrachalam temple (now Telangana border area). State-sponsored. Massive gathering. |

---

### MAJOR PAN-INDIA HINDU FESTIVALS

| Festival | Telugu | Tithi / Timing | Celebrated Primarily |
|----------|--------|----------------|---------------------|
| **Makar Sankranti** | మకర సంక్రాంతి | Solar — ~January 14 | All India (Pongal in Tamil Nadu, Lohri in Punjab, Uttarayan in Gujarat) |
| **Vasant Panchami** | వసంత పంచమి | Magha Shukla Panchami (5) | All India — Saraswati Puja |
| **Maha Shivaratri** | మహా శివరాత్రి | Phalguna Krishna Chaturdashi (14) | All India — Shaiva |
| **Holi** | హోలీ | Phalguna Purnima + Krishna Pratipada | Primarily North/Central India |
| **Gudi Padwa / Ugadi** | ఉగాది | Chaitra Shukla Pratipada (1) | Maharashtra (Gudi Padwa), Telugu & Kannada (Ugadi) |
| **Ram Navami** | రామ నవమి | Chaitra Shukla Navami (9) | All India |
| **Hanuman Jayanti** | హనుమాన్ జయంతి | Chaitra Purnima (15) | All India |
| **Akshaya Tritiya** | అక్షయ తృతీయ | Vaisakha Shukla Tritiya (3) | All India |
| **Buddha Purnima** | బుద్ధ పౌర్ణమి | Vaisakha Purnima (15) | All India |
| **Rath Yatra** | రథ యాత్ర | Ashadha Shukla Dwitiya (2) | Puri (Odisha), All India |
| **Guru Purnima** | గురు పౌర్ణమి | Ashadha Purnima (15) | All India |
| **Janmashtami** | జన్మాష్టమి | Shravana Krishna Ashtami (8) | All India |
| **Ganesh Chaturthi** | వినాయక చవితి | Bhadrapada Shukla Chaturthi (4) | Maharashtra, AP, Telangana, Karnataka |
| **Onam** | ఓణం | Bhadrapada — Thiruvonam Nakshatra | Kerala (Shravana Nakshatra day) |
| **Navratri (Sharad)** | నవరాత్రులు | Ashvayuja Shukla Pratipada → Navami | All India |
| **Vijayadasami / Dasara** | విజయదశమి | Ashvayuja Shukla Dashami (10) | All India |
| **Karwa Chauth** | కర్వా చౌత్ | Kartika Krishna Chaturthi (4) | North India — women's vrat for husbands |
| **Dhanteras** | ధన్ తేరస్ | Kartika Krishna Trayodashi (13) | All India |
| **Deepavali** | దీపావళి | Kartika Krishna Amavasya | All India |
| **Chhath Puja** | ఛఠ్ పూజ | Kartika Shukla Shashthi (6) | Bihar, UP, Jharkhand — Sun worship |
| **Karthika Purnima** | కార్తీక పౌర్ణమి | Kartika Purnima (15) | All India |
| **Vaikunta Ekadashi** | వైకుంఠ ఏకాదశి | Margashira Shukla Ekadashi (11) | South India — Vaishnava |

---

### FOUR NAVARATRIS IN A YEAR

| Navaratri | Season | Tithi | Notes |
|-----------|--------|-------|-------|
| **Vasant / Chaitra Navaratri** | Spring | Chaitra Shukla Pratipada → Navami | Ends on Ram Navami. Officially observed in Telugu tradition (Ugadi to Ram Navami overlap). |
| **Ashadha / Gupt Navaratri** | Monsoon | Ashadha Shukla Pratipada → Navami | Tantric tradition. Less publicly observed. |
| **Sharad / Ashvayuja Navaratri** | Autumn | Ashvayuja Shukla Pratipada → Navami | **Most celebrated.** Durga Puja, Dasara. 9 forms of Durga worshipped. |
| **Magha / Gupt Navaratri** | Winter | Magha Shukla Pratipada → Navami | Tantric tradition. Less publicly observed. |

---

### EKADASHI (ఏకాదశి) — 24 Per Year

Every Ekadashi (11th Tithi, both Shukla and Krishna Paksha) is a fasting day for Vaishnavas.
Some Ekadashis have special names and elevated significance:

| Ekadashi Name | Telugu Month | Paksha | Special Significance |
|---------------|-------------|--------|---------------------|
| **Vaikunta Ekadashi (Mukkoti)** | Margashira | Shukla | Most sacred. Vaikunta Dwara opens. Major at Tirupati, Bhadrachalam. |
| **Nirjala Ekadashi** | Jyeshtha | Shukla | Strictest fast — no water. Equals merit of all 24 Ekadashis. |
| **Devuttana / Prabodhini Ekadashi** | Kartika | Shukla | Vishnu wakes from Yoga Nidra. Wedding season begins. Tulasi Vivah. |
| **Devshayani / Ashadi Ekadashi** | Ashadha | Shukla | Vishnu enters Yoga Nidra (sleep). Chaturmas begins. No weddings for 4 months. |
| **Vijaya Ekadashi** | Phalguna | Krishna | Victory — observed before major events. |
| **Apa Sara Ekadashi** | Bhadrapada | Shukla | Parsva Ekadashi — Vishnu turns over in his cosmic sleep. |
| **Kamada Ekadashi** | Chaitra | Shukla | Fulfills all desires. |
| **Mokshada Ekadashi** | Margashira | Shukla | Same as Vaikunta Ekadashi — moksha-giving. |

---

### AMAVASYA (అమావాస్య) — New Moon Days

All Amavasya days are significant for ancestor (Pitru) rituals.
Some have elevated importance:

| Amavasya | Telugu Month | Significance |
|----------|-------------|--------------|
| **Mahalaya Amavasya** | Ashvayuja | Most important. Last day of Pitru Paksha. Sarva Pitru Amavasya. |
| **Karthika Amavasya** | Kartika | Deepavali. Lakshmi Puja. |
| **Diwali Amavasya** | Kartika | Same as above. |
| **Bhanu Saptami Amavasya** | — | Special Amavasya + Sunday combination |
| **Somavati Amavasya** | Any | Amavasya falling on Monday. Very auspicious for women's vrats. |
| **Shani Amavasya** | Any | Amavasya on Saturday. Shani remedies. |

---

### PURNIMA (పౌర్ణమి) — Full Moon Days

| Purnima | Telugu Month | Significance |
|---------|-------------|--------------|
| **Chaitra Purnima** | Chaitra | Hanuman Jayanti. Chitragupta Puja. |
| **Vaisakha Purnima** | Vaisakha | Buddha Purnima. Kurma Jayanti. |
| **Jyeshtha Purnima** | Jyeshtha | Vat Purnima. |
| **Ashadha Purnima** | Ashadha | Guru Purnima (Vyasa Purnima). |
| **Shravana Purnima** | Shravana | Raksha Bandhan. Narali Purnima. |
| **Bhadrapada Purnima** | Bhadrapada | Pitru Paksha begins next day. |
| **Ashvayuja Purnima** | Ashvayuja | Sharad Purnima (Kojagiri). Lakshmi worship at night. Kheer kept in moonlight. |
| **Kartika Purnima** | Kartika | Dev Deepawali. Lamp lighting. Pushkar fair. Karthika Deepotsavam. |
| **Margashira Purnima** | Margashira | Dattatreya Jayanti. |
| **Pushya Purnima** | Pushya | Shakambhari Purnima. |
| **Magha Purnima** | Magha | Holy dip in rivers. Maghi. |
| **Phalguna Purnima** | Phalguna | Holi (Holika Dahan). |

---

### PITRU PAKSHA (పితృ పక్షం) — Ancestor Fortnight

| Day | Tithi | For whom Shraddha is performed |
|-----|-------|-------------------------------|
| Day 1 | Bhadrapada Purnima | Those who died on Purnima |
| Day 2 | Krishna Pratipada (1) | Those who died on Pratipada |
| Day 3 | Dwitiya (2) | Those who died on Dwitiya |
| … | … | … |
| Day 15 | **Mahalaya Amavasya** | All ancestors — universal Shraddha |

Special Tithis in Pitru Paksha:
- **Maha Bharani**: If Bharani Nakshatra falls during Pitru Paksha — very auspicious for Shraddha
- **Gajachhaya Yoga**: Rare combination — most powerful Shraddha day
- **Madhyashtami**: Ashtami of Pitru Paksha — for those who died in accidents or untimely death

---

### SOLAR FESTIVALS (Solar Calendar Based)

| Festival | Date | Significance |
|----------|------|--------------|
| **Makara Sankranti** | ~January 14 | Sun enters Capricorn. Uttarayana begins. Harvest. |
| **Ugadi** | Chaitra Shukla Pratipada | Telugu New Year (lunar-solar combined) |
| **Vishu** | ~April 14 | Sun enters Aries (Mesha). Kerala New Year. |
| **Akshaya Tritiya** | Vaisakha Shukla 3 | Sun + Moon both in exaltation — rarest alignment |
| **Karka Sankranti** | ~July 16 | Sun enters Cancer. Dakshinayana begins. |
| **Various Sankrantis** | Monthly (~14th) | Sun entering each new Rashi — minor observance |

---

## CALCULATION LIBRARIES TO EVALUATE

When implementing in Dart, the following approaches exist:

| Approach | Accuracy | Complexity |
|----------|----------|-----------|
| Swiss Ephemeris (via FFI) | Highest | High — C library, needs binding |
| VSOP87 algorithm (pure Dart) | High | Medium — implement in Dart |
| Simplified Meeus algorithms | Good | Low — from "Astronomical Algorithms" book |
| Pre-computed lookup tables | Fixed | Very Low — not suitable (no offline flexibility) |

**Recommended**: Jean Meeus "Astronomical Algorithms" formulas implemented in Dart.
Accuracy sufficient for Panchangam purposes (arc-second level precision).
Reference book: "Astronomical Algorithms" by Jean Meeus (2nd edition).

---

## CITY → COORDINATES LOOKUP

Since we use city name (not GPS), we need a city database:
- Bundled SQLite database of Indian cities with lat/lng
- Covers all district headquarters + major towns in AP, Telangana, and other states
- International cities for diaspora (US, UK, Australia, Gulf)
- Offline — no API call needed for lookup
- Fallback: Geocoding API for cities not in the local database
