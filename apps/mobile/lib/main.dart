import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:imad_flutter/imad_flutter.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'app.dart';
import 'data/services/home_widget_service.dart';
import 'data/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Quran.initialize();
  await HomeWidgetService.updateWidget();
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await NotificationService.init();
  await NotificationService.requestPermission();
  await Locales.init([
    'ar', 'en', 'am', 'az', 'bn', 'bs', 'zh', 'cs', 'nl', 'tl',
    'fr', 'de', 'ha', 'hi', 'id', 'it', 'ja', 'kk', 'ko', 'ku',
    'ky', 'ms', 'no', 'ps', 'fa', 'pl', 'pt', 'ro', 'ru', 'sd',
    'so', 'es', 'sw', 'sv', 'tg', 'ta', 'th', 'tr', 'uk', 'ur',
    'uz', 'vi', 'wo', 'yo',
  ]);
  await Quran.initialize();
  await setupMushafWithHive();
  await HomeWidgetService.initialize();
  HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);
  await HomeWidgetService.updateWidget();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: QuranApp()));
}
