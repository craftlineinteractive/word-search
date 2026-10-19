# Complete Production Fix: Audio Reliability, Startup Performance & Game Classification

## 1. Problem Statement & Audit Summary
1. **Background Music Stops on Button Click & SFX Silenced:**
   - Root Cause A: In `sound_manager.dart`, SFX player was set to `PlayerMode.lowLatency`. Audioplayers' Android implementation `SoundPoolPlayer.kt` has a known bug where it calls `soundPool.resume(streamId)` on finished one-shots and never plays subsequent sounds.
   - Root Cause B: Using a single `AudioPlayer` for SFX meant that button clicks cut off other active sound effects (victory, word found, hints).
   - Root Cause C: Both BGM and SFX must use `AudioContext` with `audioFocus: AndroidAudioFocus.none` so neither stream requests focus or pauses the other.
   - Root Cause D: In `MainActivity.kt`, native haptics `vibrator.vibrate(effect)` lacked `VibrationAttributes.USAGE_TOUCH`. On OxygenOS (OnePlus 8T), untagged vibration triggered `OplusSoundVibrateManager` which temporarily ducked/paused media streams.
   - Root Cause E: Uncontrolled watchdog in `onPlayerStateChanged` was restarting tracks prematurely. Looping mode conflicted with playlist completion handling.

2. **Two-Second Startup Delay on App Launch:**
   - Root Cause A: In `android/app/src/main/res/values/styles.xml` and `values-v31/styles.xml`, `windowDisablePreview: true` and `windowIsTranslucent: true` were set. This forced Android WindowManager to delay showing ANY window preview until Flutter cold-started and rendered frame 1 (~1.8 seconds), causing a 2-second frozen lag on the phone launcher.
   - Root Cause B: In `lib/main.dart`, `await AudioPlayer.global.setAudioContext(...)` was blocking before `runApp()`.
   - Solution: Remove `windowDisablePreview` and `windowIsTranslucent`. Configure `LaunchTheme` with `#E0F2FE` (matching the custom splash background), with `transparent_1px` icon on Android 12+. When tapped, the window opens in 0ms (instantaneous), and smoothly transitions into the custom animated Flutter splash screen with zero white screen, zero circular icon, and zero startup lag.

3. **Game Classification:**
   - Configure `<application android:isGame="true" android:appCategory="game">` in `AndroidManifest.xml`.
   - Provide exact Google Play Console manual steps for Game > Word / Puzzle.
   - Document OEM phone game hub discovery mechanisms and constraints.

## 2. Implementation Tasks

### Task 1: Android Native Startup & Theme Optimization
- File: `android/app/src/main/res/values/styles.xml`
- File: `android/app/src/main/res/values-v31/styles.xml`
- File: `android/app/src/main/res/values-night/styles.xml`
- Remove `windowDisablePreview` and `windowIsTranslucent`.
- Set `windowBackground` to `@color/splash_background` (`#E0F2FE`).
- Keep `windowSplashScreenBackground` as `@color/splash_background` and `windowSplashScreenAnimatedIcon` as `@drawable/transparent_1px`.
- Result: Window appears instantly (0ms delay) with `#E0F2FE` background and seamless handoff to Flutter.

### Task 2: Native Android Haptics Fix (Touch Attributes)
- File: `android/app/src/main/kotlin/com/craftlineinteractive/wordpuzzle/word_puzzle/MainActivity.kt`
- Update `triggerVibration`:
  - Android 13+ (API 33+): Use `VibrationAttributes.Builder().setUsage(VibrationAttributes.USAGE_TOUCH).build()`.
  - Android 8.0-12 (API 26-32): Use `AudioAttributes.Builder().setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION).build()`.
- Result: OxygenOS `OplusSoundVibrateManager` will never pause or duck media playback during button clicks.

### Task 3: Cold Startup Optimization in Flutter
- File: `lib/main.dart`
- Call `runApp(const WordPuzzleApp())` immediately after `WidgetsFlutterBinding.ensureInitialized()`.
- Move `AudioPlayer.global.setAudioContext` into `SoundManager.init()`.
- Result: Reduces cold start Dart time to the first frame.

### Task 4: Comprehensive Audio System Architecture in `SoundManager`
- File: `lib/services/sound_manager.dart`
- BGM Player:
  - Long-lived singleton `AudioPlayer(playerId: 'bgm_player')` with `PlayerMode.mediaPlayer`.
  - `ReleaseMode.stop` with reliable `onPlayerComplete` listener for advancing the 5-track shuffled playlist.
  - Position-preserving pause and resume on app lifecycle (`paused`/`resumed`) and ads (`setAdShowing`).
  - No uncontrolled watchdogs.
- SFX Players:
  - Bounded pool:
    - 1 dedicated UI player for button clicks / letter taps (`ReleaseMode.stop`, `PlayerMode.mediaPlayer`).
    - 4 round-robin game SFX players for `word_found`, `level_win`, `hint`, `error` (`ReleaseMode.stop`, `PlayerMode.mediaPlayer`).
  - All players configured with `AudioContextAndroid(audioFocus: AndroidAudioFocus.none)`.
  - Safe duplicate suppression for identical sounds within 60ms.
- Lifecycle:
  - Only pause on `AppLifecycleState.paused` and `detached`.
  - Resume on `AppLifecycleState.resumed` if music is enabled and ad is not showing.

### Task 5: Game Classification Configuration
- File: `android/app/src/main/AndroidManifest.xml`
- Verify `android:isGame="true"` and `android:appCategory="game"`.
- Clean up any invalid intent categories.

### Task 6: Verification, Performance Profiling & Device Testing
- Run `flutter analyze`.
- Run automated tests (`flutter test`).
- Build APK and install on physical OnePlus 8T device (`ff6c260c`).
- Measure startup time via `adb shell am start-activity -W`.
- Test continuous BGM across multiple button clicks, screen navigation, and gameplay.
- Produce comprehensive final report.
