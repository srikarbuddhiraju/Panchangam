# Architecture Decisions

## Tech Stack

| Layer | Choice | Reason |
|-------|--------|--------|
| Framework | Flutter (Dart) | Single codebase for Android → iOS → Web |
| Auth | Firebase Authentication | Google login built-in, free tier generous |
| Cloud sync | Firebase Firestore | Real-time family sharing, offline-first support |
| Local storage | Hive (on-device DB) | Fast, lightweight, works fully offline |
| Payments | Google Play Billing | Native Android subscription management |
| Astronomical calc | Dart (on-device) | Offline-first; no server needed for Panchangam data |
| City → coordinates | Geocoding API or bundled city DB | City name lookup for location-based calculations |

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
├── main.dart                    # App entry point
├── app/
│   ├── theme.dart               # Colors, fonts, dark/light
│   └── routes.dart              # Navigation/routing
├── features/
│   ├── calendar/                # Calendar grid view
│   ├── panchangam/              # Daily Panchangam detail
│   ├── todos/                   # To-Do management (Premium)
│   ├── reminders/               # Reminders (Premium)
│   ├── alarms/                  # Alarms (Premium)
│   ├── occasions/               # Events, Tithi birthdays (Premium)
│   ├── festivals/               # Festival calendar
│   ├── family/                  # Family group sharing (Premium)
│   ├── eclipse/                 # Eclipse timings (Free)
│   ├── auth/                    # Google login, user profile
│   └── settings/                # App preferences
├── core/
│   ├── calculations/            # Astronomical engine (Panchangam math)
│   ├── city_lookup/             # City name → lat/lng
│   └── utils/
└── shared/
    └── widgets/                 # Reusable UI components
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
