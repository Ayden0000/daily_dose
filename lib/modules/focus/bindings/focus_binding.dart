import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/focus_repository.dart';
import 'package:daily_dose/data/services/notification_service.dart';
import 'package:daily_dose/modules/focus/controllers/focus_timer_controller.dart';

class FocusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FocusTimerController>(
      () => FocusTimerController(
        focusRepo: Get.find<FocusRepository>(),
        notificationService: Get.find<NotificationService>(),
      ),
    );
  }
}
