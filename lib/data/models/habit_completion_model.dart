import 'package:hive/hive.dart';

part 'habit_completion_model.g.dart';

/// Habit completion record for tracking daily habit completions
///
/// Stored separately from HabitModel to avoid ever-growing lists inside
/// a single Hive object. Separate box allows efficient date-range queries
/// for calendar heatmaps and streak calculations.
@HiveType(typeId: 5)
class HabitCompletionModel extends HiveObject {
  @HiveField(0)
  final String id;

  /// ID of the habit this completion belongs to
  @HiveField(1)
  String habitId;

  /// Date of completion (normalized to midnight for grouping)
  @HiveField(2)
  DateTime date;

  /// How many times the habit was completed on this date
  @HiveField(3)
  int completedCount;

  /// Actual timestamp when the completion was recorded
  @HiveField(4)
  final DateTime completedAt;

  HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.date,
    this.completedCount = 1,
    required this.completedAt,
  });

  /// Check if this completion is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if completion is for a specific date
  bool isForDate(DateTime targetDate) {
    return date.year == targetDate.year &&
        date.month == targetDate.month &&
        date.day == targetDate.day;
  }

  @override
  String toString() =>
      'HabitCompletionModel(habitId: $habitId, date: $date, count: $completedCount)';
}
