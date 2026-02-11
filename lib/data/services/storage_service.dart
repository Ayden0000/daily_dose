import 'package:get/get.dart';
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
import 'package:daily_dose/data/models/focus_session_model.dart';

/// Storage service for Hive database operations
///
/// Provides generic CRUD operations and box access.
/// Initialized at app startup via HiveConfig.
class StorageService extends GetxService {
  // ============ BOX GETTERS ============

  Box<TaskModel> get tasksBox => Hive.box<TaskModel>(AppConstants.tasksBox);
  Box<ExpenseModel> get expensesBox =>
      Hive.box<ExpenseModel>(AppConstants.expensesBox);
  Box<BreathingPatternModel> get patternsBox =>
      Hive.box<BreathingPatternModel>(AppConstants.patternsBox);
  Box<MeditationSessionModel> get sessionsBox =>
      Hive.box<MeditationSessionModel>(AppConstants.sessionsBox);
  Box get settingsBox => Hive.box(AppConstants.settingsBox);
  Box<HabitModel> get habitsBox => Hive.box<HabitModel>(AppConstants.habitsBox);
  Box<HabitCompletionModel> get habitCompletionsBox =>
      Hive.box<HabitCompletionModel>(AppConstants.habitCompletionsBox);
  Box<JournalEntryModel> get journalBox =>
      Hive.box<JournalEntryModel>(AppConstants.journalBox);
  Box<GoalModel> get goalsBox => Hive.box<GoalModel>(AppConstants.goalsBox);
  Box<FocusSessionModel> get focusSessionsBox =>
      Hive.box<FocusSessionModel>(AppConstants.focusSessionsBox);

  // ============ TASKS ============

  List<TaskModel> getAllTasks() {
    return tasksBox.values.toList();
  }

  TaskModel? getTask(String id) {
    return tasksBox.get(id);
  }

  Future<void> saveTask(TaskModel task) async {
    await tasksBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await tasksBox.delete(id);
  }

  // ============ EXPENSES ============

  List<ExpenseModel> getAllExpenses() {
    return expensesBox.values.toList();
  }

  ExpenseModel? getExpense(String id) {
    return expensesBox.get(id);
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    await expensesBox.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await expensesBox.delete(id);
  }

  // ============ BREATHING PATTERNS ============

  List<BreathingPatternModel> getAllPatterns() {
    return patternsBox.values.toList();
  }

  BreathingPatternModel? getPattern(String id) {
    return patternsBox.get(id);
  }

  Future<void> savePattern(BreathingPatternModel pattern) async {
    await patternsBox.put(pattern.id, pattern);
  }

  Future<void> deletePattern(String id) async {
    await patternsBox.delete(id);
  }

  // ============ MEDITATION SESSIONS ============

  List<MeditationSessionModel> getAllSessions() {
    return sessionsBox.values.toList();
  }

  Future<void> saveSession(MeditationSessionModel session) async {
    await sessionsBox.put(session.id, session);
  }

  // ============ HABITS ============

  List<HabitModel> getAllHabits() {
    return habitsBox.values.toList();
  }

  HabitModel? getHabit(String id) {
    return habitsBox.get(id);
  }

  Future<void> saveHabit(HabitModel habit) async {
    await habitsBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await habitsBox.delete(id);
  }

  // ============ HABIT COMPLETIONS ============

  List<HabitCompletionModel> getAllHabitCompletions() {
    return habitCompletionsBox.values.toList();
  }

  Future<void> saveHabitCompletion(HabitCompletionModel completion) async {
    await habitCompletionsBox.put(completion.id, completion);
  }

  Future<void> deleteHabitCompletion(String id) async {
    await habitCompletionsBox.delete(id);
  }

  // ============ JOURNAL ENTRIES ============

  List<JournalEntryModel> getAllJournalEntries() {
    return journalBox.values.toList();
  }

  JournalEntryModel? getJournalEntry(String id) {
    return journalBox.get(id);
  }

  Future<void> saveJournalEntry(JournalEntryModel entry) async {
    await journalBox.put(entry.id, entry);
  }

  Future<void> deleteJournalEntry(String id) async {
    await journalBox.delete(id);
  }

  // ============ GOALS ============

  List<GoalModel> getAllGoals() {
    return goalsBox.values.toList();
  }

  GoalModel? getGoal(String id) {
    return goalsBox.get(id);
  }

  Future<void> saveGoal(GoalModel goal) async {
    await goalsBox.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await goalsBox.delete(id);
  }

  // ============ FOCUS SESSIONS ============

  List<FocusSessionModel> getAllFocusSessions() {
    return focusSessionsBox.values.toList();
  }

  Future<void> saveFocusSession(FocusSessionModel session) async {
    await focusSessionsBox.put(session.id, session);
  }

  Future<void> deleteFocusSession(String id) async {
    await focusSessionsBox.delete(id);
  }

  // ============ SETTINGS ============

  T? getSetting<T>(String key) {
    return settingsBox.get(key) as T?;
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  // ============ UTILITY ============

  Future<void> clearAllData() async {
    await tasksBox.clear();
    await expensesBox.clear();
    await patternsBox.clear();
    await sessionsBox.clear();
    await settingsBox.clear();
    await habitsBox.clear();
    await habitCompletionsBox.clear();
    await journalBox.clear();
    await goalsBox.clear();
    await focusSessionsBox.clear();
  }
}
