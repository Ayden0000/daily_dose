import 'dart:async';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// Audio service for meditation timer
///
/// Provides 50 BPM metronome tick for breathing rhythm.
/// Uses just_audio for cross-platform audio playback.
class AudioService extends GetxService {
  AudioPlayer? _player;
  Timer? _tickTimer;
  bool _isEnabled = true;

  /// Whether audio cues are enabled
  bool get isEnabled => _isEnabled;

  /// Set audio enabled state
  set isEnabled(bool value) {
    _isEnabled = value;
    if (!value) {
      stop();
    }
  }

  /// Initialize audio player
  Future<void> init() async {
    _player = AudioPlayer();
    try {
      await _player?.setAsset('assets/audio/tick.mp3');
    } catch (e) {
      // Asset may not exist yet — will be silent until provided
    }
  }

  /// Start playing metronome at 50 BPM (1 tick every 1.2 seconds)
  void startMetronome() {
    if (!_isEnabled) return;

    stop();

    // 50 BPM = 1 tick every 1200ms
    const tickInterval = Duration(milliseconds: 1200);

    _playTick();

    _tickTimer = Timer.periodic(tickInterval, (_) {
      _playTick();
    });
  }

  /// Play a single tick sound
  Future<void> _playTick() async {
    if (!_isEnabled || _player == null) return;

    try {
      await _player?.seek(Duration.zero);
      await _player?.play();
    } catch (e) {
      // Silent fail — audio is optional
    }
  }

  /// Play a transition sound (phase change)
  Future<void> playTransition() async {
    if (!_isEnabled) return;
    await _playTick();
  }

  /// Stop all audio playback
  void stop() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _player?.stop();
  }

  @override
  void onClose() {
    stop();
    _player?.dispose();
    super.onClose();
  }
}
