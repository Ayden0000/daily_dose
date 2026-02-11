import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    final bgColor = isDark ? const Color(0xFF101017) : const Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
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
                  const SizedBox(height: 12),
                  _buildAdviceQuote(context, isDark),
                  const SizedBox(height: 32),
                  _buildProgressRing(context, isDark),
                  const SizedBox(height: 32),
                  _buildModuleCards(context, isDark),
                  const SizedBox(height: 40),
                ],
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
        // Profile avatar
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.focusAccent.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.focusAccent.withValues(alpha: 0.12)
                  : AppColors.focusAccent.withValues(alpha: 0.08),
            ),
            child: Icon(
              AppIcons.user,
              color: isDark ? Colors.white70 : AppColors.focusAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceQuote(BuildContext context, bool isDark) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.focusAccent.withValues(alpha: 0.12),
                    AppColors.meditationAccent.withValues(alpha: 0.08),
                  ]
                : [
                    AppColors.focusAccent.withValues(alpha: 0.08),
                    AppColors.meditationAccent.withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.focusAccent.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Advice',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark
                          ? AppColors.focusAccent.withValues(alpha: 0.7)
                          : AppColors.focusAccent.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (controller.isAdviceLoading.value)
                    _buildAdviceShimmer(isDark)
                  else
                    Text(
                      '"${controller.motivationalTagline}"',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceShimmer(bool isDark) {
    final barColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          width: 140,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing(BuildContext context, bool isDark) {
    return Obx(() {
      final progress = controller.taskProgress;
      // Glow intensifies with progress — feels rewarding
      final glowAlpha = (0.08 + progress * 0.25).clamp(0.0, 0.35);

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E32), Color(0xFF111120)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.tasksAccent.withValues(alpha: glowAlpha),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                        Colors.white.withValues(alpha: 0.1),
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${controller.todaysCompletedCount.value} of ${controller.todaysTaskCount.value} tasks completed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
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
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.focusAccent,
                          AppColors.focusGradientEnd,
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

  Widget _buildModuleCards(BuildContext context, bool isDark) {
    const muted = TextStyle(
      fontSize: 13,
      color: Colors.white70,
      fontWeight: FontWeight.w500,
    );
    const heading = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Your Day ──────────────────────────────────────────────
        _SectionLabel(text: 'Your Day', isDark: isDark),
        const SizedBox(height: 14),

        // Tasks — full-width hero with segmented capsule bar
        _DashCard(
          accent: AppColors.tasksAccent,
          onTap: () => Get.toNamed(AppRoutes.tasks),
          isDark: isDark,
          child: Obx(() {
            final done = controller.todaysCompletedCount.value;
            final total = controller.todaysTaskCount.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _AccentDot(
                      color: AppColors.tasksAccent,
                      isDark: isDark,
                      icon: AppIcons.checkCircle,
                    ),
                    const SizedBox(width: 12),
                    Text('Daily Tasks', style: heading),
                    const Spacer(),
                    Text(
                      '$done / $total',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SegmentedBar(
                  done: done,
                  total: total,
                  color: AppColors.tasksAccent,
                  isDark: isDark,
                ),
                if (controller.taskStreak.value > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(AppIcons.fire, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.taskStreak.value} day streak',
                        style: muted,
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),
        ),
        const SizedBox(height: 12),

        // Expenses + Meditation pair
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _DashCard(
                  accent: AppColors.expensesAccent,
                  onTap: () => Get.toNamed(AppRoutes.expenses),
                  isDark: isDark,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AccentDot(
                          color: AppColors.expensesAccent,
                          isDark: isDark,
                          icon: AppIcons.wallet,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '\$${controller.todaysExpenses.value.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('spent today', style: muted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DashCard(
                  accent: AppColors.meditationAccent,
                  onTap: () => Get.toNamed(AppRoutes.meditation),
                  isDark: isDark,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AccentDot(
                          color: AppColors.meditationAccent,
                          isDark: isDark,
                          icon: AppIcons.spa,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${controller.meditationStreak.value}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text('days', style: muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('zen streak', style: muted),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Build & Reflect ───────────────────────────────────────
        _SectionLabel(text: 'Build & Reflect', isDark: isDark),
        const SizedBox(height: 14),

        // Habits — full-width with bubble dots
        _DashCard(
          accent: AppColors.habitsAccent,
          onTap: () => Get.toNamed(AppRoutes.habits),
          isDark: isDark,
          child: Obx(() {
            final done = controller.todaysHabitCompleted.value;
            final total = controller.todaysHabitCount.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _AccentDot(
                      color: AppColors.habitsAccent,
                      isDark: isDark,
                      icon: AppIcons.habit,
                    ),
                    const SizedBox(width: 12),
                    Text('Habits', style: heading),
                    const Spacer(),
                    if (controller.habitStreak.value > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(AppIcons.fire, size: 13, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '${controller.habitStreak.value}d',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _HabitBubbles(
                  done: done,
                  total: total,
                  color: AppColors.habitsAccent,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                Text(
                  total > 0
                      ? '$done of $total completed today'
                      : 'No habits tracked yet',
                  style: muted,
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 12),

        // Journal + Goals pair
        IntrinsicHeight(
          child: Row(
            children: [
              // Journal — mood meter card
              Expanded(
                child: _DashCard(
                  accent: AppColors.journalAccent,
                  onTap: () => Get.toNamed(AppRoutes.journal),
                  isDark: isDark,
                  child: Obx(() {
                    final mood = controller.todaysMood.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AccentDot(
                          color: AppColors.journalAccent,
                          isDark: isDark,
                          icon: AppIcons.journal,
                        ),
                        const SizedBox(height: 16),
                        _MoodMeter(activeMood: mood, isDark: isDark),
                        const SizedBox(height: 16),
                        Text('Journal', style: muted),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              // Goals
              Expanded(
                child: _DashCard(
                  accent: AppColors.goalsAccent,
                  onTap: () => Get.toNamed(AppRoutes.goals),
                  isDark: isDark,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AccentDot(
                          color: AppColors.goalsAccent,
                          isDark: isDark,
                          icon: AppIcons.goal,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${controller.activeGoalCount.value}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text('active', style: muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Goals', style: muted),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Focus & Grow ──────────────────────────────────────────
        _SectionLabel(text: 'Focus & Grow', isDark: isDark),
        const SizedBox(height: 14),

        // Focus + Review pair
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _DashCard(
                  accent: AppColors.focusAccent,
                  onTap: () => Get.toNamed(AppRoutes.focus),
                  isDark: isDark,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AccentDot(
                          color: AppColors.focusAccent,
                          isDark: isDark,
                          icon: AppIcons.focusTimer,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          controller.todaysFocusTime.value,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('focused today', style: muted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DashCard(
                  accent: AppColors.reviewAccent,
                  onTap: () => Get.toNamed(AppRoutes.review),
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AccentDot(
                        color: AppColors.reviewAccent,
                        isDark: isDark,
                        icon: AppIcons.chart,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Weekly\nInsights',
                        style: heading.copyWith(height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'View',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            AppIcons.arrowRight,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SECTION LABEL — thin gradient bar + heading
// ══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white38 : Colors.black38,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DASH CARD — glass container with accent glow + press anim
// ══════════════════════════════════════════════════════════════

class _DashCard extends StatefulWidget {
  final Color accent;
  final VoidCallback onTap;
  final bool isDark;
  final Widget child;

  const _DashCard({
    required this.accent,
    required this.onTap,
    required this.isDark,
    required this.child,
  });

  @override
  State<_DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<_DashCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkEnd = Color.lerp(
      widget.accent,
      const Color(0xFF151520),
      widget.isDark ? 0.55 : 0.45,
    )!;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: _ctrl.reverse,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.accent, darkEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ACCENT ICON DOT — icon inside a tinted rounded square
// ══════════════════════════════════════════════════════════════

class _AccentDot extends StatelessWidget {
  final Color color;
  final bool isDark;
  final IconData icon;

  const _AccentDot({
    required this.color,
    required this.isDark,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Colors.white.withValues(alpha: 0.2),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SEGMENTED BAR — each task = one capsule, filled = completed
// ══════════════════════════════════════════════════════════════

class _SegmentedBar extends StatelessWidget {
  final int done;
  final int total;
  final Color color;
  final bool isDark;

  const _SegmentedBar({
    required this.done,
    required this.total,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white.withValues(alpha: 0.15),
        ),
      );
    }

    // Continuous bar for many items
    if (total > 12) {
      final pct = (done / total).clamp(0.0, 1.0);
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: LinearProgressIndicator(
          value: pct,
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          valueColor: const AlwaysStoppedAnimation(Colors.white),
          minHeight: 8,
        ),
      );
    }

    // Segmented capsules
    return Row(
      children: List.generate(total, (i) {
        final filled = i < done;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: i < total - 1 ? 3 : 0),
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: filled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  HABIT BUBBLES — glowing dots per habit
// ══════════════════════════════════════════════════════════════

class _HabitBubbles extends StatelessWidget {
  final int done;
  final int total;
  final Color color;
  final bool isDark;

  const _HabitBubbles({
    required this.done,
    required this.total,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return Row(
        children: List.generate(
          5,
          (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      );
    }

    final count = total.clamp(0, 15);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(count, (i) {
        final filled = i < done;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Colors.white : Colors.white.withValues(alpha: 0.2),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  MOOD METER — 5 emoji faces, active one glows & scales up
// ══════════════════════════════════════════════════════════════

class _MoodMeter extends StatelessWidget {
  final int activeMood; // 0 = none, 1–5
  final bool isDark;

  const _MoodMeter({required this.activeMood, required this.isDark});

  static const _emojis = ['😞', '😔', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final isActive = (i + 1) == activeMood;
        return AnimatedScale(
          scale: isActive ? 1.2 : (activeMood == 0 ? 0.85 : 0.7),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : (activeMood == 0 ? 0.4 : 0.25),
            duration: const Duration(milliseconds: 250),
            child: Text(
              _emojis[i],
              style: TextStyle(fontSize: isActive ? 28 : 20),
            ),
          ),
        );
      }),
    );
  }
}
