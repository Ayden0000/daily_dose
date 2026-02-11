import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/journal_repository.dart';
import 'package:daily_dose/modules/journal/controllers/journal_controller.dart';

class JournalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JournalController>(
      () => JournalController(journalRepo: Get.find<JournalRepository>()),
    );
  }
}
