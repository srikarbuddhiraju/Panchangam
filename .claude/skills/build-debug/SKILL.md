---
name: build-debug
description: Build debug APK and install on connected Android device
---

Build and install the Panchangam debug APK.

**Paths:**
- App: `/var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app`
- ADB: `/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb`
- Device: `10BDAH07CM000MQ`

**Steps:**
1. `cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app`
2. `flutter build apk --debug`
3. If build succeeds: report APK size
4. `/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-debug.apk`
5. Confirm installation

**Note:** Debug builds skip R8/ProGuard — good for fast iteration on Dart errors.
But "works in debug" is never sufficient for notification, persistence, or platform channel code.
Always do a release build (`/build-release`) before marking any session complete (Rule #8).
