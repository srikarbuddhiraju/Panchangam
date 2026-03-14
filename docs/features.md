# Feature Planning

## Status Legend
- [ ] Planned
- [~] In Progress
- [x] Done

---

## Tier Structure

### FREE TIER
- Basic Panchangam (all 5 elements + all daily timings)
- Monthly calendar view with Tithi/Nakshatra per day
- Eclipse timings (city name lookup, no GPS needed)
- Telugu + English language support

### PREMIUM TIER
| Plan | Price |
|------|-------|
| Monthly | ₹99/month |
| Annual | ₹799/year (~₹67/month) |
| Family | ₹149/month or ₹1199/year (up to 6 members) |

Premium unlocks:
1. To-Dos
2. Reminders
3. Alarms
4. Occasions & Events (including Tithi-based birthdays, death anniversaries)
5. Family sharing (all of the above + festivals + marked days)
6. Festival sharing within family/group

---

## Core Panchangam Data (FREE, offline, location-aware by city)

### The 5 Limbs
- [x] Tithi — lunar day + end time
- [x] Vara — weekday in Telugu
- [x] Nakshatra — star + end time
- [x] Yoga — combination + end time
- [x] Karana — two half-tithis per day, each with end time

### Daily Timings
- [x] Sunrise / Sunset
- [x] Moonrise / Moonset
- [x] Rahu Kalam
- [x] Gulikai Kalam
- [x] Yamaganda Kalam
- [x] Abhijit Muhurtham
- [x] Dur Muhurta
- [x] Amrit Kalam

### Month/Year Context
- [x] Telugu month (Masa)
- [x] Telugu year (Samvatsara)
- [x] Paksha (Shukla / Krishna)
- [x] Shaka Samvat
- [x] Ayanam
- [x] Ritu (Season)
- [x] Moon sign (Rashi)

### Eclipse Data (FREE)
- [x] Solar and lunar eclipse dates + timings
- [x] Eclipse card shown inline on eclipse days (no separate tab needed)
- [ ] Sutak timings
- [x] City name lookup (no GPS permission required)

---

## Calendar View (FREE)
- [x] Gregorian calendar grid (month view)
- [x] Each day cell: Tithi, Nakshatra
- [x] Festival marker on calendar cells
- [x] Day detail view: full Panchangam
- [x] Swipe left/right to navigate months
- [x] Today button (Outlook-style outlined button) to jump to current month
- [x] Calendar grid fills full screen height dynamically
- [ ] Week view
- [x] Festival markers on grid

---

## Today Tab (FREE)
- [x] Full daily Panchangam for today's date
- [x] Navigate to previous/next days with arrow buttons
- [x] Tap date header to jump back to today
- [x] Eclipse card shown inline on eclipse days

---

## Productivity Features (PREMIUM)

### 1. To-Dos (Session 7)
- [x] Tithi-based, **one-time** tasks (donate on Ekadashi, visit temple on Panchami etc.)
- [x] Pinned to NEXT occurrence of chosen tithi from creation date; stored as `targetDate`
- [x] Mark as complete → archived (no recurrence; recurring needs use Personal Events)
- [x] Optional reminder notification (reuses `ReminderType`: reminder/alarm)
- [x] Notes field (optional)
- [x] Lives inside Pro tab (`MyEventsScreen`) as a second tab alongside Events
- [ ] Day detail: shows matching To-Dos as a checkable card (deferred)
- [ ] Shareable with family group (future)

### 2. Reminders (via Occasions & Events)
- [x] Set at specific time on day-of or N days before tithi
- [x] Inexact mode (push notification, no special permission)
- [ ] Repeat options beyond tithi-based (daily, weekly, custom) — future
- [ ] Shareable with family group — future

### 3. Alarms (via Occasions & Events)
- [x] Exact `alarmClock` mode — bypasses doze, shows in system clock app
- [x] Alarm sound — `panchangam_alarms` channel with `AudioAttributesUsage.alarm` + system alarm ringtone URI
- [ ] Snooze support — future
- [ ] Shareable with family group — future

### 4. Occasions & Events (PREMIUM)
- [x] Create tithi-based personal events (name EN/TE, tithi, monthly or yearly)
- [x] Notes field on event — shown as expandable card in My Events + Day detail
- [x] Set reminder (inexact, no special permission) or alarm (exact, alarmClock)
- [x] Reminder time picker (H:MM AM/PM) + days-before selector
- [x] Events appear on calendar grid (gold dot) and Day detail card
- [ ] **Tithi-based birthday** — same as above but with birthday label/UX
- [ ] **Death anniversary (Tithi)** — same with death anniversary UX
- [ ] Shareable with family group

---

## Festivals (FREE display, PREMIUM sharing)
- [ ] Pre-loaded Telugu Hindu festival calendar
- [ ] Festival detail: significance, timings
- [ ] Shown on calendar grid automatically
- [ ] Custom festivals (PREMIUM)
- [ ] Share festivals within family group (PREMIUM)

---

## User Accounts
- [x] Sign in with Google (one tap) — optional, core app works without it
- [ ] Apple login — added at iOS release
- [ ] Profile: name, city, language preference
- [ ] Data synced across user's devices (Firestore Pro check pending)

---

## Pro Tab (PREMIUM — v1.0, replacing Family tab)
- [ ] Premium-looking Pro hub: hero section, feature cards, paywall prompt for free users
- [ ] Design: dark gradient + gold accents, modern card layout (Spotify/Apple One feel)
- [ ] Shows: Events, To-Dos, Reminders, Alarms access cards
- [ ] Non-pro: polished sign-in / upgrade prompt

## Family / Group Sharing (PREMIUM — v1.1, May/June 2026)
- [ ] Create or join a family group (Firebase Firestore)
- [ ] Invite by email
- [ ] Shared calendar view (family members' events visible)
- [ ] Shared: to-dos, reminders, alarms, events, occasions, festivals
- [ ] Admin vs member roles
- [ ] Up to 6 members on Family Plan (₹149/month or ₹1199/year)
- **Excluded from v1.0** — too complex for April launch (5-7 sessions needed)

---

## Settings & Personalization
- [x] Language: Telugu / English
- [x] Default city (for calculations) — major Indian cities + diaspora cities included
- [x] Time format: 12hr / 24hr
- [ ] Theme: light / dark
- [ ] Notification preferences

---

## Future / Post-MVP
- [ ] Muhurtham finder
- [ ] Jatakam basics
- [ ] PDF export of monthly Panchangam
- [ ] Home screen widget
- [ ] iOS release (+ Apple login)
- [ ] Web app
