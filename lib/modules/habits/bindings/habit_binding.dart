import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/habit_repository.dart';
import 'package:daily_dose/modules/habits/controllers/habit_controller.dart';

class HabitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HabitController>(
      () => HabitController(habitRepo: Get.find<HabitRepository>()),
    );
  }
}
