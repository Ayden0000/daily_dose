import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/modules/review/controllers/review_controller.dart';
import 'package:daily_dose/widgets/loading_state.dart';

/// Weekly/Monthly Review View — Premium Design
///
/// Features bar chart visualizations for tasks, habits, mood, and focus.
/// Uses fl_chart-style manual bars for now (avoids adding another dep).
///
/// Why manual bars instead of fl_chart:
/// The bar chart requirements here are simple enough that CustomPaint or
/// basic Container-based bars suffice. Adding fl_chart would increase
/// bundle size for minimal gain. If richer charts are needed later,
/// we can swap in fl_chart without changing the controller layer.
class ReviewView extends GetView<ReviewController> {
  const ReviewView({super.key});

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

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodToggle(isDark),
                      const SizedBox(height: 24),
                      _buildOverviewCards(isDark),
                      const SizedBox(height: 24),
                      _buildTaskCompletionChart(isDark),
                      const SizedBox(height: 24),
                      _buildMoodChart(isDark),
                      const SizedBox(height: 24),
                      _buildFocusChart(isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ============ HEADER ============

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
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
              'Review',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ PERIOD TOGGLE ============

  Widget _buildPeriodToggle(bool isDark) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade100,
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _PeriodTab(
              label: 'Week',
              isSelected: controller.isWeekly.value,
              onTap: () => controller.isWeekly.value = true,
              isDark: isDark,
            ),
            _PeriodTab(
              label: 'Month',
              isSelected: !controller.isWeekly.value,
              onTap: () => controller.isWeekly.value = false,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  // ============ OVERVIEW CARDS ============

  Widget _buildOverviewCards(bool isDark) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _OverviewCard(
              title: 'Tasks Done',
              value: '${controller.tasksCompleted.value}',
              icon: AppIcons.checkCircle,
              color: AppColors.tasksAccent,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OverviewCard(
              title: 'Habits',
              value: '${controller.habitsCompletionRate.value}%',
              icon: AppIcons.habit,
              color: AppColors.habitsAccent,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OverviewCard(
              title: 'Focus',
              value: '${controller.focusMinutes.value}m',
              icon: AppIcons.timerFill,
              color: AppColors.focusAccent,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============ BAR CHARTS ============

  Widget _buildTaskCompletionChart(bool isDark) {
    return _ChartSection(
      title: 'Task Completion',
      isDark: isDark,
      child: Obx(
        () => _BarChart(
          values: controller.taskCompletionData,
          maxValue: controller.taskCompletionData.isEmpty
              ? 1
              : controller.taskCompletionData
                    .reduce((a, b) => a > b ? a : b)
                    .clamp(1, double.infinity),
          barColor: AppColors.tasksAccent,
          isDark: isDark,
          isWeekly: controller.isWeekly.value,
        ),
      ),
    );
  }

  Widget _buildMoodChart(bool isDark) {
    return _ChartSection(
      title: 'Mood Trend',
      isDark: isDark,
      child: Obx(
        () => _BarChart(
          values: controller.moodData,
          maxValue: 5,
          barColor: AppColors.journalAccent,
          isDark: isDark,
          isWeekly: controller.isWeekly.value,
        ),
      ),
    );
  }

  Widget _buildFocusChart(bool isDark) {
    return _ChartSection(
      title: 'Focus Minutes',
      isDark: isDark,
      child: Obx(
        () => _BarChart(
          values: controller.focusData,
          maxValue: controller.focusData.isEmpty
              ? 1
              : controller.focusData
                    .reduce((a, b) => a > b ? a : b)
                    .clamp(1, double.infinity),
          barColor: AppColors.focusAccent,
          isDark: isDark,
          isWeekly: controller.isWeekly.value,
        ),
      ),
    );
  }
}

// ============ REUSABLE COMPONENTS ============

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.reviewAccent : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _ChartSection({
    required this.title,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade100,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;
  final double maxValue;
  final Color barColor;
  final bool isDark;
  final bool isWeekly;

  const _BarChart({
    required this.values,
    required this.maxValue,
    required this.barColor,
    required this.isDark,
    required this.isWeekly,
  });

  @override
  Widget build(BuildContext context) {
    final labels = isWeekly
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : ['W1', 'W2', 'W3', 'W4'];

    final displayValues = isWeekly
        ? List.generate(7, (i) => i < values.length ? values[i] : 0.0)
        : List.generate(4, (i) => i < values.length ? values[i] : 0.0);

    if (displayValues.every((v) => v == 0)) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No data yet',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(displayValues.length, (i) {
          final height = maxValue > 0
              ? (displayValues[i] / maxValue * 80).clamp(0.0, 80.0)
              : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Value label
              if (displayValues[i] > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    displayValues[i] % 1 == 0
                        ? '${displayValues[i].toInt()}'
                        : displayValues[i].toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),

              // Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: isWeekly ? 28 : 44,
                height: height > 0 ? height : 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: height > 0
                      ? barColor.withValues(alpha: 0.8)
                      : (isDark ? Colors.white12 : Colors.grey.shade200),
                  gradient: height > 0
                      ? LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [barColor, barColor.withValues(alpha: 0.6)],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),

              // Day label
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
