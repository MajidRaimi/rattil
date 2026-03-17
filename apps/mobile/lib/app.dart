import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

class QuranApp extends ConsumerWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return LocaleBuilder(
      builder: (locale) {
        final langCode = locale?.languageCode ?? 'en';
        final lightTheme = AppTheme.light(langCode);
        final darkTheme = AppTheme.dark(langCode);

        return ScreenUtilInit(
          designSize: const Size(392.73, 800.73),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp.router(
            title: 'Rattil',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
            locale: locale,
            localizationsDelegates: Locales.delegates,
            supportedLocales: Locales.supportedLocales,
          ),
        );
      },
    );
  }
}
