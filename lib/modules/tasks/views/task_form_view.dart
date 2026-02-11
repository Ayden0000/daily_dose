import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/app/theme/app_spacing.dart';
import 'package:daily_dose/data/models/task_model.dart';
import 'package:daily_dose/modules/tasks/controllers/tasks_controller.dart';
import 'package:daily_dose/modules/tasks/widgets/priority_option.dart';
import 'package:daily_dose/widgets/app_button.dart';
import 'package:daily_dose/widgets/app_toast.dart';
import 'package:daily_dose/widgets/app_input.dart';

/// Task form for create/edit
class TaskFormView extends GetView<TasksController> {
  const TaskFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskModel? existingTask = Get.arguments;
    final isEditing = existingTask != null;

    final titleController = TextEditingController(text: existingTask?.title);
    final descController = TextEditingController(
      text: existingTask?.description,
    );
    final priority = (existingTask?.priority ?? 2).obs;
    final dueDate = Rx<DateTime?>(existingTask?.dueDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                AppIcons.delete,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                controller.deleteTask(existingTask.id);
                Get.back();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInput(
              controller: titleController,
              label: 'Title',
              hint: 'What needs to be done?',
              autofocus: !isEditing,
            ),
            AppSpacing.vGapLg,
            AppInput(
              controller: descController,
              label: 'Description (optional)',
              hint: 'Add more details...',
              maxLines: 3,
            ),
            AppSpacing.vGapLg,
            _buildPrioritySelector(context, priority),
            AppSpacing.vGapLg,
            _buildDueDatePicker(context, dueDate),
            AppSpacing.vGapXxl,
            AppButton(
              label: isEditing ? 'Save Changes' : 'Create Task',
              isFullWidth: true,
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  AppToast.error(context, 'Please enter a task title');
                  return;
                }

                if (isEditing) {
                  existingTask.title = titleController.text.trim();
                  existingTask.description = descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim();
                  existingTask.priority = priority.value;
                  existingTask.dueDate = dueDate.value;
                  controller.updateTask(existingTask);
                } else {
                  controller.createTask(
                    title: titleController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                    priority: priority.value,
                    dueDate: dueDate.value,
                  );
                }
                Get.back();
                AppToast.success(
                  context,
                  isEditing ? 'Task updated' : 'Task created',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(BuildContext context, RxInt priority) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: theme.textTheme.labelLarge),
        AppSpacing.vGapSm,
        Obx(
          () => Row(
            children: [
              Expanded(
                child: PriorityOption(
                  label: 'Low',
                  color: AppColors.priorityLow,
                  isSelected: priority.value == 1,
                  onTap: () => priority.value = 1,
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: PriorityOption(
                  label: 'Medium',
                  color: AppColors.priorityMedium,
                  isSelected: priority.value == 2,
                  onTap: () => priority.value = 2,
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: PriorityOption(
                  label: 'High',
                  color: AppColors.priorityHigh,
                  isSelected: priority.value == 3,
                  onTap: () => priority.value = 3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDueDatePicker(BuildContext context, Rx<DateTime?> dueDate) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Due Date (optional)', style: theme.textTheme.labelLarge),
        AppSpacing.vGapSm,
        Obx(
          () => InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dueDate.value ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                dueDate.value = picked;
              }
            },
            borderRadius: AppSpacing.borderRadiusMd,
            child: Container(
              padding: AppSpacing.inputPadding,
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppSpacing.iconSm,
                    color: theme.iconTheme.color,
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Text(
                      dueDate.value != null
                          ? DateFormat.yMMMd().format(dueDate.value!)
                          : 'Select a date',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: dueDate.value != null ? null : theme.hintColor,
                      ),
                    ),
                  ),
                  if (dueDate.value != null)
                    IconButton(
                      icon: Icon(
                        AppIcons.close,
                        color: theme.iconTheme.color,
                        size: 18,
                      ),
                      onPressed: () => dueDate.value = null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
