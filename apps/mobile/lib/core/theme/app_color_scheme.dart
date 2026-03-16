import 'package:flutter/material.dart';

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceHigh;
  final Color gold;
  final Color goldLight;
  final Color goldDim;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textArabic;
  final Color error;
  final Color success;
  final Color divider;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceHigh,
    required this.gold,
    required this.goldLight,
    required this.goldDim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textArabic,
    required this.error,
    required this.success,
    required this.divider,
  });

  static const dark = AppColorScheme(
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF1A1A1A),
    surfaceVariant: Color(0xFF242424),
    surfaceHigh: Color(0xFF2E2E2E),
    gold: Color(0xFFD4A843),
    goldLight: Color(0xFFE8C97A),
    goldDim: Color(0xFF8B7335),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFB0B0B0),
    textTertiary: Color(0xFF707070),
    textArabic: Color(0xFFFFFFFF),
    error: Color(0xFFCF6679),
    success: Color(0xFF4CAF50),
    divider: Color(0xFF2A2A2A),
  );

  static const light = AppColorScheme(
    background: Color(0xFFF7F5F0),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEDE8DF),
    surfaceHigh: Color(0xFFE0DAD0),
    gold: Color(0xFFB8922D),
    goldLight: Color(0xFFD4A843),
    goldDim: Color(0xFF9A7D2E),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF5A5A5A),
    textTertiary: Color(0xFF9A9A9A),
    textArabic: Color(0xFF1A1A1A),
    error: Color(0xFFB00020),
    success: Color(0xFF2E7D32),
    divider: Color(0xFFE0DDD6),
  );

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceHigh,
    Color? gold,
    Color? goldLight,
    Color? goldDim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textArabic,
    Color? error,
    Color? success,
    Color? divider,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      gold: gold ?? this.gold,
      goldLight: goldLight ?? this.goldLight,
      goldDim: goldDim ?? this.goldDim,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textArabic: textArabic ?? this.textArabic,
      error: error ?? this.error,
      success: success ?? this.success,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      goldDim: Color.lerp(goldDim, other.goldDim, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textArabic: Color.lerp(textArabic, other.textArabic, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
