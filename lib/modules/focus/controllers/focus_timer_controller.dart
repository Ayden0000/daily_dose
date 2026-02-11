import 'dart:async';
import 'package:get/get.dart';
import 'package:daily_dose/app/config/constants.dart';
import 'package:daily_dose/data/repositories/focus_repository.dart';
import 'package:daily_dose/data/services/notification_service.dart';

/// Controller for Focus Timer (Pomodoro) module
///
/// Manages timer state, phase transitions (focus → short break → long break),
/// and session recording. Timer logic lives here (not in the repo) because
/// it's stateful UI-bound behavior, not data persistence.
///
/// Timer flow:
/// 1. Focus (25 min) → 2. Short Break (5 min) → 3. Focus → ... →
/// 4. After N sessions → Long Break (15 min) → repeat
class FocusTimerController extends GetxController {
  final FocusRepository _focusRepo;
  final NotificationService _notificationService;

  FocusTimerController({
    required FocusRepository focusRepo,
    required NotificationService notificationService,
  }) : _focusRepo = focusRepo,
       _notificationService = notificationService;

  // ============ REACTIVE STATE ============

  final RxInt remainingSeconds = 0.obs;
  final RxInt totalSeconds = 0.obs;
  final RxBool isRunning = false.obs;
  final RxBool isPaused = false.obs;
  final RxString currentPhase = AppConstants.sessionTypeFocus.obs;
  final RxInt completedSessions = 0.obs;
  final RxInt sessionsBeforeLong = AppConstants.sessionsBeforeLongBreak.obs;

  // Timer settings (user-configurable)
  final RxInt focusDuration = AppConstants.defaultFocusDuration.obs;
  final RxInt shortBreakDuration = AppConstants.defaultShortBreak.obs;
  final RxInt longBreakDuration = AppConstants.defaultLongBreak.obs;

  Timer? _timer;
  int _elapsedSeconds = 0;

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    _resetToFocus();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ============ TIMER ACTIONS ============

  /// Start or resume the timer
  void startTimer() {
    if (isRunning.value && !isPaused.value) return;

    if (!isRunning.value) {
      _elapsedSeconds = 0;
    }

    isRunning.value = true;
    isPaused.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
        _elapsedSeconds++;
      } else {
        _onPhaseComplete();
      }
    });
  }

  /// Pause the timer
  void pauseTimer() {
    _timer?.cancel();
    isPaused.value = true;
  }

  /// Resume from pause
  void resumeTimer() {
    startTimer();
  }

  /// Reset the timer to current phase start
  void resetTimer() {
    _timer?.cancel();
    isRunning.value = false;
    isPaused.value = false;
    _elapsedSeconds = 0;
    _setPhaseTime();
  }

  /// Skip to the next phase
  void skipToNext() {
    _timer?.cancel();

    // Record partial session if it was a focus phase
    if (currentPhase.value == AppConstants.sessionTypeFocus &&
        _elapsedSeconds > 0) {
      _recordSession(wasCompleted: false);
    }

    _transitionToNextPhase();
  }

  // ============ PHASE MANAGEMENT ============

  /// Called when a phase timer reaches zero
  void _onPhaseComplete() {
    _timer?.cancel();
    isRunning.value = false;
    isPaused.value = false;

    // Record the completed session
    _recordSession(wasCompleted: true);

    // Fire notification to alert user
    _notifyPhaseComplete();

    // Transition to next phase
    _transitionToNextPhase();
  }

  /// Move to the next phase in the Pomodoro cycle
  void _transitionToNextPhase() {
    if (currentPhase.value == AppConstants.sessionTypeFocus) {
      completedSessions.value++;

      // After N focus sessions, take a long break
      if (completedSessions.value % sessionsBeforeLong.value == 0) {
        currentPhase.value = AppConstants.sessionTypeLongBreak;
      } else {
        currentPhase.value = AppConstants.sessionTypeShortBreak;
      }
    } else {
      // After any break, go back to focus
      currentPhase.value = AppConstants.sessionTypeFocus;
    }

    _elapsedSeconds = 0;
    isRunning.value = false;
    isPaused.value = false;
    _setPhaseTime();
  }

  /// Set remaining time based on current phase
  void _setPhaseTime() {
    switch (currentPhase.value) {
      case AppConstants.sessionTypeFocus:
        totalSeconds.value = focusDuration.value * 60;
        break;
      case AppConstants.sessionTypeShortBreak:
        totalSeconds.value = shortBreakDuration.value * 60;
        break;
      case AppConstants.sessionTypeLongBreak:
        totalSeconds.value = longBreakDuration.value * 60;
        break;
    }
    remainingSeconds.value = totalSeconds.value;
  }

  /// Reset to initial focus state
  void _resetToFocus() {
    currentPhase.value = AppConstants.sessionTypeFocus;
    completedSessions.value = 0;
    _elapsedSeconds = 0;
    isRunning.value = false;
    isPaused.value = false;
    _setPhaseTime();
  }

  /// Record a session to the repository
  Future<void> _recordSession({required bool wasCompleted}) async {
    final durationMinutes = totalSeconds.value ~/ 60;

    await _focusRepo.recordSession(
      durationMinutes: durationMinutes,
      actualSeconds: _elapsedSeconds,
      sessionType: currentPhase.value,
      wasCompleted: wasCompleted,
    );
  }

  /// Send a notification when the current phase finishes
  void _notifyPhaseComplete() {
    if (currentPhase.value == AppConstants.sessionTypeFocus) {
      _notificationService.showNotification(
        id: AppConstants.notificationIdFocusComplete,
        title: 'Focus session complete! 🎉',
        body: 'Great work! Time for a break.',
      );
    } else {
      _notificationService.showNotification(
        id: AppConstants.notificationIdBreakComplete,
        title: 'Break is over ☕',
        body: 'Ready to focus again?',
      );
    }
  }

  // ============ SETTINGS ============

  /// Update focus duration
  void setFocusDuration(int minutes) {
    focusDuration.value = minutes;
    if (currentPhase.value == AppConstants.sessionTypeFocus &&
        !isRunning.value) {
      _setPhaseTime();
    }
  }

  /// Update short break duration
  void setShortBreakDuration(int minutes) {
    shortBreakDuration.value = minutes;
    if (currentPhase.value == AppConstants.sessionTypeShortBreak &&
        !isRunning.value) {
      _setPhaseTime();
    }
  }

  /// Update long break duration
  void setLongBreakDuration(int minutes) {
    longBreakDuration.value = minutes;
    if (currentPhase.value == AppConstants.sessionTypeLongBreak &&
        !isRunning.value) {
      _setPhaseTime();
    }
  }

  /// Full reset (settings + state)
  void fullReset() {
    _timer?.cancel();
    _resetToFocus();
  }

  // ============ COMPUTED GETTERS ============

  /// Timer progress (0.0 - 1.0)
  double get progress {
    if (totalSeconds.value == 0) return 0.0;
    return 1.0 - (remainingSeconds.value / totalSeconds.value);
  }

  /// Formatted remaining time (mm:ss)
  String get formattedTime {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Phase display label
  String get phaseLabel {
    switch (currentPhase.value) {
      case AppConstants.sessionTypeFocus:
        return 'Focus';
      case AppConstants.sessionTypeShortBreak:
        return 'Short Break';
      case AppConstants.sessionTypeLongBreak:
        return 'Long Break';
      default:
        return 'Focus';
    }
  }

  /// Whether currently in a focus phase
  bool get isFocusPhase => currentPhase.value == AppConstants.sessionTypeFocus;

  /// Whether currently in a break phase
  bool get isBreakPhase => !isFocusPhase;

  /// Today's total focus time formatted
  String get todaysFocusTime => _focusRepo.getTodaysFocusTimeFormatted();

  /// Today's completed session count
  int get todaysSessionCount => _focusRepo.getTodaysSessionCount();
}
