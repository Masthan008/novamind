# Sound Assets Usage Analysis

After removing the Calendar and Focus Forest features, we analyzed the entire project to determine where sound assets (`assets/sounds/`) were still being referenced.

## Current Usages Discovered

1.  **`lib/modules/alarm/alarm_provider.dart`**
    *   This file provides alarm functionality and references 20 alarm sounds (`alarm_1.mp3` through `alarm_20.mp3`).
    *   *Status*: Since the Alarm UI is not present/active, this is dead code holding onto the assets.

2.  **`lib/providers/notification_provider.dart`**
    *   This provider handles local notifications and is specifically configured to play custom sounds (`sounds/alarm_1.mp3` to `sounds/alarm_8.mp3`) for reminders.
    *   *Status*: Can be refactored to use system default notification sounds instead of bundled MP3 files.

3.  **`lib/providers/focus_provider.dart`**
    *   This state management file previously backed the `Focus Forest` feature, providing ambient sounds (`rain.mp3`, `fire.mp3`, `night.mp3`, `library.mp3`).
    *   *Status*: The UI (`focus_forest_screen.dart`) was deleted, making this entire provider dead code, though it is still imported in `main.dart`.

4.  **`lib/services/audio_preview_service.dart`**
    *   A service designed to play and stop audio previews (MP3 files) from the assets.
    *   *Status*: With custom alarm/focus sounds removed, this service is no longer needed.

5.  **`pubspec.yaml`**
    *   The `assets/sounds/` directory is still registered here.

## Action Plan (Executing Now)

Per your request, we are removing the `assets/sounds` directory and all associated dead code:

*   [x] Create this analysis file.
*   [ ] Delete the `assets/sounds` folder from the disk.
*   [ ] Remove `- assets/sounds/` from `pubspec.yaml`.
*   [ ] Delete `lib/modules/alarm/` (dead code).
*   [ ] Delete `lib/providers/focus_provider.dart` and remove its usage from `main.dart`.
*   [ ] Delete `lib/services/audio_preview_service.dart`.
*   [ ] Update `lib/providers/notification_provider.dart` to use default OS notification sounds instead of the bundled assets.
*   [ ] Update `prd.md` to reflect the removal of Alarm, Focus Forest, Calendar, and custom sound features.
*   [ ] Verify `about_screen.dart` has no remaining mentions (it appears clear already).
