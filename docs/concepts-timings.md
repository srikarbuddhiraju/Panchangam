# Panchangam Concepts — Daily Timings

Sunrise/Sunset, Rahu Kalam, Gulika, Yamaganda, Muhurthas, Amrit Kalam, Varjyam.
For Five Limbs → [concepts-five-limbs.md](concepts-five-limbs.md)

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

### AMRIT KALAM (అమృత కాలం) / AMRITA GADIYAS

Auspicious window derived from the Nakshatra of the day.
"Amrit" = nectar — anything started now is considered to flourish.

**Formula** (Karanam Ramakumar, *Panchangam Calculations*):
```
amrita_start    = nkStartTime + (X / 24) × nkDuration
amrita_duration = nkDuration / 15        // same as nkDuration × 1.6/24
```
Where `nkStartTime` = when Moon enters the Nakshatra; `nkDuration` = total Nakshatra duration;
`X` = Nakshatra-specific constant (see `calculation-methods.md` for full X table).

Duration is proportional to Nakshatra duration (~76–104 min, averaging ~96 min).

### VARJYAM (వర్జ్యం / త్యాజ్యం)

The inauspicious counterpart to Amrit Kalam, calculated the same way with a different X value.
Same duration as Amrit Kalam. Activities should be avoided during Varjyam.
Both Amrit Kalam and Varjyam X values are in the table in `calculation-methods.md`.

---

