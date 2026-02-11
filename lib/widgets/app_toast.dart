import 'package:flutter/material.dart';

/// Minimal bottom toast — a rounded pill that slides up, auto-dismisses.
///
/// Usage:
/// ```dart
/// AppToast.show(context, 'Saved ✨');
/// AppToast.success(context, 'Habit created');
/// AppToast.error(context, 'Please enter a title');
/// ```
class AppToast {
  AppToast._();

  /// Generic toast with optional icon.
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    _display(
      context,
      message: message,
      icon: icon,
      bg: const Color(0xFF1E1E2E),
      fg: Colors.white,
      duration: duration,
    );
  }

  /// Green-tinted success toast.
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _display(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      bg: const Color(0xFF0D7254),
      fg: Colors.white,
      duration: duration,
    );
  }

  /// Red-tinted error toast.
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _display(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      bg: const Color(0xFFB91C3B),
      fg: Colors.white,
      duration: duration,
    );
  }

  static void _display(
    BuildContext context, {
    required String message,
    required Color bg,
    required Color fg,
    IconData? icon,
    required Duration duration,
  }) {
    // Remove any existing toast first
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      elevation: 8,
      duration: duration,
      dismissDirection: DismissDirection.down,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
