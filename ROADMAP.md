# Panchangam App — Roadmap

## Milestone 1 — Foundation ✅
- Flutter project setup (Android-first, single codebase)
- Julian Day & solar/lunar position calculation engine
- All 5 Panchangam limbs: Tithi, Vara, Nakshatra, Yoga, Karana (+ Karana 2)
- Sunrise / Sunset (NOAA algorithm)
- Moonrise / Moonset
- Kalam timings: Rahu Kalam, Gulika Kalam, Yamaganda
- Muhurthas: Abhijit, Dur Muhurta, Amrit Kalam
- Calendar grid (Gregorian + Telugu overlay, transposed layout)
- Riverpod state management, GoRouter navigation, tab structure

## Milestone 2 — Core Features ✅
- Festival calculator (~28 festivals with Puranic descriptions)
- Expandable Festival card (Today screen + Panchangam detail page)
- Eclipse detection (lunar + solar, Meeus Rahu formula)
- Eclipse card: Sparsha, Moksha, Sutak timings (general + vulnerable)
- Today screen with full panchangam view
- Panchangam detail push route (/panchangam/:date)
- Telugu / English language toggle
- City picker with bundled India city database
- Location fully wired to all calculations (Hive persistence)
- Samvatsara, Ayanam, Ritu, Rashi display
- Moon phase icons (🌕 Pournami, 🌑 Amavasya) in calendar cells

## Milestone 3 — Accuracy & Polish ✅
> All calculations validated against DrikPanchang (1–3 min accuracy)

- Samvatsara calibration fix (Vishvavasu = Shaka 1947)
- Yamaganda Saturday multiplier fix (Pillai table)
- Karana sequence off-by-one fix (60-karana cycle)
- Ugadi kshaya Pratipada fix (T30 + next-day T2 rule)
- Telugu monthNumber: replaced solar approximation with correct Amavasyant method
- Adhika Maasa: detection, "అధిక X" display, festival suppression
- Calendar layout redesign (transposed grid, bigger fonts, moon icon inline)
- Eclipse: Rahu corrected, Sparsha/Moksha by 5-min scan, Sutak from Sparsha
- 32 unit tests, all passing

---

## v1.0 — MVP: Play Store Launch 🚧
> Target: first public Android release

- [ ] Family tab — fill with useful content or remove empty placeholder
- [ ] App icon & splash screen (branded, no default Flutter icon)
- [ ] Play Store listing: account, screenshots, description, privacy policy

---

## v1.1 — Quick Wins (Android)
> Fast follow-up; high user value, low effort

- Push notifications: festival reminders (day-before + day-of)
- Muhurtha alerts (auspicious time notifications)
- Home screen widget (today's tithi, nakshatra, upcoming festival)
- Share today's panchangam (image/text export)

## v1.2 — Content & UX (Android)
- More festivals (50+ including regional Telugu, diaspora events)
- Year view in calendar
- Dark mode toggle in settings
- Onboarding flow for first-time users
- In-app rating prompt

## v1.3 — Family Tab (Android)
> The social/personal layer; drives retention

- Family birthdays & anniversaries with reminders
- Personal events overlaid on calendar
- Auspicious date suggestions for family events

## v1.4 — Advanced Features (Android)
- Muhurtha picker (enter activity type → best times returned)
- Multiple saved locations (home / office / hometown)
- PDF / print export of monthly panchangam
- Expanded festival database (100+ festivals, regional variety)

## v1.5 — Monetisation (Android)
> Generate revenue before expanding platforms

- Premium subscription (notifications, export, advanced features)
- Ad-free upgrade option
- Family plan (shared data across devices)

---

## v2.0 — iOS Launch
> Android proven + revenue generating before investing in iOS

- iOS build & App Store submission
- iOS-specific UI polish (safe areas, haptics, SF Symbols)
- App Store listing, TestFlight beta
- Cross-platform analytics & crash reporting

## v2.1 — iOS Maturity
- iOS bug fixes based on App Store feedback
- App Store optimisation (ASO, keywords, ratings)
- iCloud sync for settings & family data

---

## v3.0 — Web
> Final platform; broadest reach, lowest monetisation

- Flutter Web build & hosting
- SEO-optimised panchangam pages for discoverability
- Progressive Web App (installable, offline-capable)
