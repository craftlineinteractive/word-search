import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager with WidgetsBindingObserver {
  static final SoundManager instance = SoundManager._internal();

  factory SoundManager() => instance;

  SoundManager._internal();

  static const String _keySound = 'wp_sound_enabled';
  static const String _keyMusic = 'wp_music_enabled';
  static const String _keyHaptics = 'wp_haptics_enabled';

  AudioPlayer? _sfxPlayer;
  AudioPlayer? _bgmPlayer;
  final Random _random = Random();
  int _sfxSequence = 0;

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isHapticsEnabled = true;
  bool _isBgmPlaying = false;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isHapticsEnabled => _isHapticsEnabled;
  bool get isBgmPlaying => _isBgmPlaying;

  /// All 5 background music tracks available in assets/sounds/
  static const List<String> bgmPlaylist = [
    'sounds/bgm_1.mp3',
    'sounds/bgm_2.mp3',
    'sounds/bgm_3.mp3',
    'sounds/bgm_4.mp3',
    'sounds/bgm_5.mp3',
  ];

  /// Shuffled playlist for cycling through all 5 tracks
  List<String> _shuffledPlaylist = [];
  int _currentTrackIndex = 0;
  String? _currentBgmTrack;
  bool _bgmListenerRegistered = false;

  /// Creates a new shuffled order of the 5 BGM tracks
  void _reshufflePlaylist() {
    _shuffledPlaylist = List<String>.from(bgmPlaylist)..shuffle(_random);
    _currentTrackIndex = 0;
  }

  /// Gets the next track from the shuffled playlist, reshuffling when all tracks have played
  String _getNextTrack() {
    if (_shuffledPlaylist.isEmpty || _currentTrackIndex >= _shuffledPlaylist.length) {
      _reshufflePlaylist();
    }
    final track = _shuffledPlaylist[_currentTrackIndex];
    _currentTrackIndex++;
    return track;
  }

  AudioPlayer get _getBgmPlayer {
    if (_bgmPlayer == null) {
      _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
      _bgmPlayer!.setVolume(0.40);
      _bgmPlayer!.onPlayerStateChanged.listen((state) {
        _isBgmPlaying = (state == PlayerState.playing);
      });
    }
    return _bgmPlayer!;
  }

  /// Registers the onPlayerComplete listener once to auto-advance to next track
  void _ensureBgmCompletionListener() {
    if (_bgmListenerRegistered) return;
    _bgmListenerRegistered = true;

    _getBgmPlayer.onPlayerComplete.listen((_) {
      // When current track finishes, play the next one from shuffled playlist
      if (_isMusicEnabled && !_isAdShowing) {
        _playNextTrack();
      }
    });
  }

  /// Plays the next track in the shuffled playlist
  Future<void> _playNextTrack() async {
    if (!_isMusicEnabled) return;
    try {
      _currentBgmTrack = _getNextTrack();
      final player = _getBgmPlayer;
      await player.stop();
      await player.setSource(AssetSource(_currentBgmTrack!));
      // Use release mode 'stop' so onPlayerComplete fires (loop mode never fires it)
      await player.setReleaseMode(ReleaseMode.stop);
      await player.resume();
      _isBgmPlaying = true;
    } catch (_) {}
  }

  AudioPlayer get _getSfxPlayer {
    if (_sfxPlayer == null) {
      _sfxPlayer = AudioPlayer(playerId: 'sfx_player');
      _sfxPlayer!.setVolume(0.9);
    }
    return _sfxPlayer!;
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool(_keySound) ?? true;
      _isMusicEnabled = prefs.getBool(_keyMusic) ?? true;
      _isHapticsEnabled = prefs.getBool(_keyHaptics) ?? true;

      // Configure Global Audio Context for non-stealing BGM and SFX mixing
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none, // Never steal audio focus
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );

      final sfx = _getSfxPlayer;
      await sfx.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none, // SFX will NEVER interrupt BGM
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );

      final bgm = _getBgmPlayer;
      await bgm.setVolume(0.40);

      // Register the completion listener for auto-advancing tracks
      _ensureBgmCompletionListener();

      WidgetsBinding.instance.addObserver(this);

      if (_isMusicEnabled) {
        startContinuousBgm();
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      pauseBgm();
    } else if (state == AppLifecycleState.resumed) {
      if (_isMusicEnabled && !_isAdShowing) {
        resumeBgm();
      }
    }
  }

  // ==================== BGM CONTROLS ====================

  /// Ensures continuous background music playback across all screens.
  /// Does NOT stop, restart, or interrupt music that is already playing.
  /// If music is paused (e.g., after ad dismissed or app resumed), it resumes smoothly.
  /// If no music was ever started, picks the next track from the shuffled playlist.
  Future<void> startContinuousBgm() async {
    if (!_isMusicEnabled) return;

    // Already playing — do nothing, keep it smooth
    if (_bgmPlayer != null && _bgmPlayer!.state == PlayerState.playing) {
      _isBgmPlaying = true;
      return;
    }

    // Paused — just resume from where it left off
    if (_bgmPlayer != null && _bgmPlayer!.state == PlayerState.paused && _currentBgmTrack != null) {
      try {
        await _bgmPlayer!.resume();
        _isBgmPlaying = true;
        return;
      } catch (_) {}
    }

    // Not playing at all — start the next track from the shuffled playlist
    await _playNextTrack();
  }

  /// Plays a random background music track from the 5 BGM tracks.
  /// Used when explicitly requesting a new random track (e.g., from settings re-enable).
  Future<void> playRandomBgm({bool forceNew = false}) async {
    if (!_isMusicEnabled) return;
    if (!forceNew && _bgmPlayer != null && _bgmPlayer!.state == PlayerState.playing) return;

    await _playNextTrack();
  }

  bool _isAdShowing = false;

  bool get isAdShowing => _isAdShowing;

  Future<void> setAdShowing(bool showing) async {
    _isAdShowing = showing;
    if (showing) {
      await pauseBgm();
    } else {
      await resumeBgm();
    }
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer?.pause();
      _isBgmPlaying = false;
    } catch (_) {}
  }

  Future<void> resumeBgm() async {
    if (!_isMusicEnabled || _isAdShowing) return;
    try {
      if (_currentBgmTrack == null) {
        await _playNextTrack();
      } else {
        await _bgmPlayer?.resume();
        _isBgmPlaying = true;
      }
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer?.stop();
      _isBgmPlaying = false;
      _currentBgmTrack = null;
    } catch (_) {}
  }

  static const MethodChannel _hapticsChannel = MethodChannel('com.craftline.wordsearch/haptics');

  Future<void> _triggerNativeHaptics(String style) async {
    if (!_isHapticsEnabled) return;
    try {
      await _hapticsChannel.invokeMethod('impact', {'style': style});
    } catch (_) {
      // Fallback to Flutter HapticFeedback
      switch (style) {
        case 'light':
          HapticFeedback.lightImpact();
          break;
        case 'medium':
          HapticFeedback.mediumImpact();
          break;
        case 'heavy':
          HapticFeedback.heavyImpact();
          break;
        default:
          HapticFeedback.vibrate();
      }
    }
  }

  // ==================== SFX CONTROLS ====================

  Future<void> playLetterTap() async {
    _triggerNativeHaptics('light');
    if (!_isSoundEnabled) return;

    _playSfx('sounds/tap_letter.mp3');
  }

  Future<void> playButtonClick() async {
    _triggerNativeHaptics('light');
    if (!_isSoundEnabled) return;

    _playSfx('sounds/button_click.mp3');
  }

  Future<void> playWordFound({int streak = 1}) async {
    _triggerNativeHaptics('medium');
    if (!_isSoundEnabled) return;

    _playSfx('sounds/word_found.mp3');
  }

  Future<void> playHint() async {
    _triggerNativeHaptics('light');
    if (!_isSoundEnabled) return;

    _playSfx('sounds/hint.mp3');
  }

  Future<void> playLevelWin() async {
    _triggerNativeHaptics('heavy');
    if (!_isSoundEnabled) return;

    _playSfx('sounds/level_win.mp3');
  }

  Future<void> playError() async {
    if (_isHapticsEnabled) {
      try {
        await _hapticsChannel.invokeMethod('vibrate', {'duration': 50, 'amplitude': 200});
      } catch (_) {
        HapticFeedback.vibrate();
      }
    }
    if (!_isSoundEnabled) return;

    _playSfx('sounds/error.mp3');
  }

  /// Cancels any previous audio playback instantly so rapid clicks only play the latest tap without queuing.
  Future<void> _playSfx(String assetPath) async {
    final currentSeq = ++_sfxSequence;
    try {
      final player = _getSfxPlayer;
      if (currentSeq != _sfxSequence) return;
      await player.stop();
      await player.play(AssetSource(assetPath));
    } catch (_) {}
  }

  // ==================== SETTINGS TOGGLES ====================

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySound, enabled);
    } catch (_) {}
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyMusic, enabled);
    } catch (_) {}

    if (enabled) {
      // Reshuffle and start fresh when re-enabling
      _reshufflePlaylist();
      await _playNextTrack();
    } else {
      await stopBgm();
    }
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _isHapticsEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHaptics, enabled);
    } catch (_) {}
    if (enabled) {
      _triggerNativeHaptics('medium');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sfxPlayer?.dispose();
    _bgmPlayer?.dispose();
  }
}
