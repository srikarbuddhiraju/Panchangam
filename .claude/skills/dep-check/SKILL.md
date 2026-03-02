---
name: dep-check
description: Audit dependencies for bloat, security issues, and outdated packages
---

## Dependency Check — Light & Secure Audit

### Step 1 — List all dependencies
```bash
cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app
dart pub deps
```

### Step 2 — Check for outdated packages
```bash
dart pub outdated
```
Flag any packages with major version behind or known security advisories.

### Step 3 — Audit each direct dependency
For each package in `pubspec.yaml` (not dev_dependencies):
- Is it still needed? (search codebase for usage)
- Is there a Flutter built-in that does the same thing?
- Does it add platform-native code (Android/iOS) that could fail in release builds?
  → If yes: must test in `flutter build apk --release` (Hard Rule #8)

### Step 4 — Check paywall files are still gitignored
```bash
git status | grep paywall
git ls-files --error-unmatch app/lib/features/premium/paywall_screen.dart 2>&1
```
If either file appears in `git status` as tracked, STOP and fix `.gitignore` immediately.

### Step 5 — ProGuard/R8 check for reflection-heavy packages
Any package using GSON, serialization, or reflection needs a ProGuard rule.
Check `app/android/app/proguard-rules.pro` covers all such packages.
(Hard Rule #7: check library's GitHub issues before writing ProGuard rules)

### Step 6 — Report
List: package name | version | size impact | verdict (keep / replace / remove / update)
