# Panchangam

A modern Telugu Panchangam app built with Flutter.

## Platforms
- Android (primary — in active development)
- iOS (planned — after Android is proven and generating revenue)
- Web (planned — final platform)

## Design Philosophy
Easy · Scalable · Robust · Secure · Light

## Current Status (Feb 2026)

Three milestones complete. The app runs fully offline on Android with calculations validated against DrikPanchang (1–3 min accuracy across all fields).

### What works today
- **Calendar tab** — monthly grid with Tithi + Nakshatra per cell; swipe left/right to navigate months; Today button to jump back; Adhika (leap) month labelled in header
- **Today tab** — full daily Panchangam for today; navigate to previous/next days with arrow buttons
- **Family tab** — placeholder for future family sharing features
- **Settings tab** — city selection from bundled India database, language (Telugu/English), 12h/24h time, dark/light theme
- **Day detail screen** — tap any calendar day to see full Panchangam; back button returns to calendar
- **Grahanam (Eclipse) card** — appears inline on eclipse days with Sparsha, Moksha, and Sutak timings
- **Festival cards** — expandable cards with Puranic descriptions; 28 festivals; suppressed in Adhika months

### Panchangam data computed (all offline, no internet needed)
| Element | Status |
|---------|--------|
| Tithi (lunar day) + end time | ✅ Done |
| Vara (weekday in Telugu) | ✅ Done |
| Nakshatra + end time | ✅ Done |
| Yoga + end time | ✅ Done |
| Karana × 2 + end times | ✅ Done |
| Sunrise / Sunset | ✅ Done |
| Moonrise / Moonset | ✅ Done |
| Rahu Kalam | ✅ Done |
| Gulikai Kalam | ✅ Done |
| Yamaganda Kalam | ✅ Done |
| Abhijit Muhurtham | ✅ Done |
| Dur Muhurta | ✅ Done |
| Amrit Kalam | ✅ Done |
| Telugu month (Masa) — Amavasyant | ✅ Done |
| Adhika Maasa (leap month) detection | ✅ Done |
| Telugu year (Samvatsara, 60-year cycle) | ✅ Done |
| Paksha (Shukla / Krishna) | ✅ Done |
| Shaka Samvat | ✅ Done |
| Ayanam (Uttarayana / Dakshinayana) | ✅ Done |
| Ritu (season) | ✅ Done |
| Moon sign (Rashi) | ✅ Done |
| Solar + lunar eclipses (Sutak timings) | ✅ Done |
| Festivals (~28, tithi-based + solar) | ✅ Done |

### Accuracy notes
- All fields validated against DrikPanchang with 1–3 min accuracy
- Lahiri ayanamsha used throughout (standard for South India)
- Correct Amavasyant month method: next-Amavasya sun rashi (not solar approximation)
- Ugadi kshaya Pratipada rule: assigned to Amavasya day when Pratipada is skipped
- Adhika Maasa: both consecutive Amavasyas in same rashi → first month is Adhika

### Test coverage
- 32 unit tests, all passing (`app/test/`)
- Covers: Tithi, Nakshatra, Yoga, Karana, Sunrise, Julian Day, month number, Adhika Maasa, Ugadi, festival suppression

## Roadmap

See [ROADMAP.md](ROADMAP.md) for the full feature roadmap and release plan.

Summary:
- **v1.0 MVP** — Family tab content, app icon, Play Store listing
- **v1.1–v1.5** — Push notifications, widgets, more festivals, dark mode, Family tab features, Muhurtha picker, monetisation
- **v2.0–v2.1** — iOS launch (after Android proven + revenue)
- **v3.0** — Web (final platform)

## Workspace
```
Panchangam/
├── CLAUDE.md               # AI assistant instructions (project context)
├── README.md               # This file
├── ROADMAP.md              # Feature status board and release plan
├── app/                    # Flutter application code
│   ├── lib/
│   │   ├── core/
│   │   │   └── calculations/   # All astronomy & calendar math
│   │   └── features/
│   │       ├── calendar/       # Calendar tab and grid
│   │       ├── today/          # Today tab
│   │       ├── panchangam/     # Day detail screen
│   │       ├── festivals/      # Festival calculator and cards
│   │       └── settings/       # City picker, preferences
│   └── test/
│       └── calculations/       # Unit tests (32 passing)
├── design/
│   ├── mockups/            # UI/UX mockups
│   └── assets/             # Icons, images, fonts
└── docs/
    ├── roadmap.drawio              # Visual feature status board (draw.io)
    ├── architecture.md             # Tech stack & folder structure decisions
    ├── features.md                 # Feature planning notes
    └── panchangam-concepts.md      # Domain knowledge reference
```

## Docs
- [Roadmap](ROADMAP.md)
- [Architecture](docs/architecture.md)
- [Panchangam Concepts](docs/panchangam-concepts.md)
