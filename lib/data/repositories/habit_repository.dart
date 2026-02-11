import 'package:uuid/uuid.dart';
import 'package:daily_dose/data/models/habit_model.dart';
import 'package:daily_dose/data/models/habit_completion_model.dart';
import 'package:daily_dose/data/services/storage_service.dart';

/// Repository for habit-related business logic
///
/// Handles CRUD operations, flexible streak calculations, and
/// completion tracking. Does NOT contain UI logic.
///
/// Streak Philosophy:
/// Streaks use a configurable threshold (default 70%). If a user has 10 habits
/// and completes 7, that's 70% — streak continues. This prevents perfectionism
/// and encourages consistency over perfection.
class HabitRepository {
  final StorageService _storageService;
  static const _uuid = Uuid();

  HabitRepository({required StorageService storageService})
    : _storageService = storageService;

  // ============ CRUD ============

  /// Get all active (non-archived) habits sorted by sort order
  List<HabitModel> getAllHabits() {
    final habits = _storageService
        .getAllHabits()
        .where((h) => !h.isArchived)
        .toList();
    habits.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return habits;
  }

  /// Get all habits including archived
  List<HabitModel> getAllHabitsIncludingArchived() {
    final habits = _storageService.getAllHabits();
    habits.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return habits;
  }

  /// Get habits scheduled for a specific date
  List<HabitModel> getHabitsForDate(DateTime date) {
    return getAllHabits()
        .where((h) => h.isScheduledForDay(date.weekday))
        .toList();
  }

  /// Get today's scheduled habits
  List<HabitModel> getTodaysHabits() {
    return getHabitsForDate(DateTime.now());
  }

  /// Get habit by ID
  HabitModel? getHabit(String id) {
    return _storageService.getHabit(id);
  }

  /// Create a new habit
  Future<HabitModel> createHabit({
    required String title,
    String? description,
    String category = 'Other',
    int frequency = 1,
    List<int> customDays = const [],
    int targetPerDay = 1,
    double? streakThreshold,
  }) async {
    final habit = HabitModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      frequency: frequency,
      customDays: customDays,
      targetPerDay: targetPerDay,
      streakThreshold: streakThreshold ?? 0.7,
      createdAt: DateTime.now(),
      sortOrder: getAllHabits().length,
    );
    await _storageService.saveHabit(habit);
    return habit;
  }

  /// Update an existing habit
  Future<void> updateHabit(HabitModel habit) async {
    await _storageService.saveHabit(habit);
  }

  /// Delete a habit and all its completions
  Future<void> deleteHabit(String id) async {
    // Remove all completions for this habit
    final completions = _storageService
        .getAllHabitCompletions()
        .where((c) => c.habitId == id)
        .toList();
    for (final c in completions) {
      await _storageService.deleteHabitCompletion(c.id);
    }
    await _storageService.deleteHabit(id);
  }

  /// Archive a habit (soft delete)
  Future<void> archiveHabit(String id) async {
    final habit = getHabit(id);
    if (habit == null) return;
    habit.isArchived = true;
    await _storageService.saveHabit(habit);
  }

  // ============ COMPLETION ============

  /// Toggle completion for a habit on today's date
  Future<void> toggleCompletion(String habitId) async {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);

    final existing = _getCompletionForDate(habitId, normalizedDate);

    if (existing != null) {
      // Already completed — un-complete
      await _storageService.deleteHabitCompletion(existing.id);
    } else {
      // Mark as completed
      final completion = HabitCompletionModel(
        id: _uuid.v4(),
        habitId: habitId,
        date: normalizedDate,
        completedCount: 1,
        completedAt: DateTime.now(),
      );
      await _storageService.saveHabitCompletion(completion);
    }

    // Recalculate streaks after toggling
    await _recalculateStreak(habitId);
  }

  /// Check if a habit is completed for a given date
  bool isCompletedForDate(String habitId, DateTime date) {
    return _getCompletionForDate(habitId, date) != null;
  }

  /// Get completion record for a habit on a specific date
  HabitCompletionModel? _getCompletionForDate(String habitId, DateTime date) {
    final completions = _storageService.getAllHabitCompletions();
    try {
      return completions.firstWhere(
        (c) => c.habitId == habitId && c.isForDate(date),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get all completions for a specific date
  List<HabitCompletionModel> getCompletionsForDate(DateTime date) {
    return _storageService
        .getAllHabitCompletions()
        .where((c) => c.isForDate(date))
        .toList();
  }

  // ============ STREAKS (FLEXIBLE) ============

  /// Recalculate streak for a specific habit
  ///
  /// Streak logic: looks back day-by-day. For each day the habit was
  /// scheduled, checks if it was completed. The streak continues as long
  /// as the overall completion rate across all scheduled habits stays
  /// above the threshold.
  Future<void> _recalculateStreak(String habitId) async {
    final habit = getHabit(habitId);
    if (habit == null) return;

    final streak = _calculateStreakForHabit(habit);
    habit.currentStreak = streak;
    if (streak > habit.longestStreak) {
      habit.longestStreak = streak;
    }
    await _storageService.saveHabit(habit);
  }

  /// Calculate how many consecutive days this habit was completed
  int _calculateStreakForHabit(HabitModel habit) {
    var streak = 0;
    var date = DateTime.now();
    const maxDaysToCheck = 365;

    for (var i = 0; i < maxDaysToCheck; i++) {
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Skip days when the habit isn't scheduled
      if (!habit.isScheduledForDay(normalizedDate.weekday)) {
        date = date.subtract(const Duration(days: 1));
        continue;
      }

      final isCompleted = isCompletedForDate(habit.id, normalizedDate);
      if (!isCompleted) break;

      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Get the overall completion rate for a specific date
  ///
  /// This checks ALL habits scheduled for that date and returns
  /// (completed / total). Used by the flexible streak system.
  double getCompletionRateForDate(DateTime date) {
    final scheduledHabits = getHabitsForDate(date);
    if (scheduledHabits.isEmpty) return 0.0;

    final completions = getCompletionsForDate(date);
    final completedIds = completions.map((c) => c.habitId).toSet();

    final completedCount = scheduledHabits
        .where((h) => completedIds.contains(h.id))
        .length;

    return completedCount / scheduledHabits.length;
  }

  /// Check if the overall streak (across all habits) is alive for a date
  ///
  /// Uses the flexible threshold: if completion rate >= threshold,
  /// the streak day counts.
  bool isStreakAliveForDate(DateTime date) {
    final habits = getHabitsForDate(date);
    if (habits.isEmpty) return true; // No habits scheduled = skip this day

    final rate = getCompletionRateForDate(date);
    // Use the average threshold across all habits
    final avgThreshold =
        habits.fold(0.0, (sum, h) => sum + h.streakThreshold) / habits.length;

    return rate >= avgThreshold;
  }

  // ============ STATISTICS ============

  /// Get today's progress as a fraction (0.0 - 1.0)
  double getTodaysProgress() {
    return getCompletionRateForDate(DateTime.now());
  }

  /// Get count of active (non-archived) habits
  int getActiveHabitsCount() {
    return getAllHabits().length;
  }

  /// Get today's completed count
  int getTodaysCompletedCount() {
    final today = DateTime.now();
    final scheduled = getTodaysHabits();
    final completions = getCompletionsForDate(today);
    final completedIds = completions.map((c) => c.habitId).toSet();

    return scheduled.where((h) => completedIds.contains(h.id)).length;
  }

  /// Get the current overall streak (consecutive days above threshold)
  ///
  /// Uses the flexible streak system: days where the completion rate
  /// meets the threshold count as streak days. Days with no scheduled
  /// habits are skipped (vacations don't break streaks).
  int getCurrentStreak() {
    var streak = 0;
    final now = DateTime.now();
    const maxDaysToCheck = 365;

    for (var i = 0; i < maxDaysToCheck; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final scheduled = getHabitsForDate(date);

      // Skip days with no scheduled habits
      if (scheduled.isEmpty) continue;

      if (isStreakAliveForDate(date)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get calendar heatmap data for the last N days
  ///
  /// Returns Map<DateTime, double> where double is completion rate (0.0-1.0)
  Map<DateTime, double> getCompletionHeatmap({int days = 30}) {
    final heatmap = <DateTime, double>{};
    final now = DateTime.now();

    for (var i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      heatmap[date] = getCompletionRateForDate(date);
    }

    return heatmap;
  }
}
