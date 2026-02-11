import 'package:get/get.dart';
import 'package:daily_dose/data/models/goal_model.dart';
import 'package:daily_dose/data/repositories/goal_repository.dart';

/// Controller for Goal Setting module
///
/// Manages goal lifecycle, milestone toggling, and progress tracking.
class GoalController extends GetxController {
  final GoalRepository _goalRepo;

  GoalController({required GoalRepository goalRepo}) : _goalRepo = goalRepo;

  // ============ REACTIVE STATE ============

  final RxBool isLoading = false.obs;
  final RxList<GoalModel> goals = <GoalModel>[].obs;
  final RxBool showCompleted = false.obs;

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  // ============ DATA LOADING ============

  /// Load goals based on filter
  void loadGoals() {
    isLoading.value = true;

    if (showCompleted.value) {
      goals.value = _goalRepo.getAllGoals();
    } else {
      goals.value = _goalRepo.getActiveGoals();
    }

    isLoading.value = false;
  }

  // ============ ACTIONS ============

  /// Create a new goal
  Future<void> createGoal({
    required String title,
    String? description,
    String category = 'Personal',
    required DateTime targetDate,
  }) async {
    await _goalRepo.createGoal(
      title: title,
      description: description,
      category: category,
      targetDate: targetDate,
    );
    loadGoals();
  }

  /// Update a goal
  Future<void> updateGoal(GoalModel goal) async {
    await _goalRepo.updateGoal(goal);
    loadGoals();
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _goalRepo.deleteGoal(id);
    loadGoals();
  }

  /// Complete a goal manually
  Future<void> completeGoal(String id) async {
    await _goalRepo.completeGoal(id);
    loadGoals();
  }

  /// Add a milestone to a goal
  Future<void> addMilestone(String goalId, String title) async {
    await _goalRepo.addMilestone(goalId, title);
    loadGoals();
  }

  /// Toggle milestone completion
  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    await _goalRepo.toggleMilestone(goalId, milestoneId);
    loadGoals();
  }

  /// Remove a milestone
  Future<void> removeMilestone(String goalId, String milestoneId) async {
    await _goalRepo.removeMilestone(goalId, milestoneId);
    loadGoals();
  }

  /// Toggle show completed filter
  void toggleShowCompleted() {
    showCompleted.value = !showCompleted.value;
    loadGoals();
  }

  // ============ COMPUTED GETTERS ============

  /// Number of active goals
  int get activeGoalsCount => _goalRepo.getActiveGoalsCount();

  /// Overall progress across active goals
  double get overallProgress => _goalRepo.getOverallProgress();

  /// Get active goals
  List<GoalModel> get activeGoals => _goalRepo.getActiveGoals();

  /// Get completed goals
  List<GoalModel> get completedGoals => _goalRepo.getCompletedGoals();

  /// Overdue goals
  List<GoalModel> get overdueGoals => _goalRepo.getOverdueGoals();
}
