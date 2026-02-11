import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/routes/app_routes.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/modules/home/controllers/home_controller.dart';

/// Home Dashboard View - Premium Design
///
/// Features glassmorphism, gradients, and smooth animations.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0D0D1A),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF8FAFF),
                    const Color(0xFFEEF2FF),
                    const Color(0xFFE8EDFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshDashboard,
            color: AppColors.primaryLight,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(context, isDark),
                    const SizedBox(height: 32),
                    _buildProgressRing(context, isDark),
                    const SizedBox(height: 32),
                    _buildQuickStats(context, isDark),
                    const SizedBox(height: 24),
                    _buildModuleCards(context, isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.greeting,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.formattedDate,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Profile avatar with glow
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.tasksAccent, AppColors.meditationAccent],
            ),
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            ),
            child: Icon(
              AppIcons.user,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing(BuildContext context, bool isDark) {
    return Obx(() {
      final progress = controller.taskProgress;

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.04),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.6),
                  ],
          ),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.tasksAccent.withValues(
                alpha: isDark ? 0.2 : 0.1,
              ),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          children: [
            // Progress ring
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  // Background ring
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Progress ring
                  SizedBox.expand(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.tasksAccent,
                          ),
                        );
                      },
                    ),
                  ),
                  // Center text
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${controller.todaysCompletedCount.value} of ${controller.todaysTaskCount.value} tasks completed',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Streak badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B6B),
                          const Color(0xFFFF8E53),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.fire, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.taskStreak.value} day streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickStats(BuildContext context, bool isDark) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _GlassStatCard(
              icon: AppIcons.money,
              value: '\$${controller.todaysExpenses.value.toStringAsFixed(0)}',
              label: 'Spent Today',
              gradient: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _GlassStatCard(
              icon: AppIcons.lotus,
              value: '${controller.meditationStreak.value}',
              label: 'Zen Streak',
              gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCards(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        _PremiumModuleCard(
          title: 'Daily Tasks',
          subtitle: 'Stay organized and productive',
          icon: AppIcons.checkCircle,
          gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
          statsWidget: Obx(
            () => Text(
              '${controller.todaysCompletedCount.value}/${controller.todaysTaskCount.value} completed',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => Get.toNamed(AppRoutes.tasks),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _PremiumModuleCard(
          title: 'Expense Tracker',
          subtitle: 'Monitor your spending',
          icon: AppIcons.wallet,
          gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
          statsWidget: Obx(
            () => Text(
              '\$${controller.todaysExpenses.value.toStringAsFixed(2)} today',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => Get.toNamed(AppRoutes.expenses),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _PremiumModuleCard(
          title: 'Meditation',
          subtitle: 'Breathe and find calm',
          icon: AppIcons.spa,
          gradientColors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
          statsWidget: Obx(
            () => Text(
              '${controller.meditationStreak.value} day streak',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => Get.toNamed(AppRoutes.meditation),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _PremiumModuleCard(
          title: 'Habits',
          subtitle: 'Build lasting routines',
          icon: AppIcons.habit,
          gradientColors: [const Color(0xFF0D9488), const Color(0xFF2DD4BF)],
          statsWidget: Obx(
            () => Text(
              '${controller.todaysHabitCompleted.value}/${controller.todaysHabitCount.value} completed · ${controller.habitStreak.value} day streak',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => Get.toNamed(AppRoutes.habits),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _PremiumModuleCard(
          title: 'Journal',
          subtitle: 'Capture your thoughts & mood',
          icon: AppIcons.journal,
          gradientColors: [const Color(0xFFE11D48), const Color(0xFFFB7185)],
          statsWidget: Obx(
            () => Text(
              controller.todaysMoodEmoji.isNotEmpty
                  ? 'Today: ${controller.todaysMoodEmoji} · ${controller.totalJournalEntries.value} entries'
                  : '${controller.totalJournalEntries.value} entries total',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => Get.toNamed(AppRoutes.journal),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _PremiumModuleCard(
          title: 'Goals',
          subtitle: 'Set and achieve milestones',
          icon: AppIcons.goal,
          gradientColors: [const Color(0xFFD97706), const Color(0xFFFBBF24)],
          statsWidget: Obx(
            () => Text(
              '${controller.activeGoalCount.value} active · ${controller.completedGoalCount.value} achieved',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => Get.toNamed(AppRoutes.goals),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _PremiumModuleCard(
          title: 'Focus Timer',
          subtitle: 'Pomodoro for deep work',
          icon: AppIcons.focusTimer,
          gradientColors: [const Color(0xFFEA580C), const Color(0xFFFB923C)],
          statsWidget: Obx(
            () => Text(
              '${controller.todaysFocusTime.value} today · ${controller.todaysFocusSessions.value} sessions',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => Get.toNamed(AppRoutes.focus),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _PremiumModuleCard(
          title: 'Weekly Review',
          subtitle: 'See your progress over time',
          icon: AppIcons.chart,
          gradientColors: [const Color(0xFF0891B2), const Color(0xFF22D3EE)],
          statsWidget: const Text(
            'Charts & insights',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => Get.toNamed(AppRoutes.review),
          isDark: isDark,
        ),
      ],
    );
  }
}

/// Glass-style stat card with blur effect
class _GlassStatCard extends StatelessWidget {
  final dynamic icon;
  final String value;
  final String label;
  final List<Color> gradient;
  final bool isDark;

  const _GlassStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.6),
                ],
        ),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.white,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: gradient),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium module card with gradient and animations
class _PremiumModuleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final dynamic icon;
  final List<Color> gradientColors;
  final Widget statsWidget;
  final VoidCallback onTap;
  final bool isDark;

  const _PremiumModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.statsWidget,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_PremiumModuleCard> createState() => _PremiumModuleCardState();
}

class _PremiumModuleCardState extends State<_PremiumModuleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon with glass effect
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    widget.statsWidget,
                  ],
                ),
              ),
              // Arrow
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Icon(AppIcons.arrowRight, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
