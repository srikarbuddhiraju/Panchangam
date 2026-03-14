# Panchangam Concepts — Nakshatra, Yoga, Karana

Part 2 of five limbs. For foundation + Tithi + Vara → [concepts-five-limbs.md](concepts-five-limbs.md)

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

#### The 27 Nakshatras — Properties

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

#### Nakshatra Absolute Zodiac Spans

Source: *Panchangam Calculations* (archive.org/details/PanchangamCalculations), p.25+

Each Nakshatra spans exactly 13°20' of the sidereal zodiac. Nine Nakshatras straddle two Rasis.
Format: degrees°-minutes' in the sidereal (Nirayana) frame.

| # | Name | Rasi | Span in Rasi | Absolute Span |
|---|------|------|-------------|---------------|
| 1 | Ashwini | Mesham | 00-00 → 13-20 | **000-00 → 013-20** |
| 2 | Bharani | Mesham | 13-20 → 26-40 | **013-20 → 026-40** |
| 3 | Krittika | Mesham/Vrishabham | 26-40→30-00 / 00-00→10-00 | **026-40 → 040-00** |
| 4 | Rohini | Vrishabham | 10-00 → 23-20 | **040-00 → 053-20** |
| 5 | Mrigasira | Vrishabham/Mithunam | 23-20→30-00 / 00-00→06-40 | **053-20 → 066-40** |
| 6 | Ardra | Mithunam | 06-40 → 20-00 | **066-40 → 080-00** |
| 7 | Punarvasu | Mithunam/Karkatakam | 20-00→30-00 / 00-00→03-20 | **080-00 → 093-20** |
| 8 | Pushyami | Karkatakam | 03-20 → 16-40 | **093-20 → 106-40** |
| 9 | Ashlesha | Karkatakam | 16-40 → 30-00 | **106-40 → 120-00** |
| 10 | Makha | Simham | 00-00 → 13-20 | **120-00 → 133-20** |
| 11 | Pubba | Simham | 13-20 → 26-40 | **133-20 → 146-40** |
| 12 | Uttara | Simham/Kanya | 26-40→30-00 / 00-00→10-00 | **146-40 → 160-00** |
| 13 | Hasta | Kanya | 10-00 → 23-20 | **160-00 → 173-20** |
| 14 | Chitra | Kanya/Thula | 23-20→30-00 / 00-00→06-40 | **173-20 → 186-40** |
| 15 | Swati | Thula | 06-40 → 20-00 | **186-40 → 200-00** |
| 16 | Vishakha | Thula/Vrischikam | 20-00→30-00 / 00-00→03-20 | **200-00 → 213-20** |
| 17 | Anuradha | Vrischikam | 03-20 → 16-40 | **213-20 → 226-40** |
| 18 | Jyeshtha | Vrischikam | 16-40 → 30-00 | **226-40 → 240-00** |
| 19 | Moola | Dhanus | 00-00 → 13-20 | **240-00 → 253-20** |
| 20 | Purvashadha | Dhanus | 13-20 → 26-40 | **253-20 → 266-40** |
| 21 | Uttarashadha | Dhanus/Makaram | 26-40→30-00 / 00-00→10-00 | **266-40 → 280-00** |
| 22 | Shravana | Makaram | 10-00 → 23-20 | **280-00 → 293-20** |
| 23 | Dhanishtha | Makaram/Kumbham | 23-20→30-00 / 00-00→06-40 | **293-20 → 306-40** |
| 24 | Shatabhisha | Kumbham | 06-40 → 20-00 | **306-40 → 320-00** |
| 25 | Purvabhadra | Kumbham/Meenam | 20-00→30-00 / 00-00→03-20 | **320-00 → 333-20** |
| 26 | Uttarabhadra | Meenam | 03-20 → 16-40 | **333-20 → 346-40** |
| 27 | Revati | Meenam | 16-40 → 30-00 | **346-40 → 360-00** |

#### Nakshatra Ending Time Formula

```
RD  = Remaining Degrees = nakshatra_end_longitude − moon_current_longitude
DMC = Daily Motion of Chandra (degrees/day, ~13.17° average)

Hours until nakshatra ends = (RD / DMC) × 24
```

**Example**: Moon at 353°41'52'' (Revati ends at 360°).
RD = 6°18'8'' = 6.302°, DMC = 13°9' = 13.15°/day → ends in 11.50 hours.

**Critical note on Ayanamsa**:
- Nirayana (sidereal) Moon longitude = Sayana (tropical) longitude − Ayanamsa
- Different Ayanamsa values → different Nirayana Moon positions → different ending times
- **Nakshatra and Yoga ending times depend on the Ayanamsa used**
- **Tithi ending times do NOT depend on Ayanamsa** (Tithi = relative Moon−Sun distance; absolute positions cancel)
- Our app uses **Lahiri Ayanamsa** (official Government of India standard)

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
// Step 1: sum longitudes
sum = (Sun sidereal longitude + Moon sidereal longitude) mod 360
// Step 2: if sum > 360, subtract 360 (already handled by mod)
// Step 3: divide by 13°20' (= 13.333...)
Yoga number = floor(sum / 13.3333°) + 1

// Ending time (same formula as Nakshatra):
RD  = yoga_end_longitude − sum_current
DMC = daily motion of (Sun + Moon) combined
Hours until yoga ends = (RD / DMC) × 24
```
Like Nakshatra, there are 27 Yogas of 13°20' each.
**Yoga ending time also depends on Ayanamsa used** (same reason as Nakshatra — absolute positions involved).

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

