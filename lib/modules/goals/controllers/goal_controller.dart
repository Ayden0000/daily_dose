import 'package:get/get.dart';
import 'package:daily_dose/widgets/app_toast.dart';
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
  final RxString errorMessage = ''.obs;

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  // ============ DATA LOADING ============

  /// Load goals based on filter
  Future<void> loadGoals() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (showCompleted.value) {
        goals.value = _goalRepo.getAllGoals();
      } else {
        goals.value = _goalRepo.getActiveGoals();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load goals: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ============ ACTIONS ============

  /// Create a new goal
  Future<void> createGoal({
    required String title,
    String? description,
    String category = 'Personal',
    required DateTime targetDate,
  }) async {
    try {
      await _goalRepo.createGoal(
        title: title,
        description: description,
        category: category,
        targetDate: targetDate,
      );
      await loadGoals();
    } catch (e) {
      errorMessage.value = 'Failed to create goal: $e';
      AppToast.error(Get.context!, 'Could not create goal');
    }
  }

  /// Update a goal
  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _goalRepo.updateGoal(goal);
      await loadGoals();
    } catch (e) {
      errorMessage.value = 'Failed to update goal: $e';
      AppToast.error(Get.context!, 'Could not update goal');
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    try {
      await _goalRepo.deleteGoal(id);
      await loadGoals();
    } catch (e) {
      errorMessage.value = 'Failed to delete goal: $e';
      AppToast.error(Get.context!, 'Could not delete goal');
    }
  }

  /// Complete a goal manually
  Future<void> completeGoal(String id) async {
    try {
      await _goalRepo.completeGoal(id);
      await loadGoals();
    } catch (e) {
      errorMessage.value = 'Failed to complete goal: $e';
      AppToast.error(Get.context!, 'Could not complete goal');
    }
  }

  /// Add a milestone to a goal
  Future<void> addMilestone(String goalId, String title) async {
    try {
      await _goalRepo.addMilestone(goalId, title);
      await loadGoals();
    } catch (e) {
      errorMessage.value = 'Failed to add milestone: $e';
      AppToast.error(Get.context!, 'Could not add milestone');
    }
  }

  /// Toggle milestone completion
  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    try {
      await _goalRepo.toggleMilestone(goalId, milestoneId);
      await loadGoals();
    } catch (e) {
      errorMessage.value = 'Failed to update milestone: $e';
      AppToast.error(Get.context!, 'Could not update milestone');
    }
  }

  /// Remove a milestone
  Future<void> removeMilestone(String goalId, String milestoneId) async {
    try {
      await _goalRepo.removeMilestone(goalId, milestoneId);
      await loadGoals();
    } catch (e) {
      errorMessage.value = 'Failed to remove milestone: $e';
      AppToast.error(Get.context!, 'Could not remove milestone');
    }
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
