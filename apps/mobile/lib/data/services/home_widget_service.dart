import 'dart:math';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_flutter/quran_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../features/home_widget/ayah_widget_view.dart';

class HomeWidgetService {
  static const _androidName = 'QuranAyahWidgetProvider';
  static const _iOSName = 'QuranAyahWidget';
  static const _appGroupId = 'group.app.rattil';

  static Future<void> initialize() async {
    HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> updateWidget() async {
    // Save app theme mode so the iOS widget can read it
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('theme_mode') ?? 'system';
    await HomeWidget.saveWidgetData('app_theme', themeMode);

    // Render all 3 sizes
    await Future.wait([
      _renderSize(WidgetSize.small),
      _renderSize(WidgetSize.medium),
      _renderSize(WidgetSize.large),
    ]);

    await HomeWidget.updateWidget(
      androidName: _androidName,
      iOSName: _iOSName,
    );
  }

  static ({int minChars, int maxChars}) _charRange(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => (minChars: 20, maxChars: 80),
      WidgetSize.medium => (minChars: 50, maxChars: 150),
      WidgetSize.large => (minChars: 100, maxChars: 400),
    };
  }

  static Size _logicalSize(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => const Size(200, 200),
      WidgetSize.medium => const Size(400, 200),
      WidgetSize.large => const Size(400, 420),
    };
  }

  static String _keyPrefix(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => 'ayah_widget_small',
      WidgetSize.medium => 'ayah_widget',
      WidgetSize.large => 'ayah_widget_large',
    };
  }

  static Future<void> _renderSize(WidgetSize size) async {
    final random = Random();
    final range = _charRange(size);
    String ayahText;
    int ayahNumber;
    int surahNumber;
    int attempts = 0;

    // Pick a random ayah that fits the size
    do {
      surahNumber = random.nextInt(114) + 1;
      final verseCount = quran.getVerseCount(surahNumber);
      ayahNumber = random.nextInt(verseCount) + 1;
      final verse = Quran.getVerse(
        surahNumber: surahNumber,
        verseNumber: ayahNumber,
      );
      ayahText = verse.text;
      attempts++;
      if (attempts > 500) break; // safety fallback
    } while (ayahText.length < range.minChars || ayahText.length > range.maxChars);

    final surahName = quran.getSurahNameArabic(surahNumber);
    final logicalSize = _logicalSize(size);
    final prefix = _keyPrefix(size);

    // Render light variant
    await HomeWidget.renderFlutterWidget(
      AyahWidgetView(
        ayahText: ayahText,
        surahName: surahName,
        ayahNumber: ayahNumber,
        colors: AppColorScheme.light,
        widgetSize: size,
      ),
      logicalSize: logicalSize,
      pixelRatio: 5,
      key: '${prefix}_light',
    );

    // Render dark variant
    await HomeWidget.renderFlutterWidget(
      AyahWidgetView(
        ayahText: ayahText,
        surahName: surahName,
        ayahNumber: ayahNumber,
        colors: AppColorScheme.dark.copyWith(surface: const Color(0xFF000000)),
        widgetSize: size,
      ),
      logicalSize: logicalSize,
      pixelRatio: 5,
      key: '${prefix}_dark',
    );
  }
}
