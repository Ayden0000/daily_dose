import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/task_repository.dart';
import 'package:daily_dose/data/repositories/expense_repository.dart';
import 'package:daily_dose/data/repositories/meditation_repository.dart';
import 'package:daily_dose/data/repositories/habit_repository.dart';
import 'package:daily_dose/data/repositories/journal_repository.dart';
import 'package:daily_dose/data/repositories/focus_repository.dart';

/// Cross-module analytics service
///
/// Centralizes data aggregation from ALL repositories for the
/// Review module (weekly/monthly summaries) and dashboard stats.
///
/// Why a dedicated service:
/// The Review module needs data from every repository. Putting aggregation
/// logic inside one repository creates cross-cutting dependencies.
/// Putting it in a controller violates separation of concerns (controllers
/// should not talk to multiple repos directly for data aggregation).
/// A dedicated analytics service is the clean solution.
class AnalyticsService extends GetxService {
  final TaskRepository _taskRepo;
  final ExpenseRepository _expenseRepo;
  final MeditationRepository _meditationRepo;
  final HabitRepository _habitRepo;
  final JournalRepository _journalRepo;
  final FocusRepository _focusRepo;

  AnalyticsService({
    required TaskRepository taskRepo,
    required ExpenseRepository expenseRepo,
    required MeditationRepository meditationRepo,
    required HabitRepository habitRepo,
    required JournalRepository journalRepo,
    required FocusRepository focusRepo,
  }) : _taskRepo = taskRepo,
       _expenseRepo = expenseRepo,
       _meditationRepo = meditationRepo,
       _habitRepo = habitRepo,
       _journalRepo = journalRepo,
       _focusRepo = focusRepo;

  // ============ WEEKLY SUMMARY ============

  /// Get weekly summary data for bar charts
  ///
  /// Returns a map keyed by day-of-week with aggregated stats.
  /// Each day contains: tasksCompleted, habitRate, focusMinutes, mood
  Map<DateTime, Map<String, double>> getWeeklySummary() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    final summary = <DateTime, Map<String, double>>{};

    for (var i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Tasks completed for this day
      final dayTasks = _taskRepo.getTasksForDate(date);
      final tasksCompleted = dayTasks
          .where((t) => t.isCompleted)
          .length
          .toDouble();

      // Habit completion rate for this day
      final habitRate = _habitRepo.getCompletionRateForDate(date);

      // Focus time in minutes for this day
      final focusSessions = _focusRepo.getSessionsForDate(date);
      final focusMinutes =
          focusSessions.fold(0, (sum, s) => sum + s.actualSeconds) / 60.0;

      // Mood average for this day
      final dayEntries = _journalRepo.getEntriesForDate(date);
      final moodAvg = dayEntries.isEmpty
          ? 0.0
          : dayEntries.fold(0, (sum, e) => sum + e.mood) /
                dayEntries.length.toDouble();

      summary[normalizedDate] = {
        'tasksCompleted': tasksCompleted,
        'habitRate': habitRate,
        'focusMinutes': focusMinutes,
        'mood': moodAvg,
      };
    }

    return summary;
  }

  // ============ MONTHLY SUMMARY ============

  /// Get monthly summary data for bar charts
  ///
  /// Returns weekly aggregates for the current month (4-5 weeks).
  Map<int, Map<String, double>> getMonthlySummary() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final summary = <int, Map<String, double>>{};

    for (var week = 0; week < ((daysInMonth + 6) ~/ 7); week++) {
      double totalTasks = 0;
      double totalHabitRate = 0;
      double totalFocusMinutes = 0;
      double totalMood = 0;
      int moodDays = 0;
      int daysInWeek = 0;

      for (
        var day = week * 7 + 1;
        day <= (week + 1) * 7 && day <= daysInMonth;
        day++
      ) {
        final date = DateTime(now.year, now.month, day);
        if (date.isAfter(now)) break;

        daysInWeek++;

        final dayTasks = _taskRepo.getTasksForDate(date);
        totalTasks += dayTasks.where((t) => t.isCompleted).length;

        totalHabitRate += _habitRepo.getCompletionRateForDate(date);

        final focusSessions = _focusRepo.getSessionsForDate(date);
        totalFocusMinutes +=
            focusSessions.fold(0, (sum, s) => sum + s.actualSeconds) / 60.0;

        final dayEntries = _journalRepo.getEntriesForDate(date);
        if (dayEntries.isNotEmpty) {
          totalMood += dayEntries.fold(0, (sum, e) => sum + e.mood);
          moodDays += dayEntries.length;
        }
      }

      if (daysInWeek > 0) {
        summary[week + 1] = {
          'tasksCompleted': totalTasks,
          'habitRate': totalHabitRate / daysInWeek,
          'focusMinutes': totalFocusMinutes,
          'mood': moodDays > 0 ? totalMood / moodDays : 0,
        };
      }
    }

    return summary;
  }

  // ============ TREND HELPERS ============

  /// Get mood trend for the last N days
  List<double> getMoodTrend({int days = 7}) {
    final trend = <double>[];
    final now = DateTime.now();

    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final entries = _journalRepo.getEntriesForDate(date);
      if (entries.isEmpty) {
        trend.add(0);
      } else {
        trend.add(entries.fold(0, (sum, e) => sum + e.mood) / entries.length);
      }
    }

    return trend;
  }

  /// Get total focus time for the current week (in minutes)
  double getWeeklyFocusMinutes() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    double total = 0;
    for (var i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      if (date.isAfter(now)) break;

      final sessions = _focusRepo.getSessionsForDate(date);
      total += sessions.fold(0, (sum, s) => sum + s.actualSeconds) / 60.0;
    }

    return total;
  }

  /// Get this month's expense total
  double getMonthlyExpenseTotal() {
    return _expenseRepo.getThisMonthsTotal();
  }

  /// Get meditation streak
  int getMeditationStreak() {
    return _meditationRepo.getCurrentStreak();
  }
}
