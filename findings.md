# Findings & Root Cause Analysis

## 1. Startup Delay Root Cause
- When `windowDisablePreview="true"` and `windowIsTranslucent="true"` are set in Android `LaunchTheme`:
  - Android WindowManager does not display any window preview when the user touches the app icon.
  - The OS keeps the user on the home screen while the Flutter engine boots, loads native Impeller Vulkan libraries, initializes Dart VM, and renders the first frame (~1.8 seconds).
  - From the user's perspective, tapping the app icon causes a 2-second frozen lag before the window suddenly opens.
- The correct Android design:
  - Remove `windowDisablePreview` and `windowIsTranslucent`.
  - Set `LaunchTheme` `windowBackground` to `@color/splash_background` (`#E0F2FE`).
  - In `values-v31/styles.xml`, set `windowSplashScreenBackground` to `@color/splash_background` and `windowSplashScreenAnimatedIcon` to `@drawable/transparent_1px`.
  - Window appears instantly (0ms delay) on icon touch, showing the `#E0F2FE` soft morning sky color with NO white screen and NO circular icon, and instantly hands off to the custom Flutter animated `SplashScreen`.

## 2. Audio Interruption Root Cause
- **Why did SFX stop?**
  In audioplayers 6.1.0 on Android, `PlayerMode.lowLatency` uses `SoundPoolPlayer.kt`. Once a sound finishes playing, calling `play()` again calls `soundPool.resume(streamId)` on a completed stream instead of `soundPool.play()`. On Android, `resume()` on a finished stream produces silence. Therefore, all SFX stopped working.
- **Why did button clicks pause BGM?**
  1. Single SFX player: Playing any button click cut off active game sounds.
  2. Audio focus conflict: When SFX played with default focus attributes, Android requested audio focus, sending `AUDIOFOCUS_LOSS` to `_bgmPlayer` and pausing it.
  3. OnePlus OxygenOS haptics: Untagged `vibrator.vibrate(effect)` in `MainActivity.kt` triggered `OplusSoundVibrateManager`, which ducks or mutes media playback during vibration events unless tagged with `USAGE_TOUCH`.
- **Solution:**
  1. Return all players to reliable `PlayerMode.mediaPlayer`.
  2. Implement a bounded SFX pool: 1 dedicated UI player for button clicks/taps, and 4 round-robin players for game events (`word_found`, `level_win`, `hint`, `error`). Button clicks never cut off game SFX.
  3. Set `AudioContextAndroid` with `audioFocus: AndroidAudioFocus.none` globally and per-player so neither BGM nor SFX ever requests or loses focus.
  4. Tag native haptics in `MainActivity.kt` with `VibrationAttributes.USAGE_TOUCH` (API 33+) or `AudioAttributes.USAGE_ASSISTANCE_SONIFICATION` (API 26-32) to prevent OxygenOS from ducking media.
  5. Use `ReleaseMode.stop` for BGM and cleanly advance the shuffled playlist via `onPlayerComplete`.

## 3. Game Classification Root Cause
- Standard Android manifest attributes:
  - `android:isGame="true"` (API 21+)
  - `android:appCategory="game"` (API 26+)
  Both attributes are valid and correctly present in `<application>`.
- The intent-filter `<category android:name="android.intent.category.GAME" />` inside the launcher activity is non-standard for mobile phone launchers and can be cleaned up.
- Google Play Console app categorization (Game > Word / Puzzle) must be configured in the developer dashboard.
