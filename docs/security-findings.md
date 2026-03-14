# Security Findings — Panchangam

**Audit date:** Mar 14, 2026
**Auditor:** Claude Sonnet 4.6 (full project scan)
**Status tracking:** Update `Status` column as each item is resolved.

---

## Severity Legend
- 🔴 **HIGH** — Exploitable before billing is wired. Fix before Play Store launch.
- 🟡 **MEDIUM** — Requires effort to exploit or low financial impact today. Fix before billing goes live.
- 🟢 **RESOLVED** — Fixed and verified.

---

## Finding 1 — Release APK signed with debug keys
| Field | Detail |
|-------|--------|
| **Severity** | 🔴 HIGH |
| **Status** | ✅ Fixed (Session 27) — `key.properties` + release signingConfig wired |
| **File** | `app/android/app/build.gradle.kts` lines 38–40 |
| **Category** | Insecure signing |
| **Confidence** | 10/10 |

**What:** Release build uses the Android debug keystore (`signingConfig = signingConfigs.getByName("debug")`). The debug key is identical on every Android SDK installation — password `android`, alias `androiddebugkey`.

**Why it matters:** Any attacker can sign a malicious APK with the same key and push it as an "update" to devices that already have the app installed. Android accepts the update because the signing key matches. The malicious app inherits all user data.

**Also:** The Play Store will reject a debug-signed APK on the production track — so this blocks launch entirely.

**Fix:** Create a dedicated release keystore before submission:
```bash
keytool -genkey -v -keystore release.jks -alias panchangam -keyalg RSA -keysize 2048 -validity 10000
```
Store credentials in `key.properties` (gitignored). Reference in `build.gradle.kts`:
```kotlin
signingConfigs {
  create("release") {
    storeFile = file(keystoreProperties["storeFile"] as String)
    storePassword = keystoreProperties["storePassword"] as String
    keyAlias = keystoreProperties["keyAlias"] as String
    keyPassword = keystoreProperties["keyPassword"] as String
  }
}
```

**Owner:** Srikar (keystore creation) + Claude (build.gradle.kts wiring)
**Blocker for:** Play Store submission

---

## Finding 2 — Pro status is a client-side boolean (no server verification)
| Field | Detail |
|-------|--------|
| **Severity** | 🔴 HIGH |
| **Status** | ❌ Open — acceptable for v1.0 (no billing yet), **must fix before billing** |
| **File** | `app/lib/features/settings/settings_provider.dart` lines 92–93, 130–133 |
| **Category** | Premium bypass / auth bypass |
| **Confidence** | 10/10 |

**What:** `isPremium` is a plain boolean stored in an unencrypted Hive box. Any rooted device user or Frida hook can flip it to `true`. There is no server-side re-verification on launch.

**Why it matters (when billing goes live):** A user who paid nothing can unlock all Pro features indefinitely. Financial impact scales directly with user count.

**Fix:** When billing is wired, replace the Hive boolean with a Firebase custom claim or Firestore lookup verified on every sign-in. The local value becomes a cached hint, not the authority.

**Owner:** Claude (implement Firestore Pro check when billing session starts)
**Blocker for:** Billing / v1.1

---

## Finding 3 — Pro email whitelist hardcoded in public git repo
| Field | Detail |
|-------|--------|
| **Severity** | 🟡 MEDIUM |
| **Status** | ❌ Open |
| **File** | `app/lib/services/auth_service.dart` lines 18–21 |
| **Category** | Information disclosure / hardcoded secret |
| **Confidence** | 8/10 |

**What:** `_proEmails` contains two personal Gmail addresses in plaintext, committed to a public GitHub repo. Anyone can read them.

**Why it matters:**
1. The email addresses are discoverable — phishing/social engineering target for developer accounts.
2. If the list is ever expanded to include paying customers' emails, their PII leaks publicly.
3. An attacker who gains access to either Google account gets automatic Pro access.

**Fix (short-term):** Gitignore `auth_service.dart` or move the whitelist to a gitignored file (same pattern as `paywall_screen.dart`).
**Fix (long-term):** Move Pro status to Firestore — same fix as Finding 2. The email list disappears entirely from the codebase.

**Owner:** Claude
**Blocker for:** Expanding tester list / billing

---

## Finding 4 — Premium feature routes have no server-side guard
| Field | Detail |
|-------|--------|
| **Severity** | 🟡 MEDIUM |
| **Status** | ❌ Open — acceptable for v1.0, fix before billing |
| **File** | `app/lib/app/routes.dart` + `app/lib/features/events/event_form_screen.dart` |
| **Category** | Auth bypass |
| **Confidence** | 8/10 |

**What:** Routes `/events/new`, `/events/:id`, `/todos/new`, `/todos/:id` have no GoRouter redirect guard. A user who navigates directly (deep link or modified app) can open `EventFormScreen` and create events without being premium.

**Why it matters:** Bypasses the paywall for the core Pro feature (tithi-based personal events + reminders) without any account or payment.

**Fix:** Add a GoRouter `redirect` for all `/events/*` and `/todos/*` routes:
```dart
redirect: (context, state) {
  final isPremium = container.read(settingsProvider).isPremium;
  if (!isPremium) return '/pro';
  return null;
},
```
Or wrap `EventFormScreen` and `TodoFormScreen` body with `PremiumGuard`.

**Owner:** Claude
**Blocker for:** Billing / v1.1

---

## Items Reviewed — No Finding

| Item | Result |
|------|--------|
| `firebase_options.dart` | Gitignored, never committed ✅ |
| `google-services.json` | Gitignored ✅ |
| `AndroidManifest.xml` exported components | Correct `exported` attrs on receivers ✅ |
| ProGuard rules | Correctly configured for GSON/notifications ✅ |
| Hive unencrypted storage | Event names + preferences only, not PII/credentials ✅ |
| Firebase Auth token handling | Handled by Firebase SDK, not stored manually ✅ |

---

## Fix Priority Order (pre-launch)

| Priority | Finding | When |
|----------|---------|------|
| 1 | Finding 1 — debug keystore | **Before Play Store submission** |
| 2 | Finding 3 — email whitelist in git | **Before expanding tester list** |
| 3 | Finding 2 — client-side isPremium | **Before billing goes live** |
| 4 | Finding 4 — no route guards | **Before billing goes live** |
