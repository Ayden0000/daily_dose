import 'package:get/get.dart';
import 'package:daily_dose/data/services/analytics_service.dart';

/// Controller for Weekly/Monthly Review module
///
/// Aggregates cross-module data for bar chart visualization.
/// Uses AnalyticsService for data aggregation.
class ReviewController extends GetxController {
  final AnalyticsService _analyticsService;

  ReviewController({required AnalyticsService analyticsService})
    : _analyticsService = analyticsService;

  // ============ REACTIVE STATE ============

  final RxBool isLoading = false.obs;
  final RxBool isWeekly = true.obs; // true = weekly, false = monthly

  // Weekly data: keyed by DateTime
  final Rx<Map<DateTime, Map<String, double>>> weeklyData =
      Rx<Map<DateTime, Map<String, double>>>({});

  // Monthly data: keyed by week number
  final Rx<Map<int, Map<String, double>>> monthlyData =
      Rx<Map<int, Map<String, double>>>({});

  // Summary stats
  final RxDouble totalFocusMinutes = 0.0.obs;
  final RxDouble avgHabitRate = 0.0.obs;
  final RxList<double> moodTrend = <double>[].obs;

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // ============ DATA LOADING ============

  /// Load review data based on selected period
  void loadData() {
    isLoading.value = true;

    if (isWeekly.value) {
      _loadWeeklyData();
    } else {
      _loadMonthlyData();
    }

    totalFocusMinutes.value = _analyticsService.getWeeklyFocusMinutes();
    moodTrend.value = _analyticsService.getMoodTrend(
      days: isWeekly.value ? 7 : 30,
    );

    isLoading.value = false;
  }

  void _loadWeeklyData() {
    weeklyData.value = _analyticsService.getWeeklySummary();

    // Calculate average habit rate from weekly data
    if (weeklyData.value.isNotEmpty) {
      final rates = weeklyData.value.values
          .map((v) => v['habitRate'] ?? 0.0)
          .toList();
      avgHabitRate.value = rates.fold(0.0, (sum, r) => sum + r) / rates.length;
    }
  }

  void _loadMonthlyData() {
    monthlyData.value = _analyticsService.getMonthlySummary();

    // Calculate average habit rate from monthly data
    if (monthlyData.value.isNotEmpty) {
      final rates = monthlyData.value.values
          .map((v) => v['habitRate'] ?? 0.0)
          .toList();
      avgHabitRate.value = rates.fold(0.0, (sum, r) => sum + r) / rates.length;
    }
  }

  // ============ ACTIONS ============

  /// Toggle between weekly and monthly view
  void togglePeriod() {
    isWeekly.value = !isWeekly.value;
    loadData();
  }

  /// Set to weekly view
  void showWeekly() {
    isWeekly.value = true;
    loadData();
  }

  /// Set to monthly view
  void showMonthly() {
    isWeekly.value = false;
    loadData();
  }

  // ============ COMPUTED GETTERS ============

  /// Period label
  String get periodLabel => isWeekly.value ? 'This Week' : 'This Month';

  /// Tasks completed count for the overview card
  RxInt get tasksCompleted {
    final data = isWeekly.value
        ? weeklyData.value
        : <DateTime, Map<String, double>>{};
    final total = data.values.fold(
      0.0,
      (sum, v) => sum + (v['tasksCompleted'] ?? 0),
    );
    return total.toInt().obs;
  }

  /// Habit completion rate percentage for the overview card
  RxInt get habitsCompletionRate => (avgHabitRate.value * 100).toInt().obs;

  /// Focus minutes for the overview card
  RxInt get focusMinutes => totalFocusMinutes.value.toInt().obs;

  /// Bar chart data: task completions per day/week
  List<double> get taskCompletionData {
    if (isWeekly.value) {
      return _weeklyValues('tasksCompleted');
    }
    return _monthlyValues('tasksCompleted');
  }

  /// Bar chart data: mood per day/week
  List<double> get moodData => moodTrend.toList();

  /// Bar chart data: focus minutes per day/week
  List<double> get focusData {
    if (isWeekly.value) {
      return _weeklyValues('focusMinutes');
    }
    return _monthlyValues('focusMinutes');
  }

  List<double> _weeklyValues(String key) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final match = weeklyData.value.entries.where(
        (e) =>
            e.key.year == day.year &&
            e.key.month == day.month &&
            e.key.day == day.day,
      );
      if (match.isNotEmpty) {
        return match.first.value[key] ?? 0.0;
      }
      return 0.0;
    });
  }

  List<double> _monthlyValues(String key) {
    return List.generate(4, (i) {
      final week = i + 1;
      return monthlyData.value[week]?[key] ?? 0.0;
    });
  }
}
