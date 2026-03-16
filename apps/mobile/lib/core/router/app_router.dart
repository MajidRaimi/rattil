import 'package:go_router/go_router.dart';
import '../../features/reader/reader_screen.dart';
import '../../features/reader/quran_main_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/bookmarks/bookmarks_screen.dart';
import '../../features/settings/settings_screen.dart';

abstract final class AppRouter {
  static const String home = '/';
  static const String search = '/search';
  static const String bookmarks = '/bookmarks';
  static const String reader = '/surah/:number';
  static const String settings = '/settings';

  static String readerPath(int surahNumber, {int? ayah}) {
    final base = '/surah/$surahNumber';
    if (ayah != null && ayah > 1) return '$base?ayah=$ayah';
    return base;
  }

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const QuranMainScreen(),
      ),
      GoRoute(
        path: reader,
        builder: (context, state) {
          final number = int.parse(state.pathParameters['number']!);
          final ayah =
              int.tryParse(state.uri.queryParameters['ayah'] ?? '') ?? 1;
          return ReaderScreen(surahNumber: number, initialAyah: ayah);
        },
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
