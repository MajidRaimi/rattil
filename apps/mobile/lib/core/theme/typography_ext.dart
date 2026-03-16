import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'app_color_scheme.dart';
import 'app_typography.dart';

extension ColorSchemeContext on BuildContext {
  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>()!;
}

extension TypographyContext on BuildContext {
  AppTypography get typography {
    final locale = Locales.currentLocale(this)?.languageCode ?? 'en';
    return AppTypography.of(locale, colors);
  }
}
