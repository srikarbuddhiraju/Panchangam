# Play Store Listing — Panchangam

_All copy ready to paste. Srikar reviews and adjusts tone before submitting._

---

## App Title
```
Panchangam
```
_(10 chars — clean, pan-India scalable, final decision Mar 13 2026)_

---

## Short Description (80 chars max)
```
Precise Telugu Panchangam — Tithi, Nakshatra, Kalams, Festivals & Reminders
```
_(76 chars ✓)_

---

## Full Description (4000 chars max — ~1400 chars below, leaves room)

```
Panchangam is a precise, traditional Telugu Panchangam for your Android phone.
Built on high-accuracy astronomical calculations and verified against the
Sringeri Sharada Peetham Panchangam — the most respected traditional almanac
in South India.

── DAILY PANCHANGAM ──
• All 5 limbs: Tithi, Vara, Nakshatra, Yoga, Karana
• Sunrise, Sunset, Moonrise, Moonset
• Rahu Kalam, Gulika Kalam, Yamaganda
• Abhijit Muhurtha, Dur Muhurtha
• Amrit Kalam — sourced directly from Sringeri Panchangam (Mar 2025–Apr 2027)

── CALENDAR ──
• Monthly calendar grid with Tithi and Nakshatra per day
• Festival highlights — Ugadi, Shivaratri, Ekadashi, Amavasya and more
• Eclipse days marked with timing details (lunar and solar)
• Adhika Maasa (leap month) shown correctly

── ECLIPSES ──
• Precise contact times (Sparsha, Madhya, Moksha) using shadow geometry
• Sutak timing displayed
• Solar and Lunar eclipses for India

── PRO FEATURES ──
• Personal Events — set birthdays and anniversaries by tithi once,
  they recur on the correct tithi every year automatically
• To-Dos by Tithi — plan tasks around the Panchangam
• Reminders and Alarms — get notified before each event
• Google Sign-In to sync events securely

── BILINGUAL ──
• Full Telugu and English support
• Switch languages instantly from Settings

── PRIVACY-FIRST ──
• No ads
• Personal events stored locally on your device
• Google Sign-In is optional — all Panchangam features work without it

Reference: Sri Sharada Peetham Panchangam, Sringeri Matha.
For important religious occasions, please verify with a local pandit.
```

---

## Category
`Lifestyle` (primary) — or `Education`

## Content Rating
Questionnaire answers (fill during Play Console setup):
- Violence: None
- Sexual content: None
- Profanity: None
- Controlled substances: None
- User-generated content: No (events are local, not shared)
→ Expected rating: **Everyone**

---

## App Icon
- File: `app/assets/icon.png` (source)
- Play Store needs: 512×512 PNG, <1 MB
- Run: `flutter build appbundle` → icon is embedded; also export separately

## Feature Graphic
- Size required: 1024×500 px
- Design: deep navy (#0B1437) background, app icon centered, "Panchangam" in gold text
- **TODO**: Srikar to create or commission this graphic

---

## Privacy Policy
- **Required** before publishing
- Must be hosted at a public URL (GitHub Pages works fine)
- Draft → `docs/play-store/privacy-policy.md`
- Host at: `https://srikarbuddhiraju.github.io/Panchangam/privacy-policy`
  (enable GitHub Pages on the repo → publish from `/docs` folder)

---

## Screenshots Plan

Play Store: **2–8 screenshots**, phone (portrait), PNG or JPEG.
Recommended: 6 screenshots covering key features.

| # | Screen | What to show | Status |
|---|--------|--------------|--------|
| 1 | Calendar | March/April 2026 with Ugadi highlighted | ⚠️ retake (Pro tab now exists) |
| 2 | Today tab | Full panchangam for a festival day | ⚠️ retake |
| 3 | Day detail | Kalams + Amrit Kalam with Sringeri source | ⚠️ retake (new attribution UI) |
| 4 | Pro tab | Hero + feature cards + events list | 🆕 need to capture |
| 5 | Eclipse | Eclipse day card on calendar or day detail | ⚠️ retake |
| 6 | Settings | City picker / language toggle | existing ok |

All old screenshots (Feb 22) are pre-Pro tab and pre-amrit attribution — **retake all except Settings**.

### How to take screenshots
```bash
# Connect device, then:
adb exec-out screencap -p > docs/screenshots/XX-name.png
```

---

## Release Notes (What's New — first release)
```
First release of Panchangam!

Precise Telugu Panchangam with all 5 limbs, daily timings, festivals,
eclipse details, and Pro features including tithi-based personal events
with reminders and alarms.

Verified against Sringeri Sharada Peetham Panchangam.
```
