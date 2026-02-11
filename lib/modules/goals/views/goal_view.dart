import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/data/models/goal_model.dart';
import 'package:daily_dose/modules/goals/controllers/goal_controller.dart';
import 'package:daily_dose/widgets/empty_state.dart';
import 'package:daily_dose/widgets/loading_state.dart';
import 'package:daily_dose/widgets/app_button.dart';
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
          ? const Color(0xFF0D0D1A)
          : const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
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
                    action: AppButton(
                      label: 'Add Goal',
                      icon: Icons.add,
                      onPressed: () => _showAddGoalSheet(context, isDark),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.goals.length,
                  itemBuilder: (context, index) {
                    final goal = controller.goals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _GoalCard(
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
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, isDark),
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
          Obx(
            () => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.activeGoalsCount} active goals',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goalsAccent.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(context, isDark),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(AppIcons.add, color: Colors.white, size: 28),
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
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                    if (titleCtrl.text.trim().isEmpty) return;
                    controller.createGoal(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim().isNotEmpty
                          ? descCtrl.text.trim()
                          : null,
                      targetDate: selectedDate.value,
                    );
                    Get.back();
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

// ============ GOAL CARD ============

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final bool isDark;
  final Function(String milestoneId) onToggleMilestone;
  final Function(String title) onAddMilestone;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.isDark,
    required this.onToggleMilestone,
    required this.onAddMilestone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        border: Border.all(
          color: goal.isOverdue
              ? const Color(0xFFFF6B6B).withValues(alpha: 0.3)
              : (isDark ? Colors.white12 : Colors.grey.shade100),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: goal.isCompleted
                            ? (isDark ? Colors.white38 : Colors.grey)
                            : (isDark ? Colors.white : Colors.black87),
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (goal.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Progress ring
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: goal.progress,
                      strokeWidth: 4,
                      backgroundColor: isDark
                          ? Colors.white12
                          : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        goal.isCompleted
                            ? AppColors.habitsAccent
                            : AppColors.goalsAccent,
                      ),
                    ),
                    Text(
                      '${(goal.progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Deadline badge
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: goal.isOverdue
                      ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                      : AppColors.goalsAccent.withValues(alpha: 0.12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.calendar,
                      size: 12,
                      color: goal.isOverdue
                          ? const Color(0xFFFF6B6B)
                          : AppColors.goalsAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      goal.isOverdue
                          ? '${-goal.daysRemaining}d overdue'
                          : '${goal.daysRemaining}d left',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: goal.isOverdue
                            ? const Color(0xFFFF6B6B)
                            : AppColors.goalsAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  AppIcons.delete,
                  size: 18,
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                ),
              ),
            ],
          ),

          // Milestones
          if (goal.milestones.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...goal.milestones.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onToggleMilestone(m.id),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: m.isCompleted
                              ? AppColors.goalsAccent
                              : Colors.transparent,
                          border: Border.all(
                            color: m.isCompleted
                                ? AppColors.goalsAccent
                                : (isDark
                                      ? Colors.white30
                                      : Colors.grey.shade300),
                            width: 2,
                          ),
                        ),
                        child: m.isCompleted
                            ? const Icon(
                                AppIcons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          m.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: m.isCompleted
                                ? (isDark ? Colors.white38 : Colors.grey)
                                : (isDark ? Colors.white70 : Colors.black87),
                            decoration: m.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Add milestone
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showMilestoneDialog(context),
            child: Row(
              children: [
                Icon(
                  AppIcons.add,
                  size: 18,
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  'Add milestone',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMilestoneDialog(BuildContext context) {
    final ctrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Milestone'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Milestone title'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onAddMilestone(ctrl.text.trim());
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
