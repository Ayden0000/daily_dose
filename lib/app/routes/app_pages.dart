import 'package:get/get.dart';
import 'package:daily_dose/app/routes/app_routes.dart';
import 'package:daily_dose/modules/home/bindings/home_binding.dart';
import 'package:daily_dose/modules/home/views/home_view.dart';
import 'package:daily_dose/modules/tasks/bindings/tasks_binding.dart';
import 'package:daily_dose/modules/tasks/views/tasks_view.dart';
import 'package:daily_dose/modules/tasks/views/task_form_view.dart';
import 'package:daily_dose/modules/meditation/bindings/meditation_binding.dart';
import 'package:daily_dose/modules/meditation/views/meditation_view.dart';
import 'package:daily_dose/modules/meditation/views/pattern_selector_view.dart';
import 'package:daily_dose/modules/expenses/bindings/expenses_binding.dart';
import 'package:daily_dose/modules/expenses/views/expenses_view.dart';
import 'package:daily_dose/modules/habits/bindings/habit_binding.dart';
import 'package:daily_dose/modules/habits/views/habit_view.dart';
import 'package:daily_dose/modules/journal/bindings/journal_binding.dart';
import 'package:daily_dose/modules/journal/views/journal_view.dart';
import 'package:daily_dose/modules/goals/bindings/goal_binding.dart';
import 'package:daily_dose/modules/goals/views/goal_view.dart';
import 'package:daily_dose/modules/focus/bindings/focus_binding.dart';
import 'package:daily_dose/modules/focus/views/focus_view.dart';
import 'package:daily_dose/modules/review/bindings/review_binding.dart';
import 'package:daily_dose/modules/review/views/review_view.dart';

/// Application page routes configuration
///
/// Each page is wrapped with its binding for dependency injection.
/// Using GetX's GetPage for lazy loading and route management.
class AppPages {
  AppPages._();

  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TasksView(),
      binding: TasksBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.taskForm,
      page: () => const TaskFormView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.expenses,
      page: () => const ExpensesView(),
      binding: ExpensesBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.meditation,
      page: () => const MeditationView(),
      binding: MeditationBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.patternSelector,
      page: () => const PatternSelectorView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // ============ NEW MODULES ============
    GetPage(
      name: AppRoutes.habits,
      page: () => const HabitView(),
      binding: HabitBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.journal,
      page: () => const JournalView(),
      binding: JournalBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.goals,
      page: () => const GoalView(),
      binding: GoalBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.focus,
      page: () => const FocusView(),
      binding: FocusBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.review,
      page: () => const ReviewView(),
      binding: ReviewBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 200),
    ),
  ];
}
