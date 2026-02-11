import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/routes/app_routes.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/data/models/task_model.dart';
import 'package:daily_dose/modules/tasks/controllers/tasks_controller.dart';
import 'package:daily_dose/widgets/empty_state.dart';
import 'package:daily_dose/widgets/loading_state.dart';
import 'package:daily_dose/widgets/app_button.dart';

/// Tasks List View - Premium Design
class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0D1A)
          : const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
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
                    action: AppButton(
                      label: 'Add Task',
                      icon: Icons.add,
                      onPressed: () => _showTaskForm(context),
                    ),
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
      floatingActionButton: _buildFAB(isDark),
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
                gradient: LinearGradient(
                  colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
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
            child: _TaskCard(
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

  Widget _buildFAB(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showTaskForm(Get.context!),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(AppIcons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showTaskForm(BuildContext context, {TaskModel? task}) {
    Get.toNamed(AppRoutes.taskForm, arguments: task);
  }
}

/// Premium task card with animations
class _TaskCard extends StatefulWidget {
  final TaskModel task;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.isDark,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Color get _priorityColor {
    switch (widget.task.priority) {
      case 3:
        return const Color(0xFFFF6B6B);
      case 2:
        return const Color(0xFFFFAA5C);
      default:
        return const Color(0xFF38EF7D);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
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
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              border: Border.all(
                color: widget.isDark ? Colors.white12 : Colors.grey.shade100,
              ),
              boxShadow: widget.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Priority indicator
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _priorityColor,
                  ),
                ),
                const SizedBox(width: 14),
                // Checkbox
                GestureDetector(
                  onTap: widget.onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: widget.task.isCompleted
                          ? AppColors.tasksAccent
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.task.isCompleted
                            ? AppColors.tasksAccent
                            : (widget.isDark
                                  ? Colors.white30
                                  : Colors.grey.shade300),
                        width: 2,
                      ),
                    ),
                    child: widget.task.isCompleted
                        ? Icon(AppIcons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.task.isCompleted
                              ? (widget.isDark ? Colors.white38 : Colors.grey)
                              : (widget.isDark ? Colors.white : Colors.black87),
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (widget.task.description != null &&
                          widget.task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.task.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.isDark ? Colors.white38 : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Due badge
                if (widget.task.isDueToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: widget.task.isOverdue
                          ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                          : AppColors.tasksAccent.withValues(alpha: 0.15),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.task.isOverdue
                            ? const Color(0xFFFF6B6B)
                            : AppColors.tasksAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
