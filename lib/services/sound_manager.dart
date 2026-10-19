import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager with WidgetsBindingObserver {
  static final SoundManager instance = SoundManager._internal();

  factory SoundManager() => instance;

  SoundManager._internal();

  static const String _keySound = 'wp_sound_enabled';
  static const String _keyMusic = 'wp_music_enabled';
  static const String _keyHaptics = 'wp_haptics_enabled';

  // ==================== STATE VARIABLES ====================
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isHapticsEnabled = true;
  bool _isBgmPlaying = false;
  bool _isAppInBackground = false;
  bool _isAdShowing = false;
  bool _isInitialized = false;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isHapticsEnabled => _isHapticsEnabled;
  bool get isBgmPlaying => _isBgmPlaying;
  bool get isAdShowing => _isAdShowing;

  // ==================== BGM PLAYLIST ====================
  static const List<String> bgmPlaylist = [
    'sounds/bgm_1.mp3',
    'sounds/bgm_2.mp3',
    'sounds/bgm_3.mp3',
    'sounds/bgm_4.mp3',
    'sounds/bgm_5.mp3',
  ];

  final Random _random = Random();
  List<String> _shuffledPlaylist = [];
  int _currentTrackIndex = 0;
  String? _currentBgmTrack;
  bool _isPlayingNextTrack = false;

  AudioPlayer? _bgmPlayer;

  // ==================== BOUNDED SFX POOL ====================
  // Dedicated UI player for instant, non-blocking button clicks and taps
  AudioPlayer? _uiSfxPlayer;

  // Bounded pool of 4 players for game event sounds (word found, level win, hint, error)
  // Ensures game events overlap naturally without cutting off each other or BGM
  static const int _gamePoolSize = 4;
  final List<AudioPlayer> _gameSfxPool = [];
  int _nextGamePoolIndex = 0;

  // Duplicate suppression
  int _lastSfxTimestamp = 0;
  String? _lastSfxAsset;

  // ==================== INITIALIZATION ====================

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabled = prefs.getBool(_keySound) ?? true;
      _isMusicEnabled = prefs.getBool(_keyMusic) ?? true;
      _isHapticsEnabled = prefs.getBool(_keyHaptics) ?? true;
    } catch (e) {
      debugPrint('[SoundManager] SharedPreferences init error: $e');
    }

    // 1. Configure Global AudioContext: audioFocus.none prevents Android OS from stealing focus or ducking
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
            audioMode: AndroidAudioMode.normal,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {},
          ),
        ),
      );
    } catch (e) {
      debugPrint('[SoundManager] Global AudioContext configuration error: $e');
    }

    // 2. Setup long-lived BGM Player
    _initBgmPlayer();

    // 3. Setup Bounded SFX Pool (all using MediaPlayer with isolated audioFocus: none)
    _initSfxPool();

    // 4. Register App Lifecycle Observer exactly once
    WidgetsBinding.instance.addObserver(this);

    // 5. Start background music if enabled
    if (_isMusicEnabled) {
      startContinuousBgm();
    }
  }

  void _initBgmPlayer() {
    if (_bgmPlayer != null) return;

    final player = AudioPlayer(playerId: 'bgm_player');
    _bgmPlayer = player;

    try {
      player.setPlayerMode(PlayerMode.mediaPlayer);
      player.setReleaseMode(ReleaseMode.stop);
      player.setVolume(0.40);
      player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
            audioMode: AndroidAudioMode.normal,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {},
          ),
        ),
      );

      // Track state changes without aggressive restart loops
      player.onPlayerStateChanged.listen((state) {
        _isBgmPlaying = (state == PlayerState.playing);
      });

      // Track completion cleanly advances to the next track in shuffled playlist
      player.onPlayerComplete.listen((_) {
        if (_isMusicEnabled && !_isAdShowing && !_isAppInBackground) {
          _playNextTrack();
        }
      });
    } catch (e) {
      debugPrint('[SoundManager] BGM player setup error: $e');
    }
  }

  void _initSfxPool() {
    // Dedicated UI player
    if (_uiSfxPlayer == null) {
      final uiPlayer = AudioPlayer(playerId: 'sfx_ui_player');
      _uiSfxPlayer = uiPlayer;
      _configureSfxPlayer(uiPlayer);
    }

    // Game SFX pool
    if (_gameSfxPool.isEmpty) {
      for (int i = 0; i < _gamePoolSize; i++) {
        final poolPlayer = AudioPlayer(playerId: 'sfx_game_player_$i');
        _configureSfxPlayer(poolPlayer);
        _gameSfxPool.add(poolPlayer);
      }
    }
  }

  void _configureSfxPlayer(AudioPlayer player) {
    try {
      player.setPlayerMode(PlayerMode.mediaPlayer);
      player.setReleaseMode(ReleaseMode.stop);
      player.setVolume(0.90);
      player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
            audioMode: AndroidAudioMode.normal,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {},
          ),
        ),
      );
    } catch (e) {
      debugPrint('[SoundManager] SFX player configuration error: $e');
    }
  }

  // ==================== APP LIFECYCLE ====================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _isAppInBackground = true;
        pauseBgm();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Do NOT pause music on inactive or hidden (e.g. dialogs, route transitions, notification peek)
        break;
      case AppLifecycleState.resumed:
        _isAppInBackground = false;
        if (_isMusicEnabled && !_isAdShowing) {
          resumeBgm();
        }
        break;
    }
  }

  // ==================== BGM PLAYLIST CONTROLS ====================

  void _reshufflePlaylist() {
    _shuffledPlaylist = List<String>.from(bgmPlaylist)..shuffle(_random);
    _currentTrackIndex = 0;
  }

  String _getNextTrack() {
    if (_shuffledPlaylist.isEmpty || _currentTrackIndex >= _shuffledPlaylist.length) {
      _reshufflePlaylist();
    }
    final track = _shuffledPlaylist[_currentTrackIndex];
    _currentTrackIndex++;
    return track;
  }

  /// Ensures continuous background music playback across all screens.
  /// Does NOT stop, restart, or interrupt music that is already playing.
  /// If music is paused, resumes smoothly from the paused position.
  Future<void> startContinuousBgm() async {
    if (!_isMusicEnabled || _isAdShowing || _isAppInBackground) return;

    final player = _bgmPlayer;
    if (player == null) {
      _initBgmPlayer();
      await _playNextTrack();
      return;
    }

    // Already playing — keep it smooth, do not interrupt
    if (player.state == PlayerState.playing) {
      _isBgmPlaying = true;
      return;
    }

    // Paused — resume from exact position
    if (player.state == PlayerState.paused && _currentBgmTrack != null) {
      try {
        await player.resume();
        _isBgmPlaying = true;
        return;
      } catch (e) {
        debugPrint('[SoundManager] BGM resume fallback: $e');
      }
    }

    // Stopped or initial — start next track
    await _playNextTrack();
  }

  /// Plays the next track in the shuffled playlist.
  /// Uses ReleaseMode.stop so each song plays completely, then advances.
  Future<void> _playNextTrack() async {
    if (!_isMusicEnabled || _isAppInBackground || _isAdShowing || _isPlayingNextTrack) return;
    _isPlayingNextTrack = true;

    try {
      _initBgmPlayer();
      final player = _bgmPlayer!;

      _currentBgmTrack = _getNextTrack();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource(_currentBgmTrack!));
      _isBgmPlaying = true;
    } catch (e) {
      debugPrint('[SoundManager] BGM play error ($currentTrack): $e');
    } finally {
      _isPlayingNextTrack = false;
    }
  }

  String? get currentTrack => _currentBgmTrack;

  Future<void> playRandomBgm({bool forceNew = false}) async {
    if (!_isMusicEnabled) return;
    if (!forceNew && _bgmPlayer != null && _bgmPlayer!.state == PlayerState.playing) return;

    await _playNextTrack();
  }

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
    } catch (e) {
      debugPrint('[SoundManager] pauseBgm error: $e');
    }
  }

  Future<void> resumeBgm() async {
    if (!_isMusicEnabled || _isAdShowing || _isAppInBackground) return;
    try {
      if (_bgmPlayer != null && _bgmPlayer!.state == PlayerState.paused) {
        await _bgmPlayer!.resume();
        _isBgmPlaying = true;
      } else {
        await startContinuousBgm();
      }
    } catch (e) {
      debugPrint('[SoundManager] resumeBgm error: $e');
      await startContinuousBgm();
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer?.stop();
      _isBgmPlaying = false;
      _currentBgmTrack = null;
    } catch (e) {
      debugPrint('[SoundManager] stopBgm error: $e');
    }
  }

  // ==================== HAPTICS ====================

  static const MethodChannel _hapticsChannel = MethodChannel('com.craftline.wordsearch/haptics');

  Future<void> _triggerNativeHaptics(String style) async {
    if (!_isHapticsEnabled) return;
    try {
      await _hapticsChannel.invokeMethod('impact', {'style': style});
    } catch (_) {
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
    // Letter tap sound removed per user request
  }

  /// UI Button click: uses the dedicated UI player so it never interrupts game victory/word sounds
  Future<void> playButtonClick() async {
    _triggerNativeHaptics('light');
    if (!_isSoundEnabled) return;

    _playUiSfx('sounds/button_click.mp3');
  }

  /// Game Events: use the round-robin game SFX pool so sounds overlap naturally
  Future<void> playWordFound({int streak = 1}) async {
    _triggerNativeHaptics('medium');
    if (!_isSoundEnabled) return;

    _playGameSfx('sounds/word_found.mp3');
  }

  Future<void> playHint() async {
    _triggerNativeHaptics('light');
    if (!_isSoundEnabled) return;

    _playGameSfx('sounds/hint.mp3');
  }

  Future<void> playLevelWin() async {
    _triggerNativeHaptics('heavy');
    if (!_isSoundEnabled) return;

    _playGameSfx('sounds/level_win.mp3');
  }

  Future<void> playVictoryFanfare() async {
    await playLevelWin();
  }

  Future<void> playError() async {
    if (_isHapticsEnabled) {
      try {
        _hapticsChannel.invokeMethod('vibrate', {'duration': 50, 'amplitude': 200});
      } catch (_) {
        HapticFeedback.vibrate();
      }
    }
    if (!_isSoundEnabled) return;

    _playGameSfx('sounds/error.mp3');
  }

  /// Dedicated UI SFX playback (button clicks):
  /// Rapid clicks only cut off previous button clicks, never BGM or game sounds
  Future<void> _playUiSfx(String assetPath) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (assetPath == _lastSfxAsset && (now - _lastSfxTimestamp) < 60) {
      return; // Safe duplicate suppression for rapid bounce
    }
    _lastSfxTimestamp = now;
    _lastSfxAsset = assetPath;

    try {
      if (_uiSfxPlayer == null) _initSfxPool();
      final player = _uiSfxPlayer;
      if (player == null) return;

      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[SoundManager] UI SFX error ($assetPath): $e');
    }
  }

  /// Game SFX playback (word found, level win, hint, error):
  /// Uses round-robin pool of 4 players so consecutive sounds overlap gracefully without cut-offs
  Future<void> _playGameSfx(String assetPath) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (assetPath == _lastSfxAsset && (now - _lastSfxTimestamp) < 60) {
      return;
    }
    _lastSfxTimestamp = now;
    _lastSfxAsset = assetPath;

    try {
      if (_gameSfxPool.isEmpty) _initSfxPool();
      if (_gameSfxPool.isEmpty) return;

      final player = _gameSfxPool[_nextGamePoolIndex];
      _nextGamePoolIndex = (_nextGamePoolIndex + 1) % _gameSfxPool.length;

      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[SoundManager] Game SFX error ($assetPath): $e');
    }
  }

  // ==================== SETTINGS TOGGLES ====================

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySound, enabled);
    } catch (e) {
      debugPrint('[SoundManager] Save sound setting error: $e');
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyMusic, enabled);
    } catch (e) {
      debugPrint('[SoundManager] Save music setting error: $e');
    }

    if (enabled) {
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
    } catch (e) {
      debugPrint('[SoundManager] Save haptics setting error: $e');
    }
    if (enabled) {
      _triggerNativeHaptics('medium');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _bgmPlayer?.dispose();
      _bgmPlayer = null;
      _uiSfxPlayer?.dispose();
      _uiSfxPlayer = null;
      for (final p in _gameSfxPool) {
        p.dispose();
      }
      _gameSfxPool.clear();
      _isInitialized = false;
    } catch (e) {
      debugPrint('[SoundManager] Dispose error: $e');
    }
  }
}
