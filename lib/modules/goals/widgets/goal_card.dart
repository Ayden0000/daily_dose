import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/data/models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final bool isDark;
  final Function(String milestoneId) onToggleMilestone;
  final Function(String title) onAddMilestone;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
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
