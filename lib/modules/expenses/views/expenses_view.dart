import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:get/get.dart';
import 'package:daily_dose/modules/expenses/controllers/expenses_controller.dart';
import 'package:daily_dose/widgets/empty_state.dart';
import 'package:daily_dose/widgets/loading_state.dart';
import 'package:daily_dose/widgets/app_button.dart';
import 'package:intl/intl.dart';

/// Expenses View - Premium Design
class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0D1A)
          : const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingState();
          }

          return Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: controller.periodExpenses.isEmpty
                    ? EmptyState(
                        icon: AppIcons.wallet,
                        title: 'No expenses yet',
                        subtitle: 'Start tracking your spending',
                        action: AppButton(
                          label: 'Add Expense',
                          icon: AppIcons.add,
                          onPressed: () => _showExpenseForm(context, isDark),
                        ),
                      )
                    : _buildExpenseList(context, isDark),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: _buildFAB(context, isDark),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white,
                  ),
                  child: Icon(
                    AppIcons.arrowLeft,
                    size: 18,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Summary card
          Obx(
            () => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getPeriodLabel(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Text(
                          '${controller.periodExpenses.length} items',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${controller.periodTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Period selector
                  Row(
                    children: [
                      _PeriodChip(label: 'Today', index: 0, isDark: isDark),
                      const SizedBox(width: 8),
                      _PeriodChip(label: 'Week', index: 1, isDark: isDark),
                      const SizedBox(width: 8),
                      _PeriodChip(label: 'Month', index: 2, isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel() {
    switch (controller.selectedPeriod.value) {
      case 0:
        return 'Spent Today';
      case 1:
        return 'This Week';
      case 2:
        return 'This Month';
      default:
        return 'Total Spent';
    }
  }

  Widget _buildExpenseList(BuildContext context, bool isDark) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.periodExpenses.length,
        itemBuilder: (context, index) {
          final expense = controller.periodExpenses[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(expense.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => controller.deleteExpense(expense.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                ),
                child: Icon(AppIcons.delete, color: Colors.white, size: 28),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  children: [
                    // Category icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: _getCategoryGradient(expense.category),
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(expense.category),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.category,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (expense.note != null &&
                              expense.note!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              expense.note!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Amount and date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.MMMd().format(expense.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAB(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showExpenseForm(context, isDark),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(AppIcons.add, color: Colors.white, size: 28),
      ),
    );
  }

  dynamic _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return AppIcons.food;
      case 'Transport':
        return AppIcons.transport;
      case 'Shopping':
        return AppIcons.shopping;
      case 'Entertainment':
        return AppIcons.entertainment;
      case 'Health':
        return AppIcons.health;
      case 'Bills':
        return AppIcons.bills;
      default:
        return AppIcons.money;
    }
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category) {
      case 'Food':
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
      case 'Transport':
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
      case 'Shopping':
        return [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)];
      case 'Entertainment':
        return [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)];
      case 'Health':
        return [const Color(0xFF11998E), const Color(0xFF38EF7D)];
      case 'Bills':
        return [const Color(0xFFFDC830), const Color(0xFFF37335)];
      default:
        return [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)];
    }
  }

  void _showExpenseForm(BuildContext context, bool isDark) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final selectedCategory = controller.categories.first.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add Expense',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            // Amount field
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
                hintText: '0.00',
                border: InputBorder.none,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            // Category selector
            SizedBox(
              height: 44,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    final isSelected = selectedCategory.value == category;

                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => selectedCategory.value = category,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: _getCategoryGradient(category),
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.shade100),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Note field
            TextField(
              controller: noteController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            GestureDetector(
              onTap: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) {
                  Get.snackbar(
                    'Error',
                    'Please enter a valid amount',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFF6B6B),
                    colorText: Colors.white,
                  );
                  return;
                }

                controller.createExpense(
                  amount: amount,
                  category: selectedCategory.value,
                  note: noteController.text.isEmpty
                      ? null
                      : noteController.text,
                  date: DateTime.now(),
                );
                Get.back();
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Add Expense',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

/// Period selector chip
class _PeriodChip extends GetView<ExpensesController> {
  final String label;
  final int index;
  final bool isDark;

  const _PeriodChip({
    required this.label,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedPeriod.value == index;

      return GestureDetector(
        onTap: () => controller.setSelectedPeriod(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFFF6B6B) : Colors.white,
            ),
          ),
        ),
      );
    });
  }
}
