import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // Arabic - Quranic text
  static const TextStyle quranArabic = TextStyle(
    fontFamily: 'UthmanicHafs',
    fontSize: 28,
    height: 2.0,
    color: AppColors.textArabic,
    letterSpacing: 0,
  );

  // Arabic - UI text
  static const TextStyle uiArabic = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  // Arabic - Surah name in lists
  static const TextStyle surahNameArabic = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Latin text styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
}
