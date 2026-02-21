# Panchangam

A modern Telugu Panchangam app built with Flutter.

## Platforms
- Android (primary — in active development)
- iOS (planned)
- Web (planned)

## Design Philosophy
Easy · Scalable · Robust · Secure · Light

## Current Status (Feb 2026)

The app skeleton is fully built and running on Android. Core Panchangam calculations are implemented, validated against DrikPanchang, and working offline.

### What works today
- **Calendar tab** — monthly grid with Tithi + Nakshatra per cell; swipe left/right to navigate months; Today button to jump back
- **Today tab** — full daily Panchangam for today; navigate to previous/next days with arrow buttons
- **Family tab** — placeholder for future family sharing features
- **Settings tab** — city selection, language (Telugu/English), 12h/24h time, dark/light theme
- **Day detail screen** — tap any calendar day to see full Panchangam; back button returns to calendar
- **Grahanam (Eclipse) card** — appears inline on eclipse days in both the Today tab and day detail screen

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
| Telugu month (Masa) | ✅ Done |
| Telugu year (Samvatsara) | ✅ Done |
| Paksha (Shukla / Krishna) | ✅ Done |
| Shaka Samvat | ✅ Done |
| Ayanam | ✅ Done |
| Ritu (season) | ✅ Done |
| Moon sign (Rashi) | ✅ Done |
| Solar + lunar eclipses | ✅ Done |

## Workspace
```
Panchangam/
├── CLAUDE.md           # AI assistant instructions (project context)
├── README.md           # This file
├── app/                # Flutter application code
├── design/
│   ├── mockups/        # UI/UX mockups
│   └── assets/         # Icons, images, fonts
└── docs/
    ├── architecture.md         # Tech stack & folder structure decisions
    ├── features.md             # Feature planning & roadmap
    └── panchangam-concepts.md  # Domain knowledge reference
```

## Docs
- [Architecture](docs/architecture.md)
- [Features & Roadmap](docs/features.md)
- [Panchangam Concepts](docs/panchangam-concepts.md)
