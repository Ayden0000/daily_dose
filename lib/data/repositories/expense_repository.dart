import 'package:uuid/uuid.dart';
import 'package:daily_dose/data/models/expense_model.dart';
import 'package:daily_dose/data/services/storage_service.dart';

/// Repository for expense-related business logic
///
/// Handles CRUD operations and summary calculations.
class ExpenseRepository {
  final StorageService _storageService;
  static const _uuid = Uuid();

  ExpenseRepository({required StorageService storageService})
    : _storageService = storageService;

  // ============ CRUD ============

  /// Get all expenses sorted by date (newest first)
  List<ExpenseModel> getAllExpenses() {
    final expenses = _storageService.getAllExpenses();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  /// Get expenses for a specific date
  List<ExpenseModel> getExpensesForDate(DateTime date) {
    return getAllExpenses().where((expense) {
      return expense.date.year == date.year &&
          expense.date.month == date.month &&
          expense.date.day == date.day;
    }).toList();
  }

  /// Get today's expenses
  List<ExpenseModel> getTodaysExpenses() {
    return getExpensesForDate(DateTime.now());
  }

  /// Get this week's expenses
  List<ExpenseModel> getThisWeeksExpenses() {
    return getAllExpenses().where((e) => e.isThisWeek).toList();
  }

  /// Get this month's expenses
  List<ExpenseModel> getThisMonthsExpenses() {
    return getAllExpenses().where((e) => e.isThisMonth).toList();
  }

  /// Get expense by ID
  ExpenseModel? getExpense(String id) {
    return _storageService.getExpense(id);
  }

  /// Create a new expense
  Future<ExpenseModel> createExpense({
    required double amount,
    required String category,
    String? note,
    DateTime? date,
  }) async {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      note: note,
      date: date ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
    await _storageService.saveExpense(expense);
    return expense;
  }

  /// Update an existing expense
  Future<void> updateExpense(ExpenseModel expense) async {
    await _storageService.saveExpense(expense);
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    await _storageService.deleteExpense(id);
  }

  // ============ SUMMARIES ============

  /// Get today's total
  double getTodaysTotal() {
    return getTodaysExpenses().fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get this week's total
  double getThisWeeksTotal() {
    return getThisWeeksExpenses().fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get this month's total
  double getThisMonthsTotal() {
    return getThisMonthsExpenses().fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get expenses grouped by category for a list of expenses
  Map<String, double> getCategoryTotals(List<ExpenseModel> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  /// Get this month's category breakdown
  Map<String, double> getThisMonthsCategoryTotals() {
    return getCategoryTotals(getThisMonthsExpenses());
  }

  /// Get daily totals for the last N days
  Map<DateTime, double> getDailyTotals({int days = 7}) {
    final totals = <DateTime, double>{};
    final now = DateTime.now();

    for (var i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayExpenses = getExpensesForDate(date);
      totals[date] = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    }

    return totals;
  }

  /// Get average daily expense for current month
  double getAverageDailyExpense() {
    final monthExpenses = getThisMonthsExpenses();
    if (monthExpenses.isEmpty) return 0.0;

    final total = getThisMonthsTotal();
    final daysPassed = DateTime.now().day;
    return total / daysPassed;
  }
}
