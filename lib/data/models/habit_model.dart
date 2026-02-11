import 'package:hive/hive.dart';
import 'package:daily_dose/app/config/constants.dart';

part 'habit_model.g.dart';

/// Habit model for recurring habit tracking
///
/// Unlike TaskModel (one-off items), habits are recurring patterns with
/// frequency settings, flexible streak tracking, and completion history.
/// Streaks use a configurable threshold (default 70%) so users don't
/// need 100% to maintain their streak — preventing perfectionism.
@HiveType(typeId: 4)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String category;

  /// Frequency type: 1=daily, 2=weekdays only, 3=custom days
  @HiveField(4)
  int frequency;

  /// For custom frequency: list of weekday numbers (1=Mon, 7=Sun)
  @HiveField(5)
  List<int> customDays;

  /// How many times per day this habit should be completed (default 1)
  @HiveField(6)
  int targetPerDay;

  @HiveField(7)
  int currentStreak;

  @HiveField(8)
  int longestStreak;

  /// Percentage of habits that must be completed to keep streak alive.
  /// Default 0.7 = 70% — allows flexibility without breaking streak.
  @HiveField(9)
  double streakThreshold;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  bool isArchived;

  @HiveField(12)
  int sortOrder;

  HabitModel({
    required this.id,
    required this.title,
    this.description,
    this.category = 'Other',
    this.frequency = AppConstants.frequencyDaily,
    this.customDays = const [],
    this.targetPerDay = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.streakThreshold = AppConstants.defaultStreakThreshold,
    required this.createdAt,
    this.isArchived = false,
    this.sortOrder = 0,
  });

  /// Check if this habit is scheduled for a given weekday
  bool isScheduledForDay(int weekday) {
    switch (frequency) {
      case AppConstants.frequencyDaily:
        return true;
      case AppConstants.frequencyWeekdays:
        return weekday >= 1 && weekday <= 5;
      case AppConstants.frequencyCustom:
        return customDays.contains(weekday);
      default:
        return true;
    }
  }

  /// Check if this habit is scheduled for today
  bool get isScheduledToday => isScheduledForDay(DateTime.now().weekday);

  /// Create a copy with updated fields
  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? frequency,
    List<int>? customDays,
    int? targetPerDay,
    int? currentStreak,
    int? longestStreak,
    double? streakThreshold,
    DateTime? createdAt,
    bool? isArchived,
    int? sortOrder,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakThreshold: streakThreshold ?? this.streakThreshold,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() =>
      'HabitModel(id: $id, title: $title, streak: $currentStreak)';
}
