---
name: build-release
description: Build release APK and install on connected Android device
---

Build and install the Panchangam release APK.

**Paths:**
- App: `/var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app`
- ADB: `/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb`
- Device: `10BDAH07CM000MQ`

**Steps:**
1. `cd /var/home/srikarbuddhiraju/Srikar/Repo/Panchangam/app`
2. `flutter build apk --release`
3. If build succeeds: report APK size from `build/app/outputs/flutter-apk/app-release.apk`
4. `/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ install -r build/app/outputs/flutter-apk/app-release.apk`
5. Confirm: "Installed successfully" or show error

**If build fails:** show the error clearly. Do NOT attempt fixes without Srikar's confirmation (Rule #5).

**Remember:** Release builds use R8/ProGuard. Any plugin using GSON/reflection may behave
differently from debug. If a `PlatformException` or class-not-found appears only in release,
check `android/app/proguard-rules.pro` first (Rule #8).
