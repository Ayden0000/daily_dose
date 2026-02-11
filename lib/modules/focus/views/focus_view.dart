import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/app/config/constants.dart';
import 'package:daily_dose/modules/focus/controllers/focus_timer_controller.dart';

/// Focus Timer / Pomodoro — Cozy Lofi Aesthetic
///
/// Design philosophy: Warm tones, soft gradients, ambient feel.
/// The timer dominates the screen with a large circular progress ring.
/// Controls are minimal — just play/reset. Session stats at the bottom.
///
/// Why this approach over a complex UI:
/// Focus timers should have zero cognitive overhead. The user glances at it,
/// sees the time, and returns to their work. Dense UI defeats the purpose.
class FocusView extends GetView<FocusTimerController> {
  const FocusView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A0E2E),
                    const Color(0xFF0D0D1A),
                    const Color(0xFF15101E),
                  ]
                : [
                    const Color(0xFFFFF7ED),
                    const Color(0xFFFEF3C7),
                    const Color(0xFFFFF1F2),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              const Spacer(flex: 1),
              _buildTimerRing(isDark),
              const SizedBox(height: 32),
              _buildPhaseLabel(isDark),
              const SizedBox(height: 40),
              _buildControls(isDark),
              const Spacer(flex: 1),
              _buildSessionStats(isDark),
              const SizedBox(height: 24),
            ],
          ),
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
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.7),
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
              'Focus',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF78350F),
              ),
            ),
          ),
          // Session counter
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.7),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.timerFill,
                    size: 14,
                    color: isDark
                        ? AppColors.focusAccent
                        : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${controller.completedSessions.value}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF78350F),
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

  // ============ TIMER RING ============

  Widget _buildTimerRing(bool isDark) {
    return Obx(() {
      final progress = controller.progress;
      final isWork =
          controller.currentPhase.value == AppConstants.sessionTypeFocus;
      final accentColor = isWork
          ? (isDark ? AppColors.focusAccent : const Color(0xFFD97706))
          : (isDark ? const Color(0xFF22D3EE) : const Color(0xFF0EA5E9));

      return SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),

            // Outer ring (background)
            CustomPaint(
              size: const Size(260, 260),
              painter: _TimerRingPainter(
                progress: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                strokeWidth: 8,
              ),
            ),

            // Progress ring
            CustomPaint(
              size: const Size(260, 260),
              painter: _TimerRingPainter(
                progress: progress,
                color: accentColor,
                strokeWidth: 8,
              ),
            ),

            // Inner content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.formattedTime,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                    color: isDark ? Colors.white : const Color(0xFF78350F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWork ? 'Focus' : 'Rest',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: accentColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ============ PHASE LABEL ============

  Widget _buildPhaseLabel(bool isDark) {
    return Obx(() {
      final phase = controller.currentPhase.value;
      String label;

      if (phase == AppConstants.sessionTypeFocus) {
        label = 'Time to focus — you got this';
      } else if (phase == AppConstants.sessionTypeShortBreak) {
        label = 'Take a short break';
      } else {
        label = 'You earned a long break!';
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          label,
          key: ValueKey(phase),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white38 : const Color(0xFFA8A29E),
          ),
        ),
      );
    });
  }

  // ============ CONTROLS ============

  Widget _buildControls(bool isDark) {
    final accentColor = isDark
        ? AppColors.focusAccent
        : const Color(0xFFD97706);

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reset button
          if (controller.isRunning.value || controller.isPaused.value)
            GestureDetector(
              onTap: controller.resetTimer,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.7),
                  border: Border.all(
                    color: isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Icon(
                  AppIcons.stop,
                  size: 22,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
            ),

          if (controller.isRunning.value || controller.isPaused.value)
            const SizedBox(width: 24),

          // Play / Pause button
          GestureDetector(
            onTap: () {
              if (controller.isRunning.value) {
                controller.pauseTimer();
              } else {
                controller.startTimer();
              }
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.focusAccent, const Color(0xFFFF8A3D)]
                      : [const Color(0xFFD97706), const Color(0xFFF59E0B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                controller.isRunning.value ? AppIcons.pause : AppIcons.play,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),

          if (controller.isRunning.value || controller.isPaused.value)
            const SizedBox(width: 24),

          // Skip button
          if (controller.isRunning.value || controller.isPaused.value)
            GestureDetector(
              onTap: controller.skipToNext,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.7),
                  border: Border.all(
                    color: isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Icon(
                  AppIcons.forward,
                  size: 22,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============ SESSION STATS ============

  Widget _buildSessionStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.6),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.03),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Sessions',
                value: '${controller.completedSessions.value}',
                icon: AppIcons.timerFill,
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 36,
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.06),
              ),
              _StatItem(
                label: 'Focus Time',
                value: '${controller.todaysSessionCount}m',
                icon: AppIcons.clock,
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 36,
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.06),
              ),
              _StatItem(
                label: 'Round',
                value:
                    '${controller.completedSessions.value}/${AppConstants.sessionsBeforeLongBreak}',
                icon: AppIcons.streak,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ STAT ITEM ============

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? AppColors.focusAccent.withValues(alpha: 0.7)
              : const Color(0xFFD97706),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF78350F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : const Color(0xFFA8A29E),
          ),
        ),
      ],
    );
  }
}

// ============ TIMER RING PAINTER ============

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
