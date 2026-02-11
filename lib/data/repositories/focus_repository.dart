import 'package:uuid/uuid.dart';
import 'package:daily_dose/data/models/focus_session_model.dart';
import 'package:daily_dose/data/services/storage_service.dart';

/// Repository for focus/Pomodoro session business logic
///
/// Handles recording completed sessions and calculating focus statistics.
/// Does NOT contain timer logic — that lives in the controller.
class FocusRepository {
  final StorageService _storageService;
  static const _uuid = Uuid();

  FocusRepository({required StorageService storageService})
    : _storageService = storageService;

  // ============ CRUD ============

  /// Get all sessions sorted by date (newest first)
  List<FocusSessionModel> getAllSessions() {
    final sessions = _storageService.getAllFocusSessions();
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  /// Get sessions for a specific date
  List<FocusSessionModel> getSessionsForDate(DateTime date) {
    return getAllSessions().where((s) => s.isForDate(date)).toList();
  }

  /// Get today's sessions
  List<FocusSessionModel> getTodaysSessions() {
    return getSessionsForDate(DateTime.now());
  }

  /// Get sessions for a date range
  List<FocusSessionModel> getSessionsForDateRange(
    DateTime start,
    DateTime end,
  ) {
    return getAllSessions().where((s) {
      return !s.completedAt.isBefore(start) && !s.completedAt.isAfter(end);
    }).toList();
  }

  /// Record a completed focus/break session
  Future<FocusSessionModel> recordSession({
    required int durationMinutes,
    required int actualSeconds,
    required String sessionType,
    bool wasCompleted = true,
    String? linkedTaskId,
  }) async {
    final session = FocusSessionModel(
      id: _uuid.v4(),
      durationMinutes: durationMinutes,
      actualSeconds: actualSeconds,
      sessionType: sessionType,
      wasCompleted: wasCompleted,
      linkedTaskId: linkedTaskId,
      completedAt: DateTime.now(),
    );
    await _storageService.saveFocusSession(session);
    return session;
  }

  /// Delete a session
  Future<void> deleteSession(String id) async {
    await _storageService.deleteFocusSession(id);
  }

  // ============ STATISTICS ============

  /// Get today's total focus time in seconds (focus sessions only)
  int getTodaysFocusTime() {
    return getTodaysSessions()
        .where((s) => s.isFocusSession)
        .fold(0, (sum, s) => sum + s.actualSeconds);
  }

  /// Get today's total focus time formatted as "Xh Ym"
  String getTodaysFocusTimeFormatted() {
    final seconds = getTodaysFocusTime();
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  /// Get weekly total focus time in seconds
  int getWeeklyFocusTime() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    return getSessionsForDateRange(
      startOfWeek,
      now,
    ).where((s) => s.isFocusSession).fold(0, (sum, s) => sum + s.actualSeconds);
  }

  /// Get total completed focus sessions count
  int getTotalSessionsCount() {
    return getAllSessions()
        .where((s) => s.isFocusSession && s.wasCompleted)
        .length;
  }

  /// Get average focus session length in seconds
  int getAverageSessionLength() {
    final focusSessions = getAllSessions()
        .where((s) => s.isFocusSession && s.wasCompleted)
        .toList();
    if (focusSessions.isEmpty) return 0;

    final total = focusSessions.fold(0, (sum, s) => sum + s.actualSeconds);
    return total ~/ focusSessions.length;
  }

  /// Get today's completed focus session count
  int getTodaysSessionCount() {
    return getTodaysSessions()
        .where((s) => s.isFocusSession && s.wasCompleted)
        .length;
  }

  /// Get daily focus times for the last N days
  ///
  /// Returns Map<DateTime, int> where int is focus seconds for that day
  Map<DateTime, int> getDailyFocusTimes({int days = 7}) {
    final result = <DateTime, int>{};
    final now = DateTime.now();

    for (var i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final daySessions = getSessionsForDate(date);
      result[date] = daySessions
          .where((s) => s.isFocusSession)
          .fold(0, (sum, s) => sum + s.actualSeconds);
    }

    return result;
  }
}
