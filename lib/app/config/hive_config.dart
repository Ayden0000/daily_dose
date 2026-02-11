import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_dose/app/config/constants.dart';
import 'package:daily_dose/data/models/task_model.dart';
import 'package:daily_dose/data/models/expense_model.dart';
import 'package:daily_dose/data/models/breathing_pattern_model.dart';
import 'package:daily_dose/data/models/meditation_session_model.dart';
import 'package:daily_dose/data/models/habit_model.dart';
import 'package:daily_dose/data/models/habit_completion_model.dart';
import 'package:daily_dose/data/models/journal_entry_model.dart';
import 'package:daily_dose/data/models/goal_model.dart';
import 'package:daily_dose/data/models/goal_milestone_model.dart';
import 'package:daily_dose/data/models/focus_session_model.dart';

/// Hive database configuration and initialization
class HiveConfig {
  HiveConfig._();

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters — existing
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(BreathingPatternModelAdapter());
    Hive.registerAdapter(MeditationSessionModelAdapter());

    // Register adapters — new modules
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(HabitCompletionModelAdapter());
    Hive.registerAdapter(JournalEntryModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(GoalMilestoneModelAdapter());
    Hive.registerAdapter(FocusSessionModelAdapter());

    // Open boxes — existing
    await Hive.openBox<TaskModel>(AppConstants.tasksBox);
    await Hive.openBox<ExpenseModel>(AppConstants.expensesBox);
    await Hive.openBox<BreathingPatternModel>(AppConstants.patternsBox);
    await Hive.openBox<MeditationSessionModel>(AppConstants.sessionsBox);
    await Hive.openBox(AppConstants.settingsBox);

    // Open boxes — new modules
    await Hive.openBox<HabitModel>(AppConstants.habitsBox);
    await Hive.openBox<HabitCompletionModel>(AppConstants.habitCompletionsBox);
    await Hive.openBox<JournalEntryModel>(AppConstants.journalBox);
    await Hive.openBox<GoalModel>(AppConstants.goalsBox);
    await Hive.openBox<FocusSessionModel>(AppConstants.focusSessionsBox);
  }

  static Future<void> clearAll() async {
    await Hive.box<TaskModel>(AppConstants.tasksBox).clear();
    await Hive.box<ExpenseModel>(AppConstants.expensesBox).clear();
    await Hive.box<BreathingPatternModel>(AppConstants.patternsBox).clear();
    await Hive.box<MeditationSessionModel>(AppConstants.sessionsBox).clear();
    await Hive.box<HabitModel>(AppConstants.habitsBox).clear();
    await Hive.box<HabitCompletionModel>(
      AppConstants.habitCompletionsBox,
    ).clear();
    await Hive.box<JournalEntryModel>(AppConstants.journalBox).clear();
    await Hive.box<GoalModel>(AppConstants.goalsBox).clear();
    await Hive.box<FocusSessionModel>(AppConstants.focusSessionsBox).clear();
  }
}
