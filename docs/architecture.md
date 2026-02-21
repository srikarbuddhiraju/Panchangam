# Architecture Decisions

## Tech Stack

| Layer | Choice | Reason |
|-------|--------|--------|
| Framework | Flutter (Dart) | Single codebase for Android → iOS → Web |
| State management | Riverpod (flutter_riverpod) | Simple, testable, composable providers |
| Navigation | go_router | Declarative routing; StatefulShellRoute for bottom nav tabs |
| Auth | Firebase Authentication | Google login built-in, free tier generous |
| Cloud sync | Firebase Firestore | Real-time family sharing, offline-first support |
| Local storage | Hive (on-device DB) | Fast, lightweight, works fully offline |
| Payments | Google Play Billing | Native Android subscription management |
| Astronomical calc | Dart (on-device) | Offline-first; no server needed for Panchangam data |
| City → coordinates | Bundled JSON (cities_india.json) | ~500 cities pre-loaded; no network call needed |

## Why Firebase?
- Firebase is Google's product — pairs naturally with Google login
- Firestore gives us real-time sync for family sharing with minimal backend code
- No need to build or host our own server (reduces cost and complexity)
- Free tier (Spark plan) covers development + early users; scales as we grow

## Offline-First Architecture
```
User opens app
     │
     ▼
Local Hive DB (on-device)
     │  ← Panchangam calculations run on device (no internet needed)
     │  ← User's own to-dos, reminders, events stored locally
     │
     ▼ (when internet available)
Firebase Firestore (cloud)
     │  ← Syncs user data across their devices
     │  ← Syncs shared data within family group
     ▼
Family members see shared events, reminders, occasions in real time
```

## App Folder Structure (inside `app/lib/`)
```
lib/
├── main.dart                    # App entry point; locale init (Telugu + English)
├── app/
│   ├── theme.dart               # Colors (saffron, kumkum), fonts, dark/light
│   └── routes.dart              # go_router config; 4 tabs + /panchangam/:date
├── features/
│   ├── calendar/                # Monthly calendar grid; swipe months; Today button
│   │   ├── calendar_screen.dart
│   │   ├── calendar_provider.dart
│   │   └── widgets/
│   │       ├── calendar_grid.dart   # 7-col grid; LayoutBuilder for dynamic scaling
│   │       ├── day_cell.dart
│   │       └── month_header.dart
│   ├── today/                   # Today tab — daily Panchangam with day navigation
│   │   └── today_screen.dart
│   ├── panchangam/              # Day detail screen (pushed from calendar or today tab)
│   │   ├── panchangam_screen.dart
│   │   ├── panchangam_provider.dart
│   │   └── widgets/
│   │       ├── five_limbs_card.dart     # Tithi, Vara, Nakshatra, Yoga, Karana ×2
│   │       ├── timings_card.dart        # Sunrise/set, Moonrise/set
│   │       ├── kalam_card.dart          # Rahu, Gulika, Yamaganda
│   │       ├── muhurtha_card.dart       # Abhijit, Dur Muhurta, Amrit Kalam
│   │       └── context_card.dart        # Month, year, Paksha, Rashi, Ritu, etc.
│   ├── eclipse/                 # Eclipse data provider + card widget
│   │   ├── eclipse_provider.dart        # eclipseProvider (year-level) + eclipseForDateProvider
│   │   └── widgets/
│   │       └── eclipse_card.dart        # Inline alert card shown on eclipse days
│   ├── family/                  # Family tab (Premium placeholder)
│   │   └── family_screen.dart
│   ├── settings/                # App preferences (city, language, time format)
│   │   ├── settings_screen.dart
│   │   └── settings_provider.dart
│   ├── todos/                   # To-Do management (Premium, future)
│   ├── reminders/               # Reminders (Premium, future)
│   ├── alarms/                  # Alarms (Premium, future)
│   ├── occasions/               # Events, Tithi birthdays (Premium, future)
│   ├── festivals/               # Festival calendar (future)
│   └── auth/                    # Google login, user profile (future)
├── core/
│   ├── calculations/            # Astronomical engine (all Panchangam math)
│   │   ├── panchangam_engine.dart   # Top-level orchestrator; PanchangamData model
│   │   ├── julian_day.dart          # Julian Day ↔ calendar conversions
│   │   ├── solar.dart               # Sun longitude, sunrise/sunset
│   │   ├── lunar.dart               # Moon longitude, moonrise/moonset
│   │   ├── tithi.dart               # Tithi number + end time
│   │   ├── nakshatra.dart           # Nakshatra number + end time
│   │   ├── yoga.dart                # Yoga number + end time
│   │   ├── karana.dart              # Karana number + end time (two per day)
│   │   ├── kalam_timings.dart       # Rahu/Gulika/Yamaganda using Pillai table
│   │   ├── muhurtha.dart            # Abhijit, Dur Muhurta, Amrit Kalam
│   │   ├── telugu_calendar.dart     # Masa, Samvatsara, Paksha, Shaka Samvat
│   │   ├── eclipse_calculator.dart  # Solar + lunar eclipse detection
│   │   └── ayanamsha.dart           # Lahiri ayanamsha for sidereal positions
│   ├── city_lookup/             # City name → lat/lng lookup from bundled JSON
│   └── utils/
│       └── app_strings.dart     # All UI strings (Telugu + English); S.isTelugu flag
└── shared/
    └── widgets/
        ├── main_scaffold.dart       # Bottom nav: Calendar | Today | Family | Settings
        └── language_toggle.dart     # EN/తె toggle button
```

## Tab Structure (Bottom Navigation)
| Tab | Icon | Route | Description |
|-----|------|-------|-------------|
| Calendar | calendar_month | `/` | Monthly grid; tap day → detail |
| Today | today | `/today` | Daily Panchangam; ← → day navigation |
| Family | people | `/family` | Premium placeholder |
| Settings | settings | `/settings` | City, language, time format |

**Eclipse/Grahanam**: Not a separate tab. The `eclipseForDateProvider` checks if the selected date has an eclipse and shows an inline `EclipseCard` at the top of the Panchangam detail in both the Today tab and the day detail screen.

## Navigation Flow
```
Bottom nav (4 tabs, StatefulShellRoute — state preserved)
├── / (Calendar) ──→ context.push('/panchangam/yyyy-MM-dd') → Day detail (back button)
├── /today ──────────── day navigation via StateProvider (no route change)
├── /family
└── /settings

/panchangam/:date  ← pushed on top of any tab; back button returns to caller
```

## Subscription & Paywall
- Google Play Billing handles all payment processing
- Firestore stores user's subscription status (verified server-side)
- Feature flags in app check subscription tier before unlocking Premium screens

## Infrastructure Cost Strategy

### Philosophy: Zero server cost until revenue justifies it

| Service | Cost | Notes |
|---------|------|-------|
| Firebase Auth | **Free forever** | Google login has no per-user cost |
| Firebase Firestore | **Free** up to 50K reads/day, 20K writes/day | ~1,600 active users before hitting limits |
| Firebase Cloud Messaging (push notifications) | **Free forever** | Unlimited notifications |
| Google Play Store | **₹1,700 one-time** | One-time developer registration |
| Apple App Store | **~₹8,300/year** | When we go to iOS — not now |
| Custom server / VPS | **₹0** | We don't need one — Firebase replaces it |
| Panchangam calculations | **₹0** | Runs on user's device, not our servers |

### How we stay on Firebase free tier as long as possible
- **Hive (local DB) is the primary store** — app reads from device first, Firestore second
- Firestore is only used for: family sync, user profile, subscription status
- Panchangam data never touches Firestore — calculated on-device
- Aggressive local caching: family data fetched once, cached, updated only on change

### When does Firebase start costing money?
Firebase Blaze (pay-as-you-go) kicks in beyond the free limits:
- Firestore reads: $0.06 per 100K reads (~₹5 per 100K)
- At 10,000 daily active users → estimated Firestore cost: ~₹500–1,500/month
- At that scale, premium revenue (even 500 subscribers × ₹99) = ₹49,500/month
- **Infrastructure cost will always be a tiny fraction of revenue**

### Cost triggers to watch
1. When daily active users exceed ~1,500 → upgrade Firebase to Blaze (pay-as-you-go)
2. When iOS is released → Apple Developer account ₹8,300/year
3. Web release → Firebase Hosting free tier (10GB) is sufficient for years

## Platform Rollout
1. **Android** — MVP, all features above
2. **iOS** — Add Apple Sign-In, submit to App Store
3. **Web** — Firebase Hosting, same codebase

## Key Decisions (Settled)
| Decision | Choice |
|----------|--------|
| Monetization | Freemium — ₹99/mo, ₹799/yr, ₹149/mo family |
| Market | India primary, diaspora secondary |
| Login | Google (Apple added at iOS release) |
| Offline | Yes — core Panchangam works without internet |
| Calculations | On-device (Dart), not a server |
| Backend | Firebase only (no custom server) |
| Eclipse display | Inline card in day detail (not a separate tab) |
