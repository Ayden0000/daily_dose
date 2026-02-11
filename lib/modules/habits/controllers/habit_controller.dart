import 'package:get/get.dart';
import 'package:daily_dose/data/models/habit_model.dart';
import 'package:daily_dose/data/models/habit_completion_model.dart';
import 'package:daily_dose/data/repositories/habit_repository.dart';

/// Controller for Habit Tracker module
///
/// Manages habit list, daily completion toggling, and streak display.
/// Business logic lives in HabitRepository — this controller handles
/// reactive state and UI-facing actions only.
class HabitController extends GetxController {
  final HabitRepository _habitRepo;

  HabitController({required HabitRepository habitRepo})
    : _habitRepo = habitRepo;

  // ============ REACTIVE STATE ============

  final RxBool isLoading = false.obs;
  final RxList<HabitModel> habits = <HabitModel>[].obs;
  final RxList<HabitCompletionModel> todaysCompletions =
      <HabitCompletionModel>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    loadHabits();
  }

  // ============ DATA LOADING ============

  /// Load habits and today's completions
  void loadHabits() {
    isLoading.value = true;

    habits.value = _habitRepo.getHabitsForDate(selectedDate.value);
    todaysCompletions.value = _habitRepo.getCompletionsForDate(
      selectedDate.value,
    );

    isLoading.value = false;
  }

  /// Refresh when returning from other screens
  void refreshData() => loadHabits();

  // ============ ACTIONS ============

  /// Create a new habit
  Future<void> createHabit({
    required String title,
    String? description,
    String category = 'Other',
    int frequency = 1,
    List<int> customDays = const [],
    int targetPerDay = 1,
    double? streakThreshold,
  }) async {
    await _habitRepo.createHabit(
      title: title,
      description: description,
      category: category,
      frequency: frequency,
      customDays: customDays,
      targetPerDay: targetPerDay,
      streakThreshold: streakThreshold,
    );
    loadHabits();
  }

  /// Toggle completion for a habit
  Future<void> toggleCompletion(String habitId) async {
    await _habitRepo.toggleCompletion(habitId);
    loadHabits();
  }

  /// Delete a habit
  Future<void> deleteHabit(String id) async {
    await _habitRepo.deleteHabit(id);
    loadHabits();
  }

  /// Archive a habit
  Future<void> archiveHabit(String id) async {
    await _habitRepo.archiveHabit(id);
    loadHabits();
  }

  // ============ COMPUTED GETTERS ============

  /// Check if a habit is completed today
  bool isHabitCompleted(String habitId) {
    return todaysCompletions.any((c) => c.habitId == habitId);
  }

  /// Today's completion progress (0.0 - 1.0)
  double get todaysProgress => _habitRepo.getTodaysProgress();

  /// Today's completed count
  int get completedCount => _habitRepo.getTodaysCompletedCount();

  /// Total scheduled today
  int get totalScheduled => habits.length;

  /// Get completion rate for a specific habit
  int getHabitStreak(String habitId) {
    final habit = _habitRepo.getHabit(habitId);
    return habit?.currentStreak ?? 0;
  }

  /// Get heatmap data for calendar view
  Map<DateTime, double> get heatmapData =>
      _habitRepo.getCompletionHeatmap(days: 90);
}
