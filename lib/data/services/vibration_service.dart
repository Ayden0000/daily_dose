import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

/// Vibration service for haptic feedback
///
/// Provides vibration cues for meditation breathing phases.
class VibrationService extends GetxService {
  bool _isEnabled = true;
  bool _hasVibrator = false;

  /// Whether vibration cues are enabled
  bool get isEnabled => _isEnabled;

  /// Set vibration enabled state
  set isEnabled(bool value) {
    _isEnabled = value;
  }

  /// Initialize vibration service
  Future<void> init() async {
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (e) {
      _hasVibrator = false;
    }
  }

  /// Short vibration for phase transition
  Future<void> vibrateShort() async {
    if (!_isEnabled || !_hasVibrator) return;

    try {
      await Vibration.vibrate(duration: 100);
    } catch (e) {
      // Silent fail - vibration is optional
    }
  }

  /// Medium vibration for important transitions
  Future<void> vibrateMedium() async {
    if (!_isEnabled || !_hasVibrator) return;

    try {
      await Vibration.vibrate(duration: 200);
    } catch (e) {
      // Silent fail
    }
  }

  /// Long vibration for session complete
  Future<void> vibrateLong() async {
    if (!_isEnabled || !_hasVibrator) return;

    try {
      await Vibration.vibrate(duration: 500);
    } catch (e) {
      // Silent fail
    }
  }

  /// Pattern vibration (double pulse)
  Future<void> vibratePattern() async {
    if (!_isEnabled || !_hasVibrator) return;

    try {
      await Vibration.vibrate(pattern: [0, 100, 100, 100]);
    } catch (e) {
      // Silent fail
    }
  }

  /// Cancel any ongoing vibration
  Future<void> cancel() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      // Silent fail
    }
  }
}
