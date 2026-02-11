import 'package:uuid/uuid.dart';
import 'package:daily_dose/data/models/task_model.dart';
import 'package:daily_dose/data/services/storage_service.dart';

/// Repository for task-related business logic
///
/// Handles CRUD operations, filtering, and streak calculations.
/// Does NOT contain UI logic - only data operations.
class TaskRepository {
  final StorageService _storageService;
  static const _uuid = Uuid();

  TaskRepository({required StorageService storageService})
    : _storageService = storageService;

  // ============ CRUD ============

  /// Get all tasks sorted by creation date (newest first)
  List<TaskModel> getAllTasks() {
    final tasks = _storageService.getAllTasks();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  /// Get tasks for a specific date
  List<TaskModel> getTasksForDate(DateTime date) {
    return getAllTasks().where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  /// Get today's tasks
  List<TaskModel> getTodaysTasks() {
    return getTasksForDate(DateTime.now());
  }

  /// Get incomplete tasks
  List<TaskModel> getIncompleteTasks() {
    return getAllTasks().where((task) => !task.isCompleted).toList();
  }

  /// Get overdue tasks
  List<TaskModel> getOverdueTasks() {
    return getAllTasks().where((task) => task.isOverdue).toList();
  }

  /// Get task by ID
  TaskModel? getTask(String id) {
    return _storageService.getTask(id);
  }

  /// Create a new task
  Future<TaskModel> createTask({
    required String title,
    String? description,
    int priority = 2,
    DateTime? dueDate,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    await _storageService.saveTask(task);
    return task;
  }

  /// Update an existing task
  Future<void> updateTask(TaskModel task) async {
    await _storageService.saveTask(task);
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    await _storageService.deleteTask(id);
  }

  // ============ DAILY RESET ============

  /// Reset tasks that were completed on a previous day.
  ///
  /// Called at app startup and when loading the home/task screen.
  /// This unmarks `isCompleted` so daily tasks feel fresh each morning,
  /// while preserving `streakCount` history.
  Future<int> resetDailyTasks() async {
    final now = DateTime.now();
    var resetCount = 0;

    for (final task in getAllTasks()) {
      if (!task.isCompleted) continue;
      if (task.completedAt == null) continue;

      final ca = task.completedAt!;
      final isToday =
          ca.year == now.year && ca.month == now.month && ca.day == now.day;

      if (!isToday) {
        task.isCompleted = false;
        task.completedAt = null;
        // Move dueDate to today so the task re-appears in Today's list
        task.dueDate = DateTime(
          now.year,
          now.month,
          now.day,
          task.dueDate?.hour ?? 0,
          task.dueDate?.minute ?? 0,
        );
        await _storageService.saveTask(task);
        resetCount++;
      }
    }
    return resetCount;
  }

  // ============ COMPLETION ============

  /// Mark task as completed
  Future<TaskModel> completeTask(String id) async {
    final task = getTask(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    task.isCompleted = true;
    task.completedAt = DateTime.now();
    task.streakCount += 1;

    await _storageService.saveTask(task);
    return task;
  }

  /// Mark task as incomplete
  Future<TaskModel> uncompleteTask(String id) async {
    final task = getTask(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    task.isCompleted = false;
    task.completedAt = null;

    await _storageService.saveTask(task);
    return task;
  }

  /// Toggle task completion status
  Future<TaskModel> toggleTaskCompletion(String id) async {
    final task = getTask(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    if (task.isCompleted) {
      return uncompleteTask(id);
    } else {
      return completeTask(id);
    }
  }

  // ============ STATISTICS ============

  /// Get today's completion count
  int getTodaysCompletedCount() {
    return getTodaysTasks().where((t) => t.isCompleted).length;
  }

  /// Get today's total task count
  int getTodaysTotalCount() {
    return getTodaysTasks().length;
  }

  /// Calculate overall completion rate
  double getCompletionRate() {
    final all = getAllTasks();
    if (all.isEmpty) return 0.0;
    final completed = all.where((t) => t.isCompleted).length;
    return completed / all.length;
  }

  /// Get current streak (consecutive days with all tasks completed)
  int getCurrentStreak() {
    var streak = 0;
    var date = DateTime.now();
    var daysChecked = 0;
    const maxDaysToCheck = 365;

    while (daysChecked < maxDaysToCheck) {
      final tasks = getTasksForDate(date);
      daysChecked++;

      if (tasks.isEmpty) {
        // No tasks for this day, skip to previous day
        date = date.subtract(const Duration(days: 1));
        continue;
      }

      final allCompleted = tasks.every((t) => t.isCompleted);
      if (!allCompleted) break;

      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
