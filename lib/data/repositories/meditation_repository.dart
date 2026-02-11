import 'package:uuid/uuid.dart';
import 'package:daily_dose/app/config/constants.dart';
import 'package:daily_dose/data/models/breathing_pattern_model.dart';
import 'package:daily_dose/data/models/meditation_session_model.dart';
import 'package:daily_dose/data/services/storage_service.dart';

/// Repository for meditation-related business logic
///
/// Handles breathing patterns and session history.
class MeditationRepository {
  final StorageService _storageService;
  static const _uuid = Uuid();

  MeditationRepository({required StorageService storageService})
    : _storageService = storageService;

  // ============ PATTERNS ============

  /// Get all breathing patterns (default + custom)
  List<BreathingPatternModel> getAllPatterns() {
    final patterns = _storageService.getAllPatterns();

    // If no patterns exist, seed with defaults
    if (patterns.isEmpty) {
      _seedDefaultPatterns();
      return _storageService.getAllPatterns();
    }

    // Sort: defaults first, then custom by creation date
    patterns.sort((a, b) {
      if (a.isCustom != b.isCustom) {
        return a.isCustom ? 1 : -1;
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    return patterns;
  }

  /// Get pattern by ID
  BreathingPatternModel? getPattern(String id) {
    return _storageService.getPattern(id);
  }

  /// Create a custom pattern
  Future<BreathingPatternModel> createPattern({
    required String name,
    required int inhale,
    required int hold1,
    required int exhale,
    required int hold2,
  }) async {
    final pattern = BreathingPatternModel(
      id: _uuid.v4(),
      name: name,
      inhale: inhale,
      hold1: hold1,
      exhale: exhale,
      hold2: hold2,
      isCustom: true,
      createdAt: DateTime.now(),
    );
    await _storageService.savePattern(pattern);
    return pattern;
  }

  /// Update an existing pattern (custom only)
  Future<void> updatePattern(BreathingPatternModel pattern) async {
    if (!pattern.isCustom) {
      throw Exception('Cannot modify default patterns');
    }
    await _storageService.savePattern(pattern);
  }

  /// Delete a pattern (custom only)
  Future<void> deletePattern(String id) async {
    final pattern = getPattern(id);
    if (pattern != null && !pattern.isCustom) {
      throw Exception('Cannot delete default patterns');
    }
    await _storageService.deletePattern(id);
  }

  /// Seed default breathing patterns
  Future<void> _seedDefaultPatterns() async {
    for (final data in AppConstants.defaultBreathingPatterns) {
      final pattern = BreathingPatternModel(
        id: _uuid.v4(),
        name: data['name'] as String,
        inhale: data['inhale'] as int,
        hold1: data['hold1'] as int,
        exhale: data['exhale'] as int,
        hold2: data['hold2'] as int,
        isCustom: false,
        createdAt: DateTime.now(),
      );
      await _storageService.savePattern(pattern);
    }
  }

  // ============ SESSIONS ============

  /// Get all meditation sessions sorted by date (newest first)
  List<MeditationSessionModel> getAllSessions() {
    final sessions = _storageService.getAllSessions();
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  /// Get today's sessions
  List<MeditationSessionModel> getTodaysSessions() {
    return getAllSessions().where((s) => s.isToday).toList();
  }

  /// Record a completed meditation session
  Future<MeditationSessionModel> recordSession({
    required String patternId,
    required String patternName,
    required int durationSeconds,
    required int completedCycles,
  }) async {
    final session = MeditationSessionModel(
      id: _uuid.v4(),
      patternId: patternId,
      patternName: patternName,
      durationSeconds: durationSeconds,
      completedCycles: completedCycles,
      completedAt: DateTime.now(),
    );
    await _storageService.saveSession(session);
    return session;
  }

  // ============ STATISTICS ============

  /// Get total meditation time today (in seconds)
  int getTodaysTotalTime() {
    return getTodaysSessions().fold(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Get total meditation time for all time (in seconds)
  int getTotalMeditationTime() {
    return getAllSessions().fold(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Get total sessions count
  int getTotalSessionsCount() {
    return getAllSessions().length;
  }

  /// Get current meditation streak (consecutive days with at least one session)
  int getCurrentStreak() {
    var streak = 0;
    var date = DateTime.now();
    final sessions = getAllSessions();

    while (true) {
      final hasSessions = sessions.any(
        (s) =>
            s.completedAt.year == date.year &&
            s.completedAt.month == date.month &&
            s.completedAt.day == date.day,
      );

      if (!hasSessions) break;

      streak++;
      date = date.subtract(const Duration(days: 1));

      // Limit check
      if (streak > 365) break;
    }

    return streak;
  }

  /// Get average session duration (in seconds)
  int getAverageSessionDuration() {
    final sessions = getAllSessions();
    if (sessions.isEmpty) return 0;

    final total = sessions.fold(0, (sum, s) => sum + s.durationSeconds);
    return total ~/ sessions.length;
  }
}
