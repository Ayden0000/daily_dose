import 'package:hive/hive.dart';

part 'focus_session_model.g.dart';

/// Focus session model for Pomodoro timer tracking
///
/// Records completed focus and break sessions for productivity analytics.
@HiveType(typeId: 9)
class FocusSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  /// Planned duration in minutes
  @HiveField(1)
  int durationMinutes;

  /// Actual elapsed time in seconds
  @HiveField(2)
  int actualSeconds;

  /// Session type: 'focus', 'shortBreak', or 'longBreak'
  @HiveField(3)
  String sessionType;

  /// Whether the user completed the full session or cancelled early
  @HiveField(4)
  bool wasCompleted;

  /// Optional: link this focus session to a specific task
  @HiveField(5)
  String? linkedTaskId;

  @HiveField(6)
  final DateTime completedAt;

  FocusSessionModel({
    required this.id,
    required this.durationMinutes,
    required this.actualSeconds,
    required this.sessionType,
    this.wasCompleted = true,
    this.linkedTaskId,
    required this.completedAt,
  });

  /// Check if this session is from today
  bool get isToday {
    final now = DateTime.now();
    return completedAt.year == now.year &&
        completedAt.month == now.month &&
        completedAt.day == now.day;
  }

  /// Check if session is for a specific date
  bool isForDate(DateTime date) {
    return completedAt.year == date.year &&
        completedAt.month == date.month &&
        completedAt.day == date.day;
  }

  /// Whether this is a focus session (not a break)
  bool get isFocusSession => sessionType == 'focus';

  /// Formatted actual duration as mm:ss
  String get formattedDuration {
    final minutes = actualSeconds ~/ 60;
    final seconds = actualSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() =>
      'FocusSessionModel(type: $sessionType, duration: $formattedDuration, completed: $wasCompleted)';
}
