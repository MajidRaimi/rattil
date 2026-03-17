import 'dart:math';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_flutter/quran_flutter.dart';
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
    final random = Random();
    String ayahText;
    String surahName;
    int ayahNumber;
    int surahNumber;

    // Pick a random ayah that fits (< 200 chars)
    do {
      surahNumber = random.nextInt(114) + 1;
      final verseCount = quran.getVerseCount(surahNumber);
      ayahNumber = random.nextInt(verseCount) + 1;
      final verse = Quran.getVerse(
        surahNumber: surahNumber,
        verseNumber: ayahNumber,
      );
      ayahText = verse.text;
    } while (ayahText.length > 200);

    surahName = quran.getSurahNameArabic(surahNumber);
    final displayText = ayahText;

    // Render light variant
    await HomeWidget.renderFlutterWidget(
      AyahWidgetView(
        ayahText: displayText,
        surahName: surahName,
        ayahNumber: ayahNumber,
        colors: AppColorScheme.light,
      ),
      logicalSize: const Size(400, 200),
      pixelRatio: 5,
      key: 'ayah_widget_light',
    );

    // Render dark variant
    await HomeWidget.renderFlutterWidget(
      AyahWidgetView(
        ayahText: displayText,
        surahName: surahName,
        ayahNumber: ayahNumber,
        colors: AppColorScheme.dark,
      ),
      logicalSize: const Size(400, 200),
      pixelRatio: 5,
      key: 'ayah_widget_dark',
    );

    await HomeWidget.updateWidget(
      androidName: _androidName,
      iOSName: _iOSName,
    );
  }
}
