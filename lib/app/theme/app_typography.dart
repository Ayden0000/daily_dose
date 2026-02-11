import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daily_dose/app/theme/app_colors.dart';

/// Central typography scale
///
/// Design Philosophy:
/// - Inter font for clean, modern readability
/// - Semantic naming (display, headline, title, body, label)
/// - Consistent line heights for rhythm
class AppTypography {
  AppTypography._();

  // Font family
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  // ============ TEXT THEME FOR LIGHT MODE ============

  static TextTheme get lightTextTheme => TextTheme(
    // Display - Large promotional text
    displayLarge: GoogleFonts.inter(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
      color: AppColors.textPrimaryLight,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
      color: AppColors.textPrimaryLight,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
      color: AppColors.textPrimaryLight,
    ),

    // Headline - Section headers
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
      color: AppColors.textPrimaryLight,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.29,
      color: AppColors.textPrimaryLight,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.33,
      color: AppColors.textPrimaryLight,
    ),

    // Title - Subsection headers
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
      color: AppColors.textPrimaryLight,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
      color: AppColors.textPrimaryLight,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      color: AppColors.textPrimaryLight,
    ),

    // Body - Main content
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
      color: AppColors.textPrimaryLight,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
      color: AppColors.textPrimaryLight,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      color: AppColors.textSecondaryLight,
    ),

    // Label - Buttons, chips, captions
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      color: AppColors.textPrimaryLight,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
      color: AppColors.textPrimaryLight,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
      color: AppColors.textSecondaryLight,
    ),
  );

  // ============ TEXT THEME FOR DARK MODE ============

  static TextTheme get darkTextTheme => TextTheme(
    displayLarge: lightTextTheme.displayLarge!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    displayMedium: lightTextTheme.displayMedium!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    displaySmall: lightTextTheme.displaySmall!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineLarge: lightTextTheme.headlineLarge!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineMedium: lightTextTheme.headlineMedium!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineSmall: lightTextTheme.headlineSmall!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleLarge: lightTextTheme.titleLarge!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleMedium: lightTextTheme.titleMedium!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleSmall: lightTextTheme.titleSmall!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodyLarge: lightTextTheme.bodyLarge!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: lightTextTheme.bodyMedium!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodySmall: lightTextTheme.bodySmall!.copyWith(
      color: AppColors.textSecondaryDark,
    ),
    labelLarge: lightTextTheme.labelLarge!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    labelMedium: lightTextTheme.labelMedium!.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    labelSmall: lightTextTheme.labelSmall!.copyWith(
      color: AppColors.textSecondaryDark,
    ),
  );
}
