import 'package:flutter/material.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/routes/app_routes.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/data/models/task_model.dart';
import 'package:daily_dose/modules/tasks/controllers/tasks_controller.dart';
import 'package:daily_dose/modules/tasks/widgets/task_card.dart';
import 'package:daily_dose/widgets/empty_state.dart';
import 'package:daily_dose/widgets/loading_state.dart';

import 'package:daily_dose/widgets/primary_action_button.dart';
import 'package:daily_dose/widgets/error_banner.dart';

/// Tasks List View - Premium Design
class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
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

                if (controller.filteredTasks.isEmpty) {
                  return EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'All caught up!',
                    subtitle: 'Add a task to get started',
                    iconColor: AppColors.tasksAccent,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshTasks,
                  child: _buildTaskList(context, isDark),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PrimaryActionButton(
        label: 'Add Task',
        icon: Icons.add,
        gradient: const [AppColors.tasksAccent, AppColors.tasksGradientEnd],
        onPressed: () => _showTaskForm(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
                  'Daily Tasks',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
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
                          ? AppColors.tasksAccent.withValues(alpha: 0.2)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          controller.showCompleted.value
                              ? AppIcons.visible
                              : AppIcons.hidden,
                          size: 16,
                          color: controller.showCompleted.value
                              ? AppColors.tasksAccent
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.showCompleted.value ? 'Hide' : 'Show',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: controller.showCompleted.value
                                ? AppColors.tasksAccent
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Obx(
            () => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppColors.tasksAccent, AppColors.tasksGradientEnd],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.todaysCompletedCount} of ${controller.todaysTasks.length} completed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: controller.todaysTasks.isEmpty
                                ? 0
                                : controller.todaysCompletedCount /
                                      controller.todaysTasks.length,
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
                    child: Row(
                      children: [
                        Icon(AppIcons.fire, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.currentStreak.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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

  Widget _buildTaskList(BuildContext context, bool isDark) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.filteredTasks.length,
        itemBuilder: (context, index) {
          final task = controller.filteredTasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(
              task: task,
              isDark: isDark,
              onToggle: () => controller.toggleTaskCompletion(task.id),
              onTap: () => _showTaskForm(context, task: task),
              onDelete: () => controller.deleteTask(task.id),
            ),
          );
        },
      ),
    );
  }

  void _showTaskForm(BuildContext context, {TaskModel? task}) {
    Get.toNamed(AppRoutes.taskForm, arguments: task);
  }
}
