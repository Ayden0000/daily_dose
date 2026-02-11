import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/modules/meditation/controllers/meditation_controller.dart';

/// Animated breathing circle for meditation
///
/// Visual representation of the breathing cycle.
/// Expands during inhale, contracts during exhale.
class BreathingCircle extends StatelessWidget {
  final BreathingPhase phase;
  final double progress;
  final double size;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.progress,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate scale based on phase and progress
    double scale;
    switch (phase) {
      case BreathingPhase.inhale:
        // Expand from 0.6 to 1.0
        scale = 0.6 + (0.4 * progress);
        break;
      case BreathingPhase.hold1:
        // Stay at maximum
        scale = 1.0;
        break;
      case BreathingPhase.exhale:
        // Contract from 1.0 to 0.6
        scale = 1.0 - (0.4 * progress);
        break;
      case BreathingPhase.hold2:
        // Stay at minimum
        scale = 0.6;
        break;
      case BreathingPhase.idle:
        scale = 0.6;
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: CustomPaint(
          size: Size(size, size),
          painter: _BreathingCirclePainter(
            phase: phase,
            progress: progress,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class _BreathingCirclePainter extends CustomPainter {
  final BreathingPhase phase;
  final double progress;
  final bool isDark;

  _BreathingCirclePainter({
    required this.phase,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow
    final glowColor = isDark
        ? AppColors.meditationAccent.withValues(alpha: 0.2)
        : AppColors.meditationAccent.withValues(alpha: 0.15);

    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(center, radius * 0.95, glowPaint);

    // Main gradient circle
    final gradient = RadialGradient(
      colors: isDark
          ? [AppColors.meditationAccent, AppColors.meditationAccentDark]
          : [
              AppColors.meditationAccent.withValues(alpha: 0.9),
              AppColors.meditationAccent,
            ],
    );

    final mainPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.9),
      );

    canvas.drawCircle(center, radius * 0.9, mainPaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 0.85, highlightPaint);

    // Progress arc (only during active phases)
    if (phase != BreathingPhase.idle) {
      final arcPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final arcRect = Rect.fromCircle(center: center, radius: radius * 0.75);
      canvas.drawArc(
        arcRect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BreathingCirclePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark;
  }
}

/// Phase indicator text with animation
class PhaseLabel extends StatelessWidget {
  final String label;
  final int secondsRemaining;

  const PhaseLabel({
    super.key,
    required this.label,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            label,
            key: ValueKey(label),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.meditationAccent,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$secondsRemaining',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w200,
          ),
        ),
      ],
    );
  }
}
