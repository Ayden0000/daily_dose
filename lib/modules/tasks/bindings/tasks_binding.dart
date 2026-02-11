import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/task_repository.dart';
import 'package:daily_dose/modules/tasks/controllers/tasks_controller.dart';

/// Binding for Tasks module
///
/// Injects TasksController with required dependencies.
class TasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TasksController>(
      () => TasksController(taskRepository: Get.find<TaskRepository>()),
    );
  }
}
