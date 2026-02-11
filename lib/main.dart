import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/bindings/initial_binding.dart';
import 'package:daily_dose/app/config/hive_config.dart';
import 'package:daily_dose/app/routes/app_pages.dart';
import 'package:daily_dose/app/theme/app_theme.dart';

/// Application entry point
///
/// Initializes Hive database and sets up GetX framework
/// with theme, routes, and initial bindings.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive database
  await HiveConfig.init();

  runApp(const DailyFlowApp());
}

class DailyFlowApp extends StatelessWidget {
  const DailyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DailyFlow',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Initial binding for global services
      initialBinding: InitialBinding(),

      // Route configuration
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Default transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
