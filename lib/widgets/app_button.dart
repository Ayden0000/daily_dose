import 'package:flutter/material.dart';
import 'package:daily_dose/app/theme/app_spacing.dart';

/// Button variant types
enum AppButtonVariant { primary, secondary, outline, ghost }

/// Button size types
enum AppButtonSize { small, medium, large }

/// Reusable button component with consistent styling
///
/// Supports multiple variants and sizes. Uses theme colors
/// for consistent appearance across light/dark modes.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Size configurations
    final EdgeInsets padding;
    final double fontSize;
    final double iconSize;

    switch (size) {
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        fontSize = 12;
        iconSize = 16;
        break;
      case AppButtonSize.medium:
        padding = AppSpacing.buttonPadding;
        fontSize = 14;
        iconSize = 20;
        break;
      case AppButtonSize.large:
        padding = AppSpacing.buttonPaddingLarge;
        fontSize = 16;
        iconSize = 24;
        break;
    }

    // Build button content
    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          AppSpacing.hGapSm,
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize),
          AppSpacing.hGapSm,
        ],
        Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
      ],
    );

    // Build button based on variant
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(padding: padding),
          child: content,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
          ),
          child: content,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(padding: padding),
          child: content,
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(padding: padding),
          child: content,
        );
    }
  }
}

/// Icon-only button variant
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (backgroundColor != null) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: IconButton(
          icon: Icon(icon, size: size),
          color: color ?? theme.colorScheme.onSurface,
          onPressed: onPressed,
        ),
      );
    }

    return IconButton(
      icon: Icon(icon, size: size),
      color: color ?? theme.iconTheme.color,
      onPressed: onPressed,
    );
  }
}
