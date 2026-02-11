import 'package:get/get.dart';
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
  void loadTasks() {
    try {
      isLoading.value = true;
      errorMessage.value = '';

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
    loadTasks();
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

      loadTasks();
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
      loadTasks();
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
      loadTasks();
    } catch (e) {
      errorMessage.value = 'Failed to delete task: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String id) async {
    try {
      await _taskRepository.toggleTaskCompletion(id);
      loadTasks();
    } catch (e) {
      errorMessage.value = 'Failed to update task: $e';
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
