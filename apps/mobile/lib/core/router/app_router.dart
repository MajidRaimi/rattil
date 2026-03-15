import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/reader/reader_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../widgets/app_shell.dart';

abstract final class AppRouter {
  static const String home = '/';
  static const String search = '/search';
  static const String bookmarks = '/bookmarks';
  static const String reader = '/surah/:number';
  static const String settings = '/settings';

  static String readerPath(int surahNumber) => '/surah/$surahNumber';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: search,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: bookmarks,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookmarksScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: reader,
        builder: (context, state) {
          final number = int.parse(state.pathParameters['number']!);
          return ReaderScreen(surahNumber: number);
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
