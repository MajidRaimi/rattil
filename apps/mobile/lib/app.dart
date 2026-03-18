import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/home_widget_service.dart';
import 'providers/theme_provider.dart';

class QuranApp extends ConsumerStatefulWidget {
  const QuranApp({super.key});

  @override
  ConsumerState<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends ConsumerState<QuranApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      HomeWidgetService.updateWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
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
