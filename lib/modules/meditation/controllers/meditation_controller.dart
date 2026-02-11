import 'dart:async';
import 'package:get/get.dart';
import 'package:daily_dose/data/models/breathing_pattern_model.dart';
import 'package:daily_dose/data/repositories/meditation_repository.dart';
import 'package:daily_dose/data/services/audio_service.dart';
import 'package:daily_dose/data/services/vibration_service.dart';

/// Breathing phases for the meditation timer
enum BreathingPhase { idle, inhale, hold1, exhale, hold2 }

/// Timer states
enum TimerState { idle, running, paused }

/// Controller for Meditation module
///
/// Manages breathing timer, pattern selection, and session tracking.
/// Phase durations are in beats at 50 BPM (1.2 seconds per beat).
/// The countdown displays beats remaining — matching the pattern numbers.
class MeditationController extends GetxController {
  final MeditationRepository _meditationRepository;
  final AudioService _audioService;
  final VibrationService _vibrationService;

  MeditationController({
    required MeditationRepository meditationRepository,
    required AudioService audioService,
    required VibrationService vibrationService,
  }) : _meditationRepository = meditationRepository,
       _audioService = audioService,
       _vibrationService = vibrationService;

  // ============ CONSTANTS ============

  /// Beat interval at 50 BPM = 1200 ms per beat
  static const int beatIntervalMs = 1200;

  // ============ REACTIVE STATE ============

  final Rx<TimerState> timerState = TimerState.idle.obs;
  final Rx<BreathingPhase> currentPhase = BreathingPhase.idle.obs;
  final RxDouble phaseProgress = 0.0.obs;
  final RxInt beatsRemaining = 0.obs;
  final RxInt completedCycles = 0.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxBool audioEnabled = true.obs;
  final RxBool vibrationEnabled = true.obs;

  // Pattern state
  final RxList<BreathingPatternModel> patterns = <BreathingPatternModel>[].obs;
  final Rx<BreathingPatternModel?> selectedPattern = Rx<BreathingPatternModel?>(
    null,
  );

  // ============ INTERNAL STATE ============

  Timer? _phaseTimer;
  Timer? _elapsedTimer;
  int _currentBeat = 0;
  int _totalBeatsInPhase = 0;
  DateTime? _sessionStartTime;

  // ============ COMPUTED GETTERS ============

  bool get isIdle => timerState.value == TimerState.idle;
  bool get isRunning => timerState.value == TimerState.running;
  bool get isPaused => timerState.value == TimerState.paused;

  String get phaseLabel {
    switch (currentPhase.value) {
      case BreathingPhase.idle:
        return 'Ready';
      case BreathingPhase.inhale:
        return 'Inhale';
      case BreathingPhase.hold1:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Exhale';
      case BreathingPhase.hold2:
        return 'Hold';
    }
  }

  String get formattedElapsedTime {
    final mins = elapsedSeconds.value ~/ 60;
    final secs = elapsedSeconds.value % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    _loadPatterns();
  }

  @override
  void onClose() {
    _stopTimers();
    super.onClose();
  }

  // ============ PATTERN MANAGEMENT ============

  void _loadPatterns() {
    patterns.value = _meditationRepository.getAllPatterns();
    if (patterns.isNotEmpty) {
      selectedPattern.value = patterns.first;
    }
  }

  void selectPattern(BreathingPatternModel pattern) {
    if (isIdle) {
      selectedPattern.value = pattern;
    }
  }

  /// Delete a custom pattern
  Future<void> deletePattern(String id) async {
    await _meditationRepository.deletePattern(id);
    _loadPatterns();
  }

  /// Create a custom breathing pattern
  Future<void> createCustomPattern({
    required String name,
    required int inhale,
    required int hold1,
    required int exhale,
    required int hold2,
  }) async {
    await _meditationRepository.createPattern(
      name: name,
      inhale: inhale,
      hold1: hold1,
      exhale: exhale,
      hold2: hold2,
    );
    _loadPatterns();
  }

  // ============ TIMER CONTROLS ============

  /// Start the meditation session
  void start() {
    final pattern = selectedPattern.value;
    if (pattern == null) return;

    _sessionStartTime = DateTime.now();
    completedCycles.value = 0;
    elapsedSeconds.value = 0;
    timerState.value = TimerState.running;

    // Start audio metronome
    if (audioEnabled.value) {
      _audioService.startMetronome();
    }

    // Start elapsed time counter
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });

    // Begin first phase
    _startPhase(BreathingPhase.inhale);
  }

  /// Pause the session
  void pause() {
    timerState.value = TimerState.paused;
    _phaseTimer?.cancel();
    _elapsedTimer?.cancel();
    _audioService.stop();
  }

  /// Resume the session
  void resume() {
    timerState.value = TimerState.running;

    if (audioEnabled.value) {
      _audioService.startMetronome();
    }

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });

    // Resume current phase with remaining beats
    _resumePhase();
  }

  /// Stop the session and save
  void stop() {
    final duration = elapsedSeconds.value;
    _stopTimers();

    // Save session if meaningful (> 10 seconds)
    if (duration > 10 &&
        _sessionStartTime != null &&
        selectedPattern.value != null) {
      _meditationRepository.recordSession(
        patternId: selectedPattern.value!.id,
        patternName: selectedPattern.value!.name,
        durationSeconds: duration,
        completedCycles: completedCycles.value,
      );
    }

    // Reset state
    timerState.value = TimerState.idle;
    currentPhase.value = BreathingPhase.idle;
    phaseProgress.value = 0.0;
    beatsRemaining.value = 0;
    completedCycles.value = 0;
    elapsedSeconds.value = 0;
  }

  // ============ PHASE MANAGEMENT ============

  void _startPhase(BreathingPhase phase) {
    currentPhase.value = phase;
    _currentBeat = 0;
    _totalBeatsInPhase = _getBeatsForPhase(phase);

    if (_totalBeatsInPhase == 0) {
      _advanceToNextPhase();
      return;
    }

    beatsRemaining.value = _totalBeatsInPhase;
    phaseProgress.value = 0.0;

    // Vibrate on phase transition
    if (vibrationEnabled.value) {
      _vibrationService.vibrateShort();
    }

    // Tick at exactly 50 BPM (1.2s per beat)
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(
      const Duration(milliseconds: beatIntervalMs),
      (_) => _onBeat(),
    );
  }

  void _onBeat() {
    _currentBeat++;
    phaseProgress.value = _currentBeat / _totalBeatsInPhase;
    beatsRemaining.value = _totalBeatsInPhase - _currentBeat;

    if (_currentBeat >= _totalBeatsInPhase) {
      _phaseTimer?.cancel();
      beatsRemaining.value = 0;
      _advanceToNextPhase();
    }
  }

  void _resumePhase() {
    final remaining = _totalBeatsInPhase - _currentBeat;
    if (remaining <= 0) {
      _advanceToNextPhase();
      return;
    }

    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(
      const Duration(milliseconds: beatIntervalMs),
      (_) => _onBeat(),
    );
  }

  void _advanceToNextPhase() {
    switch (currentPhase.value) {
      case BreathingPhase.inhale:
        _startPhase(BreathingPhase.hold1);
        break;
      case BreathingPhase.hold1:
        _startPhase(BreathingPhase.exhale);
        break;
      case BreathingPhase.exhale:
        _startPhase(BreathingPhase.hold2);
        break;
      case BreathingPhase.hold2:
        completedCycles.value++;
        _startPhase(BreathingPhase.inhale);
        break;
      case BreathingPhase.idle:
        break;
    }
  }

  int _getBeatsForPhase(BreathingPhase phase) {
    final pattern = selectedPattern.value;
    if (pattern == null) return 0;

    switch (phase) {
      case BreathingPhase.inhale:
        return pattern.inhale;
      case BreathingPhase.hold1:
        return pattern.hold1;
      case BreathingPhase.exhale:
        return pattern.exhale;
      case BreathingPhase.hold2:
        return pattern.hold2;
      case BreathingPhase.idle:
        return 0;
    }
  }

  // ============ SETTINGS ============

  void toggleAudio() {
    audioEnabled.value = !audioEnabled.value;
    _audioService.isEnabled = audioEnabled.value;
    if (isRunning) {
      if (audioEnabled.value) {
        _audioService.startMetronome();
      } else {
        _audioService.stop();
      }
    }
  }

  void toggleVibration() {
    vibrationEnabled.value = !vibrationEnabled.value;
  }

  // ============ CLEANUP ============

  void _stopTimers() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _audioService.stop();
  }
}
