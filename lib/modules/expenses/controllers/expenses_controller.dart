import 'package:get/get.dart';
import 'package:daily_dose/widgets/app_toast.dart';
import 'package:daily_dose/data/models/expense_model.dart';
import 'package:daily_dose/data/repositories/expense_repository.dart';
import 'package:daily_dose/app/config/constants.dart';

/// Controller for Expenses module
///
/// Manages expense state and operations.
class ExpensesController extends GetxController {
  final ExpenseRepository _expenseRepository;

  ExpensesController({required ExpenseRepository expenseRepository})
    : _expenseRepository = expenseRepository;

  // ============ REACTIVE STATE ============

  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Summary values
  final RxDouble todaysTotal = 0.0.obs;
  final RxDouble weeksTotal = 0.0.obs;
  final RxDouble monthsTotal = 0.0.obs;
  final RxMap<String, double> categoryTotals = <String, double>{}.obs;

  // View state
  final RxInt selectedPeriod = 0.obs; // 0 = today, 1 = week, 2 = month

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  // ============ DATA LOADING ============

  /// Load all expenses and summaries
  Future<void> loadExpenses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      expenses.value = _expenseRepository.getAllExpenses();
      _updateSummaries();
    } catch (e) {
      errorMessage.value = 'Failed to load expenses: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Update summary values
  void _updateSummaries() {
    todaysTotal.value = _expenseRepository.getTodaysTotal();
    weeksTotal.value = _expenseRepository.getThisWeeksTotal();
    monthsTotal.value = _expenseRepository.getThisMonthsTotal();
    categoryTotals.value = _expenseRepository.getThisMonthsCategoryTotals();
  }

  /// Refresh expenses
  Future<void> refreshExpenses() async {
    await loadExpenses();
  }

  // ============ COMPUTED GETTERS ============

  /// Get expenses for selected period
  List<ExpenseModel> get periodExpenses {
    switch (selectedPeriod.value) {
      case 0:
        return _expenseRepository.getTodaysExpenses();
      case 1:
        return _expenseRepository.getThisWeeksExpenses();
      case 2:
        return _expenseRepository.getThisMonthsExpenses();
      default:
        return expenses;
    }
  }

  /// Get current period total
  double get periodTotal {
    switch (selectedPeriod.value) {
      case 0:
        return todaysTotal.value;
      case 1:
        return weeksTotal.value;
      case 2:
        return monthsTotal.value;
      default:
        return 0.0;
    }
  }

  /// Get category list for dropdown
  List<String> get categories => AppConstants.expenseCategories;

  // ============ CRUD OPERATIONS ============

  /// Create a new expense
  Future<void> createExpense({
    required double amount,
    required String category,
    String? note,
    DateTime? date,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _expenseRepository.createExpense(
        amount: amount,
        category: category,
        note: note,
        date: date,
      );

      await loadExpenses();
    } catch (e) {
      errorMessage.value = 'Failed to create expense: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an expense
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _expenseRepository.updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      errorMessage.value = 'Failed to update expense: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    final existingIndex = expenses.indexWhere((e) => e.id == id);
    if (existingIndex == -1) return;

    final removed = expenses[existingIndex];

    // Optimistic remove
    expenses.removeAt(existingIndex);
    expenses.refresh();
    _updateSummaries();

    try {
      await _expenseRepository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      // Revert on failure
      expenses.insert(existingIndex, removed);
      expenses.refresh();
      _updateSummaries();
      errorMessage.value = 'Failed to delete expense: $e';
      AppToast.error(Get.context!, 'Could not delete expense');
    }
  }

  // ============ PERIOD SELECTION ============

  /// Set selected period
  void setSelectedPeriod(int period) {
    selectedPeriod.value = period;
  }
}
