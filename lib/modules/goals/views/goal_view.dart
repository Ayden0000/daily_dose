import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/modules/goals/controllers/goal_controller.dart';
import 'package:daily_dose/modules/goals/widgets/goal_card.dart';
import 'package:daily_dose/widgets/empty_state.dart';
import 'package:daily_dose/widgets/loading_state.dart';

import 'package:daily_dose/widgets/primary_action_button.dart';
import 'package:daily_dose/widgets/error_banner.dart';
import 'package:daily_dose/widgets/app_toast.dart';
import 'package:intl/intl.dart';

/// Goal Setting View — Premium Design
///
/// Displays active goals with progress rings, milestones,
/// deadline badges, and add goal flow.
class GoalView extends GetView<GoalController> {
  const GoalView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Obx(
              () => controller.errorMessage.isNotEmpty
                  ? ErrorBanner(
                      message: controller.errorMessage.value,
                      onClose: () => controller.errorMessage.value = '',
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingState();
                }

                if (controller.goals.isEmpty) {
                  return EmptyState(
                    icon: AppIcons.goal,
                    title: 'No goals yet',
                    subtitle:
                        'Set your first goal and break it into milestones',
                    iconColor: AppColors.goalsAccent,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadGoals,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.goals.length,
                    itemBuilder: (context, index) {
                      final goal = controller.goals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GoalCard(
                          goal: goal,
                          isDark: isDark,
                          onToggleMilestone: (milestoneId) =>
                              controller.toggleMilestone(goal.id, milestoneId),
                          onAddMilestone: (title) =>
                              controller.addMilestone(goal.id, title),
                          onDelete: () => controller.deleteGoal(goal.id),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      bottomNavigationBar: PrimaryActionButton(
        label: 'Add Goal',
        icon: Icons.add,
        gradient: const [AppColors.goalsAccent, AppColors.goalsGradientEnd],
        onPressed: () => _showAddGoalSheet(context, isDark),
      ),
    );
  }
  // ============ HEADER ============

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
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
                  'Goals',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              // Toggle completed filter
              Obx(
                () => GestureDetector(
                  onTap: controller.toggleShowCompleted,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: controller.showCompleted.value
                          ? AppColors.goalsAccent.withValues(alpha: 0.2)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white),
                    ),
                    child: Text(
                      controller.showCompleted.value ? 'All' : 'Active',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: controller.showCompleted.value
                            ? AppColors.goalsAccent
                            : (isDark ? Colors.white54 : Colors.black45),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overall progress banner
          Obx(() {
            // Reference reactive list to satisfy Obx
            final goalCount = controller.goals.length;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppColors.goalsAccent, AppColors.goalsGradientEnd],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$goalCount active goals',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: controller.overallProgress,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
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
                      '${(controller.overallProgress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============ ADD GOAL BOTTOM SHEET ============

  void _showAddGoalSheet(BuildContext context, bool isDark) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final selectedDate = DateTime.now().add(const Duration(days: 30)).obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceElevatedDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                'New Goal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Goal title',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Target date picker
              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) selectedDate.value = picked;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade100,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.calendar,
                          size: 20,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Target: ${DateFormat('MMM d, yyyy').format(selectedDate.value)}',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) {
                      AppToast.error(context, 'Please enter a goal name');
                      return;
                    }
                    controller.createGoal(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim().isNotEmpty
                          ? descCtrl.text.trim()
                          : null,
                      targetDate: selectedDate.value,
                    );
                    Get.back();
                    AppToast.success(
                      context,
                      'Goal created — "${titleCtrl.text.trim()}"',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goalsAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Goal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
