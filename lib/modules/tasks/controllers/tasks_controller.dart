import 'package:get/get.dart';
import 'package:daily_dose/widgets/app_toast.dart';
import 'package:daily_dose/data/models/task_model.dart';
import 'package:daily_dose/data/repositories/task_repository.dart';

/// Controller for Tasks module
///
/// Manages task state and operations. All business logic
/// is delegated to TaskRepository.
class TasksController extends GetxController {
  final TaskRepository _taskRepository;

  TasksController({required TaskRepository taskRepository})
    : _taskRepository = taskRepository;

  // ============ REACTIVE STATE ============

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxList<TaskModel> todaysTasks = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentStreak = 0.obs;

  // Filter state
  final RxBool showCompleted = true.obs;
  final RxInt filterPriority = 0.obs; // 0 = all

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  // ============ DATA LOADING ============

  /// Load all tasks from repository
  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Reset stale completions from previous days
      await _taskRepository.resetDailyTasks();

      tasks.value = _taskRepository.getAllTasks();
      todaysTasks.value = _taskRepository.getTodaysTasks();
      currentStreak.value = _taskRepository.getCurrentStreak();
    } catch (e) {
      errorMessage.value = 'Failed to load tasks: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh tasks (pull-to-refresh)
  Future<void> refreshTasks() async {
    await loadTasks();
  }

  // ============ COMPUTED GETTERS ============

  /// Filtered tasks based on current filter state
  List<TaskModel> get filteredTasks {
    var result = tasks.toList();

    // Filter by completion status
    if (!showCompleted.value) {
      result = result.where((t) => !t.isCompleted).toList();
    }

    // Filter by priority
    if (filterPriority.value > 0) {
      result = result.where((t) => t.priority == filterPriority.value).toList();
    }

    return result;
  }

  /// Today's completion progress (0.0 - 1.0)
  double get todaysProgress {
    if (todaysTasks.isEmpty) return 0.0;
    final completed = todaysTasks.where((t) => t.isCompleted).length;
    return completed / todaysTasks.length;
  }

  /// Today's completed count
  int get todaysCompletedCount {
    return todaysTasks.where((t) => t.isCompleted).length;
  }

  // ============ CRUD OPERATIONS ============

  /// Create a new task
  Future<void> createTask({
    required String title,
    String? description,
    int priority = 2,
    DateTime? dueDate,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _taskRepository.createTask(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );

      await loadTasks();
    } catch (e) {
      errorMessage.value = 'Failed to create task: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing task
  Future<void> updateTask(TaskModel task) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _taskRepository.updateTask(task);
      await loadTasks();
    } catch (e) {
      errorMessage.value = 'Failed to update task: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _taskRepository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      errorMessage.value = 'Failed to delete task: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String id) async {
    // Optimistic update for snappier UI
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final original = tasks[index];
    final toggled = original.copyWith(
      isCompleted: !original.isCompleted,
      completedAt: original.isCompleted ? null : DateTime.now(),
      streakCount: original.isCompleted
          ? original.streakCount
          : original.streakCount + 1,
    );

    tasks[index] = toggled;
    tasks.refresh();

    final todayIndex = todaysTasks.indexWhere((t) => t.id == id);
    if (todayIndex != -1) {
      todaysTasks[todayIndex] = toggled;
      todaysTasks.refresh();
    }

    try {
      await _taskRepository.toggleTaskCompletion(id);

      // Pull fresh record to sync derived fields (streak count, completedAt)
      final fresh = _taskRepository.getTask(id);
      if (fresh != null) {
        tasks[index] = fresh;
        tasks.refresh();
        if (todayIndex != -1) {
          todaysTasks[todayIndex] = fresh;
          todaysTasks.refresh();
        }
      }

      currentStreak.value = _taskRepository.getCurrentStreak();
    } catch (e) {
      // Revert on failure
      tasks[index] = original;
      tasks.refresh();
      if (todayIndex != -1) {
        todaysTasks[todayIndex] = original;
        todaysTasks.refresh();
      }
      errorMessage.value = 'Failed to update task: $e';
      AppToast.error(Get.context!, 'Could not update task status');
    }
  }

  // ============ FILTER ACTIONS ============

  /// Toggle show completed filter
  void toggleShowCompleted() {
    showCompleted.toggle();
  }

  /// Set priority filter
  void setFilterPriority(int priority) {
    filterPriority.value = priority;
  }

  /// Clear all filters
  void clearFilters() {
    showCompleted.value = true;
    filterPriority.value = 0;
  }
}
