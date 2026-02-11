import 'package:get/get.dart';
import 'package:daily_dose/data/services/analytics_service.dart';
import 'package:daily_dose/modules/review/controllers/review_controller.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewController>(
      () => ReviewController(analyticsService: Get.find<AnalyticsService>()),
    );
  }
}
