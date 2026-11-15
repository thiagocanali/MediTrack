# Reminder implementation status

This PR adds a tested, pure-Dart wall-clock schedule model only. **No notification
is scheduled by this change.** Do not claim reminders are working yet.

## Remaining integration work

1. Decide and validate a schedule schema (multiple daily times, weekdays,
   start/end dates and user timezone) and enforce it in Firestore rules.
2. Implement permission requests for Android 13+ and iOS; verify platform
   configuration, notification channels and exact-alarm restrictions.
3. Use stable per-occurrence notification identifiers; avoid ID 0 and
   `cancelAll()`. Test collisions and edits/deletions.
4. Schedule with timezone-aware notifications, including DST and travel
   changes, and reconcile after restart/reboot.
5. Add integration tests on actual Android and iOS devices.
6. Never interpret an alarm as proof a medication was taken. Dose
   confirmation must be an explicit user action.
