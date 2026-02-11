/// Route names for the application
///
/// Using abstract class with static constants to prevent instantiation
/// and provide type-safe route names.
abstract class AppRoutes {
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String taskForm = '/tasks/form';
  static const String expenses = '/expenses';
  static const String expenseForm = '/expenses/form';
  static const String meditation = '/meditation';
  static const String patternSelector = '/meditation/patterns';

  // New modules
  static const String habits = '/habits';
  static const String habitForm = '/habits/form';
  static const String habitCalendar = '/habits/calendar';
  static const String journal = '/journal';
  static const String journalEntry = '/journal/entry';
  static const String goals = '/goals';
  static const String goalDetail = '/goals/detail';
  static const String goalForm = '/goals/form';
  static const String focus = '/focus';
  static const String focusSettings = '/focus/settings';
  static const String review = '/review';
}
