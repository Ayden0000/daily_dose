import 'package:flutter/material.dart';

/// Central color palette for the application
///
/// Design Philosophy:
/// - Soft, calm colors inspired by Headspace/Notion
/// - High contrast for accessibility
/// - Consistent semantic naming
class AppColors {
  AppColors._();

  // ============ LIGHT THEME ============

  // Primary - Soft indigo for calm, focused feel
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryVariantLight = Color(0xFF4F46E5);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);

  // Secondary - Warm coral for accents
  static const Color secondaryLight = Color(0xFFF97316);
  static const Color secondaryVariantLight = Color(0xFFEA580C);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);

  // Background & Surface
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  static const Color onBackgroundLight = Color(0xFF1F2937);
  static const Color onSurfaceLight = Color(0xFF1F2937);

  // Semantic colors
  static const Color errorLight = Color(0xFFDC2626);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color successLight = Color(0xFF16A34A);
  static const Color warningLight = Color(0xFFF59E0B);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color textDisabledLight = Color(0xFFD1D5DB);

  // Border & Divider
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // ============ DARK THEME ============

  // Primary
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color primaryVariantDark = Color(0xFF6366F1);
  static const Color onPrimaryDark = Color(0xFF1F2937);

  // Secondary
  static const Color secondaryDark = Color(0xFFFB923C);
  static const Color secondaryVariantDark = Color(0xFFF97316);
  static const Color onSecondaryDark = Color(0xFF1F2937);

  // Background & Surface
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);
  static const Color onBackgroundDark = Color(0xFFF9FAFB);
  static const Color onSurfaceDark = Color(0xFFF9FAFB);

  // Semantic colors
  static const Color errorDark = Color(0xFFF87171);
  static const Color onErrorDark = Color(0xFF1F2937);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color warningDark = Color(0xFFFBBF24);

  // Text colors
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color textDisabledDark = Color(0xFF4B5563);

  // Border & Divider
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerDark = Color(0xFF1F2937);

  // ============ SCAFFOLD BACKGROUNDS ============

  static const Color scaffoldDark = Color(0xFF0D0D1A);
  static const Color scaffoldLight = Color(0xFFF8FAFF);
  static const Color surfaceElevatedDark = Color(0xFF1A1A2E);

  // ============ HOME GRADIENT (warm energetic) ============

  // Light — sunrise peach → soft coral → lavender
  static const Color homeGradientLightStart = Color(0xFFFFF5ED);
  static const Color homeGradientLightMid = Color(0xFFFDECE2);
  static const Color homeGradientLightEnd = Color(0xFFEDE7F6);

  // Dark — deep navy → indigo → purple
  static const Color homeGradientDarkStart = Color(0xFF0B0B1E);
  static const Color homeGradientDarkMid = Color(0xFF141432);
  static const Color homeGradientDarkEnd = Color(0xFF1A1040);

  // ============ MODULE ACCENT COLORS ============

  // Tasks module - Blue tones
  static const Color tasksAccent = Color(0xFF3B82F6);
  static const Color tasksAccentLight = Color(0xFFDBEAFE);
  static const Color tasksAccentDark = Color(0xFF1E3A5F);
  static const Color tasksGradientEnd = Color(0xFF60A5FA);

  // Expenses module - Green tones
  static const Color expensesAccent = Color(0xFF10B981);
  static const Color expensesAccentLight = Color(0xFFD1FAE5);
  static const Color expensesAccentDark = Color(0xFF064E3B);
  static const Color expensesGradientEnd = Color(0xFF34D399);

  // Meditation module - Purple tones
  static const Color meditationAccent = Color(0xFF8B5CF6);
  static const Color meditationAccentLight = Color(0xFFEDE9FE);
  static const Color meditationAccentDark = Color(0xFF4C1D95);
  static const Color meditationGradientEnd = Color(0xFFA78BFA);

  // Habits module - Teal tones
  static const Color habitsAccent = Color(0xFF14B8A6);
  static const Color habitsAccentLight = Color(0xFFCCFBF1);
  static const Color habitsAccentDark = Color(0xFF134E4A);
  static const Color habitsGradientEnd = Color(0xFF2DD4BF);

  // Journal/Mood module - Rose tones
  static const Color journalAccent = Color(0xFFF43F5E);
  static const Color journalAccentLight = Color(0xFFFFE4E6);
  static const Color journalAccentDark = Color(0xFF881337);
  static const Color journalGradientEnd = Color(0xFFFB7185);

  // Goals module - Amber tones
  static const Color goalsAccent = Color(0xFFF59E0B);
  static const Color goalsAccentLight = Color(0xFFFEF3C7);
  static const Color goalsAccentDark = Color(0xFF78350F);
  static const Color goalsGradientEnd = Color(0xFFFBBF24);

  // Focus Timer module - Warm orange/brown tones
  static const Color focusAccent = Color(0xFFEA580C);
  static const Color focusAccentLight = Color(0xFFFFF7ED);
  static const Color focusAccentDark = Color(0xFF7C2D12);
  static const Color focusGradientEnd = Color(0xFFFB923C);

  // Review module - Cyan tones
  static const Color reviewAccent = Color(0xFF06B6D4);
  static const Color reviewAccentLight = Color(0xFFCFFAFE);
  static const Color reviewAccentDark = Color(0xFF164E63);
  static const Color reviewGradientEnd = Color(0xFF22D3EE);

  // ============ DESTRUCTIVE GRADIENT ============

  static const Color destructiveStart = Color(0xFFEF4444);
  static const Color destructiveEnd = Color(0xFFF87171);

  // ============ MOOD COLORS ============

  static const Color moodAwful = Color(0xFFEF4444); // 1 - Red
  static const Color moodBad = Color(0xFFF97316); // 2 - Orange
  static const Color moodOkay = Color(0xFFF59E0B); // 3 - Amber
  static const Color moodGood = Color(0xFF22C55E); // 4 - Green
  static const Color moodGreat = Color(0xFF10B981); // 5 - Emerald

  static const List<Color> moodColors = [
    moodAwful,
    moodBad,
    moodOkay,
    moodGood,
    moodGreat,
  ];

  // ============ PRIORITY COLORS ============

  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);
}
