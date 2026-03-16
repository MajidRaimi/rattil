import 'package:flutter/material.dart';
import 'app_color_scheme.dart';

class AppTypography {
  final String locale;
  final AppColorScheme colors;

  const AppTypography._(this.locale, this.colors);

  factory AppTypography.of(String locale, AppColorScheme colors) {
    return AppTypography._(locale, colors);
  }

  String get _uiFont => 'NeueFrutigerWorld';

  // ── Quranic text ──

  TextStyle get quranArabic => TextStyle(
        fontFamily: 'UthmanicHafs',
        fontSize: 28,
        height: 2.0,
        color: colors.textArabic,
        letterSpacing: 0,
      );

  // ── Arabic proper nouns (surah names, headers) ──

  TextStyle get arabicDisplay => TextStyle(
        fontFamily: 'NeueFrutigerWorld',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: colors.textPrimary,
      );

  TextStyle get arabicDisplayBody => TextStyle(
        fontFamily: 'NeueFrutigerWorld',
        fontSize: 18,
        height: 1.6,
        color: colors.textPrimary,
      );

  // ── Locale-aware UI text ──

  TextStyle get headlineLarge => TextStyle(
        fontFamily: _uiFont,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        letterSpacing: -0.5,
      );

  TextStyle get headlineMedium => TextStyle(
        fontFamily: _uiFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      );

  TextStyle get titleMedium => TextStyle(
        fontFamily: _uiFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      );

  TextStyle get bodyLarge => TextStyle(
        fontFamily: _uiFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.5,
      );

  TextStyle get bodyMedium => TextStyle(
        fontFamily: _uiFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      );

  TextStyle get bodySmall => TextStyle(
        fontFamily: _uiFont,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.textTertiary,
      );

  TextStyle get labelMedium => TextStyle(
        fontFamily: _uiFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
        letterSpacing: 0.5,
      );
}
