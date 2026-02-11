import 'package:uuid/uuid.dart';
import 'package:daily_dose/data/models/goal_model.dart';
import 'package:daily_dose/data/models/goal_milestone_model.dart';
import 'package:daily_dose/data/services/storage_service.dart';

/// Repository for goal-related business logic
///
/// Handles CRUD for goals and their milestones, progress tracking,
/// and deadline awareness. Does NOT contain UI logic.
class GoalRepository {
  final StorageService _storageService;
  static const _uuid = Uuid();

  GoalRepository({required StorageService storageService})
    : _storageService = storageService;

  // ============ CRUD ============

  /// Get all goals sorted by target date (earliest first)
  List<GoalModel> getAllGoals() {
    final goals = _storageService.getAllGoals();
    goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    return goals;
  }

  /// Get active (incomplete) goals
  List<GoalModel> getActiveGoals() {
    return getAllGoals().where((g) => !g.isCompleted).toList();
  }

  /// Get completed goals
  List<GoalModel> getCompletedGoals() {
    return getAllGoals().where((g) => g.isCompleted).toList();
  }

  /// Get overdue goals
  List<GoalModel> getOverdueGoals() {
    return getAllGoals().where((g) => g.isOverdue).toList();
  }

  /// Get goal by ID
  GoalModel? getGoal(String id) {
    return _storageService.getGoal(id);
  }

  /// Create a new goal
  Future<GoalModel> createGoal({
    required String title,
    String? description,
    String category = 'Personal',
    required DateTime targetDate,
    List<GoalMilestoneModel>? milestones,
  }) async {
    final goal = GoalModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      milestones: milestones ?? [],
    );
    await _storageService.saveGoal(goal);
    return goal;
  }

  /// Update an existing goal
  Future<void> updateGoal(GoalModel goal) async {
    await _storageService.saveGoal(goal);
  }

  /// Delete a goal
  Future<void> deleteGoal(String id) async {
    await _storageService.deleteGoal(id);
  }

  /// Mark a goal as completed
  Future<void> completeGoal(String id) async {
    final goal = getGoal(id);
    if (goal == null) return;

    goal.isCompleted = true;
    goal.completedAt = DateTime.now();
    await _storageService.saveGoal(goal);
  }

  // ============ MILESTONES ============

  /// Add a milestone to a goal
  Future<void> addMilestone(String goalId, String title) async {
    final goal = getGoal(goalId);
    if (goal == null) return;

    final milestone = GoalMilestoneModel(
      id: _uuid.v4(),
      title: title,
      sortOrder: goal.milestones.length,
    );

    goal.milestones = [...goal.milestones, milestone];
    await _storageService.saveGoal(goal);
  }

  /// Toggle milestone completion
  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    final goal = getGoal(goalId);
    if (goal == null) return;

    final milestones = goal.milestones.toList();
    final index = milestones.indexWhere((m) => m.id == milestoneId);
    if (index == -1) return;

    final milestone = milestones[index];
    milestone.isCompleted = !milestone.isCompleted;
    milestone.completedAt = milestone.isCompleted ? DateTime.now() : null;

    goal.milestones = milestones;

    // Auto-complete goal if all milestones are done
    if (milestones.isNotEmpty && milestones.every((m) => m.isCompleted)) {
      goal.isCompleted = true;
      goal.completedAt = DateTime.now();
    } else {
      goal.isCompleted = false;
      goal.completedAt = null;
    }

    await _storageService.saveGoal(goal);
  }

  /// Remove a milestone from a goal
  Future<void> removeMilestone(String goalId, String milestoneId) async {
    final goal = getGoal(goalId);
    if (goal == null) return;

    goal.milestones = goal.milestones
        .where((m) => m.id != milestoneId)
        .toList();
    await _storageService.saveGoal(goal);
  }

  // ============ STATISTICS ============

  /// Get progress for a specific goal (0.0 - 1.0)
  double getGoalProgress(String goalId) {
    final goal = getGoal(goalId);
    return goal?.progress ?? 0.0;
  }

  /// Get number of active goals
  int getActiveGoalsCount() {
    return getActiveGoals().length;
  }

  /// Get overall progress across all active goals
  double getOverallProgress() {
    final active = getActiveGoals();
    if (active.isEmpty) return 0.0;

    final totalProgress = active.fold(0.0, (sum, g) => sum + g.progress);
    return totalProgress / active.length;
  }
}
