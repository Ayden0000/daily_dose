import 'package:flutter/material.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/data/models/task_model.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isDark,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
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
        child: const Icon(AppIcons.delete, color: Colors.white, size: 28),
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
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _priorityColor,
                  ),
                ),
                const SizedBox(width: 14),
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
                        ? const Icon(
                            AppIcons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
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
