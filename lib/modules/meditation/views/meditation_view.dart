import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:daily_dose/app/constants/app_icons.dart';
import 'package:daily_dose/app/theme/app_colors.dart';
import 'package:daily_dose/modules/meditation/controllers/meditation_controller.dart';

/// Meditation Timer View - Premium Design
class MeditationView extends GetView<MeditationController> {
  const MeditationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0D0D1A),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF0D0D1A),
                  ]
                : [
                    const Color(0xFFE8F5E9),
                    const Color(0xFFE0F2F1),
                    const Color(0xFFE8F5E9),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(child: _buildBreathingSection(context, isDark)),
              _buildControlsSection(context, isDark),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
              ),
              child: Icon(
                AppIcons.arrowLeft,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const Spacer(),
          // Audio toggle
          Obx(
            () => _ToggleButton(
              icon: controller.audioEnabled.value
                  ? AppIcons.volumeOn
                  : AppIcons.volumeOff,
              isActive: controller.audioEnabled.value,
              onTap: controller.toggleAudio,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          // Vibration toggle
          Obx(
            () => _ToggleButton(
              icon: controller.vibrationEnabled.value
                  ? AppIcons.vibration
                  : AppIcons.phone,
              isActive: controller.vibrationEnabled.value,
              onTap: controller.toggleVibration,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingSection(BuildContext context, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pattern name
        Obx(
          () => Text(
            controller.selectedPattern.value?.name ?? 'Select Pattern',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Breathing circle
        Obx(
          () => _BreathingOrb(
            phase: controller.currentPhase.value,
            progress: controller.phaseProgress.value,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 24),
        // Phase label
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              controller.phaseLabel,
              key: ValueKey(controller.phaseLabel),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Countdown
        Obx(
          () => Text(
            controller.timerState.value == TimerState.idle
                ? ''
                : '${controller.phaseSecondsRemaining.value}',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w200,
              color: AppColors.meditationAccent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Session stats
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatPill(
                icon: AppIcons.timer,
                value: controller.formattedElapsedTime,
                isDark: isDark,
              ),
              const SizedBox(width: 16),
              _StatPill(
                icon: AppIcons.repeat,
                value: '${controller.completedCycles.value} cycles',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Pattern selector (only when idle)
          Obx(
            () => controller.isIdle
                ? _buildPatternSelector(isDark)
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          // Control buttons
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!controller.isIdle) ...[
                  _ControlButton(
                    icon: AppIcons.stop,
                    label: 'Stop',
                    gradient: [
                      const Color(0xFFFF6B6B),
                      const Color(0xFFFF8E53),
                    ],
                    onTap: controller.stop,
                    size: 60,
                  ),
                  const SizedBox(width: 24),
                ],
                _ControlButton(
                  icon: controller.isRunning ? AppIcons.pause : AppIcons.play,
                  label: controller.isRunning
                      ? 'Pause'
                      : (controller.isPaused ? 'Resume' : 'Start'),
                  gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                  onTap: () {
                    if (controller.isRunning) {
                      controller.pause();
                    } else if (controller.isPaused) {
                      controller.resume();
                    } else {
                      controller.start();
                    }
                  },
                  size: 80,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternSelector(bool isDark) {
    return SizedBox(
      height: 70,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.patterns.length,
          itemBuilder: (context, index) {
            return Obx(() {
              final pattern = controller.patterns[index];
              final isSelected =
                  controller.selectedPattern.value?.id == pattern.id;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == controller.patterns.length - 1 ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => controller.selectPattern(pattern),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pattern.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pattern.patternString,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white70
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

/// Animated breathing orb
class _BreathingOrb extends StatelessWidget {
  final BreathingPhase phase;
  final double progress;
  final bool isDark;

  const _BreathingOrb({
    required this.phase,
    required this.progress,
    required this.isDark,
  });

  double get _scale {
    switch (phase) {
      case BreathingPhase.inhale:
        return 0.6 + (0.4 * progress);
      case BreathingPhase.hold1:
        return 1.0;
      case BreathingPhase.exhale:
        return 1.0 - (0.4 * progress);
      case BreathingPhase.hold2:
      case BreathingPhase.idle:
        return 0.6;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow rings
          ...List.generate(3, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 200 + (i * 30) * _scale,
              height: 200 + (i * 30) * _scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.meditationAccent.withValues(
                    alpha: 0.1 - (i * 0.03),
                  ),
                  width: 2,
                ),
              ),
            );
          }),
          // Main orb
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 160 * _scale,
            height: 160 * _scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.meditationAccent,
                  AppColors.meditationAccent.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.meditationAccent.withValues(alpha: 0.4),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Inner highlight
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 80 * _scale,
            height: 80 * _scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Toggle button widget
class _ToggleButton extends StatelessWidget {
  final dynamic icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive
              ? AppColors.meditationAccent.withValues(alpha: 0.2)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? AppColors.meditationAccent
              : (isDark ? Colors.white54 : Colors.black45),
        ),
      ),
    );
  }
}

/// Stat pill widget
class _StatPill extends StatelessWidget {
  final dynamic icon;
  final String value;
  final bool isDark;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Control button with gradient
class _ControlButton extends StatefulWidget {
  final dynamic icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    required this.size,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.first.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: widget.size * 0.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
