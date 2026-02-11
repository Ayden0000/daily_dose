import 'package:flutter/material.dart';

/// Reusable inline error banner used across list views.
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const ErrorBanner({super.key, required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.redAccent : Colors.red).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.redAccent : Colors.red).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: isDark ? Colors.redAccent : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.red[100] : Colors.red[900],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: isDark ? Colors.red[100] : Colors.red[900],
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
