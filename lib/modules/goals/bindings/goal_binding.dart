import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/goal_repository.dart';
import 'package:daily_dose/modules/goals/controllers/goal_controller.dart';

class GoalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GoalController>(
      () => GoalController(goalRepo: Get.find<GoalRepository>()),
    );
  }
}
