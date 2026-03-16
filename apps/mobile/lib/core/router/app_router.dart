import 'package:go_router/go_router.dart';
import '../../features/reader/quran_main_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/settings/settings_screen.dart';

abstract final class AppRouter {
  static const String home = '/';
  static const String search = '/search';
  static const String bookmarks = '/bookmarks';
  static const String settings = '/settings';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const QuranMainScreen(),
      ),
      GoRoute(
        path: search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: bookmarks,
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
