import 'package:get/get.dart';
import 'package:daily_dose/data/repositories/expense_repository.dart';
import 'package:daily_dose/modules/expenses/controllers/expenses_controller.dart';

/// Binding for Expenses module
class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpensesController>(
      () =>
          ExpensesController(expenseRepository: Get.find<ExpenseRepository>()),
    );
  }
}
