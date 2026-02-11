import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/meditation_repository.dart';
import 'package:daily_dose/data/services/audio_service.dart';
import 'package:daily_dose/data/services/vibration_service.dart';
import 'package:daily_dose/modules/meditation/controllers/meditation_controller.dart';

/// Binding for Meditation module
class MeditationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeditationController>(
      () => MeditationController(
        meditationRepository: Get.find<MeditationRepository>(),
        audioService: Get.find<AudioService>(),
        vibrationService: Get.find<VibrationService>(),
      ),
    );
  }
}
