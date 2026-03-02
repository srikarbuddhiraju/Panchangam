---
name: notify-test
description: Device notification test checklist — never mark complete without device confirmation
---

Run the Panchangam notification test checklist.

**Hard Rule #6:** Notifications are ONLY verified by device test. Code passing = nothing.

**Checklist (work through each with Srikar):**

1. **Permission check**
   Open Settings in app → Notifications tile.
   Expected: green tile, permission granted.
   If red banner: tap to open system notification settings, grant permission, restart app.

2. **Immediate notification**
   Tap "Test" button in Settings.
   Expected: notification appears within 2 seconds.
   Channel: `panchangam_reminders`

3. **Scheduled notification (~1 min)**
   Tap "Sched." button in Settings.
   Expected: notification fires approximately 1 minute later.
   This tests `zonedSchedule` + `AndroidScheduleMode.inexact`.

4. **Alarm mode**
   Create an event with ReminderType.alarm.
   Expected: fires at exact time with alarm ringtone (system alarm sound).
   Channel: `panchangam_alarms` (AudioAttributesUsage.alarm, Importance.max, fullScreenIntent)

5. **Boot persistence**
   Reboot device. Open app to trigger reschedule.
   Check if previously scheduled events are rescheduled.
   Boot receiver: `ScheduledNotificationBootReceiver` (must be `exported=true`)

**If anything fails — surface the error first:**
```
/home/srikarbuddhiraju/Android/Sdk/platform-tools/adb -s 10BDAH07CM000MQ logcat | grep -iE "notification|alarm|flutter"
```
Read the error. Then propose a fix. Never guess (Rule #1).
