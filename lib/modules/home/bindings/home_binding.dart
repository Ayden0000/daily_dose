import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/task_repository.dart';
import 'package:daily_dose/data/repositories/expense_repository.dart';
import 'package:daily_dose/data/repositories/meditation_repository.dart';
import 'package:daily_dose/data/repositories/habit_repository.dart';
import 'package:daily_dose/data/repositories/journal_repository.dart';
import 'package:daily_dose/data/repositories/goal_repository.dart';
import 'package:daily_dose/data/repositories/focus_repository.dart';
import 'package:daily_dose/modules/home/controllers/home_controller.dart';

/// Binding for Home module
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        taskRepository: Get.find<TaskRepository>(),
        expenseRepository: Get.find<ExpenseRepository>(),
        meditationRepository: Get.find<MeditationRepository>(),
        habitRepository: Get.find<HabitRepository>(),
        journalRepository: Get.find<JournalRepository>(),
        goalRepository: Get.find<GoalRepository>(),
        focusRepository: Get.find<FocusRepository>(),
      ),
    );
  }
}
