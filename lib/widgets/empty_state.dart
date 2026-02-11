import 'package:flutter/material.dart';
import 'package:daily_dose/app/theme/app_spacing.dart';

/// Empty state widget for lists and screens
///
/// Displays when there's no content to show.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = iconColor;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: (accent ?? theme.colorScheme.primary).withValues(
                alpha: 0.5,
              ),
            ),
            AppSpacing.vGapLg,
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: accent ?? theme.textTheme.titleMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.vGapSm,
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: (accent ?? theme.textTheme.bodySmall?.color)
                      ?.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[AppSpacing.vGapLg, action!],
          ],
        ),
      ),
    );
  }
}
