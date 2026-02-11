import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/app/config/constants.dart';
import 'package:daily_dose/modules/habits/controllers/habit_controller.dart';
import 'package:daily_dose/widgets/empty_state.dart';
import 'package:daily_dose/widgets/loading_state.dart';

import 'package:daily_dose/widgets/primary_action_button.dart';
import 'package:daily_dose/widgets/error_banner.dart';
import 'package:daily_dose/widgets/app_toast.dart';
import 'package:daily_dose/modules/habits/widgets/frequency_chip.dart';
import 'package:daily_dose/modules/habits/widgets/habit_card.dart';

/// Habit Tracker View — Premium Design
///
/// Features a progress banner, habit list with completion toggles,
/// streak counters, and a floating add button.
class HabitView extends GetView<HabitController> {
  const HabitView({super.key});

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

                if (controller.habits.isEmpty) {
                  return EmptyState(
                    icon: AppIcons.habit,
                    title: 'No habits yet',
                    subtitle: 'Start building better routines',
                    iconColor: AppColors.habitsAccent,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.habits.length,
                  itemBuilder: (context, index) {
                    final habit = controller.habits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HabitCard(
                        habit: habit,
                        isDark: isDark,
                        isCompleted: controller.isHabitCompleted(habit.id),
                        onToggle: () => controller.toggleCompletion(habit.id),
                        onDelete: () => controller.deleteHabit(habit.id),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PrimaryActionButton(
        label: 'Add Habit',
        icon: Icons.add,
        gradient: const [AppColors.habitsAccent, AppColors.habitsGradientEnd],
        onPressed: () => _showAddHabitSheet(context, isDark),
      ),
    );
  }

  // ============ HEADER WITH PROGRESS ============

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top row: back button + title
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
                  'Habits',
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

          // Progress banner
          Obx(
            () => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppColors.habitsAccent, AppColors.habitsGradientEnd],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.completedCount} of ${controller.totalScheduled} today',
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
                            value: controller.todaysProgress,
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
                        const Icon(
                          AppIcons.streak,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(controller.todaysProgress * 100).toInt()}%',
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

  // ============ ADD HABIT BOTTOM SHEET ============

  void _showAddHabitSheet(BuildContext context, bool isDark) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final selectedFrequency = AppConstants.frequencyDaily.obs;
    final selectedCategory = 'Health'.obs;

    final categories = [
      'Health',
      'Fitness',
      'Mindfulness',
      'Learning',
      'Productivity',
      'Social',
      'Finance',
      'Wellness',
    ];

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
                'New Habit',
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
                  hintText: 'Habit title',
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

              // Description field
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
              const SizedBox(height: 20),

              // Category chips
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = selectedCategory.value == cat;
                    return GestureDetector(
                      onTap: () => selectedCategory.value = cat,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isSelected
                              ? AppColors.habitsAccent
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey.shade100),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white54 : Colors.black54),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Frequency selector
              Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: [
                    FrequencyChip(
                      label: 'Daily',
                      isSelected:
                          selectedFrequency.value ==
                          AppConstants.frequencyDaily,
                      onTap: () =>
                          selectedFrequency.value = AppConstants.frequencyDaily,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    FrequencyChip(
                      label: 'Weekdays',
                      isSelected:
                          selectedFrequency.value ==
                          AppConstants.frequencyWeekdays,
                      onTap: () => selectedFrequency.value =
                          AppConstants.frequencyWeekdays,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) {
                      AppToast.error(context, 'Please enter a habit name');
                      return;
                    }
                    controller.createHabit(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim().isNotEmpty
                          ? descCtrl.text.trim()
                          : null,
                      category: selectedCategory.value,
                      frequency: selectedFrequency.value,
                    );
                    Get.back();
                    AppToast.success(
                      context,
                      'Habit created — "${titleCtrl.text.trim()}"',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.habitsAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Habit',
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
