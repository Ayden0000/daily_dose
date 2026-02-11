/// Application-wide constants
/// All magic numbers and configuration values live here

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'DailyFlow';
  static const String appVersion = '1.0.0';

  // ============ HIVE BOX NAMES ============

  static const String tasksBox = 'tasks';
  static const String expensesBox = 'expenses';
  static const String patternsBox = 'breathing_patterns';
  static const String sessionsBox = 'meditation_sessions';
  static const String settingsBox = 'settings';
  static const String habitsBox = 'habits';
  static const String habitCompletionsBox = 'habit_completions';
  static const String journalBox = 'journal_entries';
  static const String goalsBox = 'goals';
  static const String focusSessionsBox = 'focus_sessions';

  // ============ ANIMATION DURATIONS (ms) ============

  static const int shortAnimation = 200;
  static const int mediumAnimation = 300;
  static const int longAnimation = 500;

  // ============ MEDITATION DEFAULTS ============

  static const int defaultBpm = 50;
  static const double tickFrequency =
      60 / 50; // seconds between ticks at 50 BPM

  // ============ PRIORITY LEVELS ============

  static const int priorityLow = 1;
  static const int priorityMedium = 2;
  static const int priorityHigh = 3;

  // ============ EXPENSE CATEGORIES ============

  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Bills',
    'Other',
  ];

  // ============ HABIT CONSTANTS ============

  /// Default streak threshold: 70% completion = streak maintained
  /// This prevents perfectionism — users don't need 100% to keep streaks
  static const double defaultStreakThreshold = 0.7;

  /// Habit frequency types
  static const int frequencyDaily = 1;
  static const int frequencyWeekdays = 2;
  static const int frequencyCustom = 3;

  static const List<String> habitCategories = [
    'Health',
    'Fitness',
    'Learning',
    'Mindfulness',
    'Productivity',
    'Social',
    'Creative',
    'Other',
  ];

  // ============ MOOD / JOURNAL CONSTANTS ============

  /// Mood scale: 1 = Awful, 2 = Bad, 3 = Okay, 4 = Good, 5 = Great
  static const int moodMin = 1;
  static const int moodMax = 5;

  static const List<String> moodLabels = [
    'Awful',
    'Bad',
    'Okay',
    'Good',
    'Great',
  ];

  static const List<String> moodEmojis = ['😞', '😔', '😐', '🙂', '😄'];

  static const List<String> journalTags = [
    'Productive',
    'Stressed',
    'Energetic',
    'Calm',
    'Grateful',
    'Anxious',
    'Motivated',
    'Tired',
    'Happy',
    'Focused',
  ];

  // ============ FOCUS TIMER CONSTANTS ============

  /// Pomodoro defaults (in minutes)
  static const int defaultFocusDuration = 25;
  static const int defaultShortBreak = 5;
  static const int defaultLongBreak = 15;
  static const int sessionsBeforeLongBreak = 4;

  /// Focus session types
  static const String sessionTypeFocus = 'focus';
  static const String sessionTypeShortBreak = 'shortBreak';
  static const String sessionTypeLongBreak = 'longBreak';

  // ============ GOAL CONSTANTS ============

  static const List<String> goalCategories = [
    'Health',
    'Career',
    'Financial',
    'Personal',
    'Education',
    'Fitness',
    'Relationships',
    'Other',
  ];

  // ============ NOTIFICATION CONSTANTS ============

  static const String settingNotificationsEnabled = 'notifications_enabled';
  static const String settingMorningReminder = 'morning_reminder';
  static const String settingEveningReminder = 'evening_reminder';

  /// Notification IDs — unique per notification type to allow cancellation
  static const int notificationIdFocusComplete = 1001;
  static const int notificationIdBreakComplete = 1002;
  static const int notificationIdMorningReminder = 2001;
  static const int notificationIdEveningReminder = 2002;
  static const int notificationIdHabitBase = 3000; // + habit index

  // Default breathing patterns [inhale, hold1, exhale, hold2]
  static const List<Map<String, dynamic>> defaultBreathingPatterns = [
    {'name': 'Calm', 'inhale': 4, 'hold1': 4, 'exhale': 4, 'hold2': 4},
    {'name': 'Relax', 'inhale': 4, 'hold1': 7, 'exhale': 8, 'hold2': 0},
    {'name': 'Focus', 'inhale': 3, 'hold1': 5, 'exhale': 5, 'hold2': 5},
    {'name': 'Energize', 'inhale': 3, 'hold1': 5, 'exhale': 5, 'hold2': 6},
  ];
}
