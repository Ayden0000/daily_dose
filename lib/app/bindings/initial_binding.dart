import 'package:get/get.dart';
import 'package:daily_dose/data/services/storage_service.dart';
import 'package:daily_dose/data/services/audio_service.dart';
import 'package:daily_dose/data/services/vibration_service.dart';
import 'package:daily_dose/data/services/notification_service.dart';
import 'package:daily_dose/data/services/analytics_service.dart';
import 'package:daily_dose/data/repositories/task_repository.dart';
import 'package:daily_dose/data/repositories/expense_repository.dart';
import 'package:daily_dose/data/repositories/meditation_repository.dart';
import 'package:daily_dose/data/repositories/habit_repository.dart';
import 'package:daily_dose/data/repositories/journal_repository.dart';
import 'package:daily_dose/data/repositories/goal_repository.dart';
import 'package:daily_dose/data/repositories/focus_repository.dart';

/// Initial binding that registers core services and repositories
///
/// These are app-level singletons that persist across the entire
/// application lifecycle. They are injected before the first screen loads.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services (lowest layer - no dependencies)
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<AudioService>(AudioService(), permanent: true);
    Get.put<VibrationService>(VibrationService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);

    // Repositories (depend on services)
    Get.put<TaskRepository>(
      TaskRepository(storageService: Get.find<StorageService>()),
      permanent: true,
    );
    Get.put<ExpenseRepository>(
      ExpenseRepository(storageService: Get.find<StorageService>()),
      permanent: true,
    );
    Get.put<MeditationRepository>(
      MeditationRepository(storageService: Get.find<StorageService>()),
      permanent: true,
    );
    Get.put<HabitRepository>(
      HabitRepository(storageService: Get.find<StorageService>()),
      permanent: true,
    );
    Get.put<JournalRepository>(
      JournalRepository(storageService: Get.find<StorageService>()),
      permanent: true,
    );
    Get.put<GoalRepository>(
      GoalRepository(storageService: Get.find<StorageService>()),
      permanent: true,
    );
    Get.put<FocusRepository>(
      FocusRepository(storageService: Get.find<StorageService>()),
      permanent: true,
    );

    // Analytics service (depends on repositories)
    Get.put<AnalyticsService>(
      AnalyticsService(
        taskRepo: Get.find<TaskRepository>(),
        expenseRepo: Get.find<ExpenseRepository>(),
        meditationRepo: Get.find<MeditationRepository>(),
        habitRepo: Get.find<HabitRepository>(),
        journalRepo: Get.find<JournalRepository>(),
        focusRepo: Get.find<FocusRepository>(),
      ),
      permanent: true,
    );
  }
}
