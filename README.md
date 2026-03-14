# Panchangam

A precise, traditional Telugu Panchangam app built with Flutter.
Verified against the Sringeri Sharada Peetham Panchangam.

**Release target: First week of April 2026 — Android (Play Store)**

## Platforms
- Android — in active development, release-ready
- iOS — planned after Android launch
- Web — planned final platform

## Design Philosophy
Easy · Scalable · Robust · Secure · Light · **Accurate**

## Current Status (Mar 2026)

Play Store submission in progress. All core features complete and verified on device.

### Tabs

| Tab | Description |
|-----|-------------|
| **Calendar** | Monthly grid with Tithi + Nakshatra per cell; Adhika month labelled; festival highlights; eclipse days marked |
| **Today** | Full daily Panchangam; navigate days with arrows |
| **Pro** | Premium hub — personal events, to-dos, reminders/alarms (Google Sign-In required) |
| **Settings** | City selection, language (Telugu/English), 12h/24h time, theme |

### Panchangam elements computed (all offline)

| Element | Status |
|---------|--------|
| All 5 limbs: Tithi, Vara, Nakshatra, Yoga, Karana + end times | ✅ |
| Sunrise / Sunset / Moonrise / Moonset | ✅ |
| Rahu Kalam, Gulika Kalam, Yamaganda | ✅ |
| Abhijit Muhurtham, Dur Muhurta | ✅ |
| Amrit Kalam — Sringeri lookup (Mar 2025–Apr 2027) | ✅ |
| Telugu month (Masa), Samvatsara, Paksha, Shaka Samvat | ✅ |
| Adhika Maasa (leap month) detection | ✅ |
| Ayanam, Ritu (season), Moon sign (Rashi) | ✅ |
| Solar + lunar eclipse contact times + Sutak | ✅ |
| Festivals (~28, tithi-based + solar-transit based) | ✅ |

### Pro features (Google Sign-In + Pro access required)

- Personal events — birthdays/anniversaries set by tithi, recur annually on the correct tithi
- To-Dos by tithi — plan tasks around the Panchangam
- Reminders and Alarms with per-event scheduling
- Pro hub tab with live events preview

### Accuracy

- All 5 limbs validated against DrikPanchang: 1–3 min accuracy
- Lahiri ayanamsha (standard for South India, Govt of India)
- VSOP87 solar position (~0.001°), Meeus Ch.47 lunar position (~0.01°)
- Amrit Kalam: exact Sringeri published times (Mar 2025–Apr 2027); no formula fallback outside that range
- Eclipse contact times: shadow geometry (Meeus), ~2–5 min accuracy

## Workspace

```
Panchangam/
├── app/                    # Flutter app
│   ├── lib/
│   │   ├── core/
│   │   │   ├── calculations/   # Astronomy & calendar math
│   │   │   └── data/           # Amrita lookup table, city database
│   │   └── features/
│   │       ├── calendar/       # Calendar tab
│   │       ├── today/          # Today tab
│   │       ├── panchangam/     # Day detail screen
│   │       ├── pro/            # Pro tab (premium hub)
│   │       ├── events/         # Personal events + to-dos
│   │       ├── festivals/      # Festival calculator + cards
│   │       └── settings/       # City picker, preferences
│   └── test/               # Unit tests
├── bin/                    # Validation + diagnostic scripts
└── docs/
    ├── roadmap.md          # Release plan (v1.0 April 2026, v1.1 May/June)
    ├── features.md         # Feature specs
    ├── architecture.md     # Tech stack & folder structure
    ├── calculation-methods.md          # Core calculation methods
    ├── calculation-methods-special.md  # Amrit Kalam, Eclipse, Samvatsara
    ├── concepts-five-limbs.md          # Domain reference: Tithi, Vara
    ├── concepts-nakshatra-yoga-karana.md
    ├── concepts-timings.md
    ├── concepts-calendar-eclipse.md
    ├── concepts-festivals.md
    ├── lessons.md          # Project lessons (read at every session start)
    └── play-store/
        ├── listing.md      # Play Store copy (title, description, screenshots)
        └── privacy-policy.md
```

## Privacy

No ads. No analytics. Personal events stored locally on device.
Google Sign-In is optional — all Panchangam features work without it.
Privacy policy: `docs/play-store/privacy-policy.md`
(To be hosted at: https://srikarbuddhiraju.github.io/Panchangam/privacy-policy)
