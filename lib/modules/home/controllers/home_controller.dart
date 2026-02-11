import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/task_repository.dart';
import 'package:daily_dose/data/repositories/expense_repository.dart';
import 'package:daily_dose/data/repositories/meditation_repository.dart';
import 'package:daily_dose/data/repositories/habit_repository.dart';
import 'package:daily_dose/data/repositories/journal_repository.dart';
import 'package:daily_dose/data/repositories/goal_repository.dart';
import 'package:daily_dose/data/repositories/focus_repository.dart';

/// Controller for Home/Dashboard module
///
/// Aggregates data from ALL modules for dashboard display.
///
/// Why every repo is injected here:
/// The home screen is the single entry point showing cross-module stats.
/// Rather than depending on AnalyticsService (which targets Review charts),
/// HomeController directly reads lightweight summary data from each repo.
/// This avoids computing heavy weekly aggregates on every home load.
class HomeController extends GetxController {
  final TaskRepository _taskRepository;
  final ExpenseRepository _expenseRepository;
  final MeditationRepository _meditationRepository;
  final HabitRepository _habitRepository;
  final JournalRepository _journalRepository;
  final GoalRepository _goalRepository;
  final FocusRepository _focusRepository;

  HomeController({
    required TaskRepository taskRepository,
    required ExpenseRepository expenseRepository,
    required MeditationRepository meditationRepository,
    required HabitRepository habitRepository,
    required JournalRepository journalRepository,
    required GoalRepository goalRepository,
    required FocusRepository focusRepository,
  }) : _taskRepository = taskRepository,
       _expenseRepository = expenseRepository,
       _meditationRepository = meditationRepository,
       _habitRepository = habitRepository,
       _journalRepository = journalRepository,
       _goalRepository = goalRepository,
       _focusRepository = focusRepository;

  // ============ REACTIVE STATE ============

  final RxBool isLoading = false.obs;

  // Tasks summary
  final RxInt todaysTaskCount = 0.obs;
  final RxInt todaysCompletedCount = 0.obs;
  final RxInt taskStreak = 0.obs;

  // Expenses summary
  final RxDouble todaysExpenses = 0.0.obs;
  final RxDouble monthsExpenses = 0.0.obs;

  // Meditation summary
  final RxInt meditationStreak = 0.obs;
  final RxInt todaysMeditationTime = 0.obs;

  // Habits summary
  final RxInt todaysHabitCount = 0.obs;
  final RxInt todaysHabitCompleted = 0.obs;
  final RxInt habitStreak = 0.obs;

  // Journal summary
  final RxInt todaysMood = 0.obs;
  final RxInt totalJournalEntries = 0.obs;

  // Goals summary
  final RxInt activeGoalCount = 0.obs;
  final RxInt completedGoalCount = 0.obs;

  // Focus summary
  final RxInt todaysFocusSessions = 0.obs;
  final RxString todaysFocusTime = '0m'.obs;

  // Advice from API
  final RxString advice = ''.obs;
  final RxBool isAdviceLoading = true.obs;

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    _fetchAdvice();
  }

  // ============ API ============

  /// Fetch a random advice from adviceslip.com
  Future<void> _fetchAdvice() async {
    isAdviceLoading.value = true;
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.adviceslip.com/advice'),
      );
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        final text = data['slip']?['advice'] as String?;
        if (text != null && text.isNotEmpty) {
          advice.value = text;
        }
      }
    } catch (_) {
      // Keep whatever was loaded before, or show fallback
      if (advice.value.isEmpty) {
        advice.value = 'Let\'s make today count!';
      }
    } finally {
      isAdviceLoading.value = false;
    }
  }

  // ============ DATA LOADING ============

  /// Load all dashboard data
  void loadDashboardData() {
    isLoading.value = true;

    // Ensure stale completions from yesterday are cleared
    _taskRepository.resetDailyTasks();

    // Tasks
    final todaysTasks = _taskRepository.getTodaysTasks();
    todaysTaskCount.value = todaysTasks.length;
    todaysCompletedCount.value = todaysTasks.where((t) => t.isCompleted).length;
    taskStreak.value = _taskRepository.getCurrentStreak();

    // Expenses
    todaysExpenses.value = _expenseRepository.getTodaysTotal();
    monthsExpenses.value = _expenseRepository.getThisMonthsTotal();

    // Meditation
    meditationStreak.value = _meditationRepository.getCurrentStreak();
    todaysMeditationTime.value = _meditationRepository.getTodaysTotalTime();

    // Habits
    final todayHabits = _habitRepository.getHabitsForDate(DateTime.now());
    todaysHabitCount.value = todayHabits.length;
    todaysHabitCompleted.value = _habitRepository.getTodaysCompletedCount();
    habitStreak.value = _habitRepository.getCurrentStreak();

    // Journal
    final todayEntries = _journalRepository.getEntriesForDate(DateTime.now());
    todaysMood.value = todayEntries.isNotEmpty ? todayEntries.last.mood : 0;
    totalJournalEntries.value = _journalRepository.getAllEntries().length;

    // Goals
    final allGoals = _goalRepository.getAllGoals();
    activeGoalCount.value = allGoals.where((g) => !g.isCompleted).length;
    completedGoalCount.value = allGoals.where((g) => g.isCompleted).length;

    // Focus
    todaysFocusSessions.value = _focusRepository.getTodaysSessionCount();
    todaysFocusTime.value = _focusRepository.getTodaysFocusTimeFormatted();

    isLoading.value = false;
  }

  /// Refresh dashboard
  Future<void> refreshDashboard() async {
    loadDashboardData();
    await _fetchAdvice();
  }

  // ============ COMPUTED GETTERS ============

  /// Task completion progress (0.0 - 1.0)
  double get taskProgress {
    if (todaysTaskCount.value == 0) return 0.0;
    return todaysCompletedCount.value / todaysTaskCount.value;
  }

  /// Formatted meditation time
  String get formattedMeditationTime {
    final minutes = todaysMeditationTime.value ~/ 60;
    if (minutes < 1) return '${todaysMeditationTime.value}s';
    return '${minutes}m';
  }

  /// Habit completion progress (0.0 - 1.0)
  double get habitProgress {
    if (todaysHabitCount.value == 0) return 0.0;
    return todaysHabitCompleted.value / todaysHabitCount.value;
  }

  /// Today's mood as emoji
  String get todaysMoodEmoji {
    const emojis = ['', '😞', '😔', '😐', '🙂', '😄'];
    if (todaysMood.value < 1 || todaysMood.value > 5) return '';
    return emojis[todaysMood.value];
  }

  /// Greeting based on time of day
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Random advice fetched from adviceslip.com
  String get motivationalTagline => advice.value;

  /// Current date formatted
  String get formattedDate {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
