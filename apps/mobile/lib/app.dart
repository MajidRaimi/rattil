import 'package:animated_theme_switcher/animated_theme_switcher.dart';
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

        final initTheme = switch (themeMode) {
          ThemeMode.light => lightTheme,
          ThemeMode.dark => darkTheme,
          _ => WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark
              ? darkTheme
              : lightTheme,
        };

        return ThemeProvider(
          initTheme: initTheme,
          builder: (context, theme) => ScreenUtilInit(
            designSize: const Size(392.73, 800.73),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp.router(
              title: 'Rattil',
              debugShowCheckedModeBanner: false,
              theme: theme,
              routerConfig: AppRouter.router,
              locale: locale,
              localizationsDelegates: Locales.delegates,
              supportedLocales: Locales.supportedLocales,
            ),
          ),
        );
      },
    );
  }
}
