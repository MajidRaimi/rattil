import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/typography_ext.dart';
import '../../providers/quran_providers.dart';
import 'widgets/last_read_card.dart';
import 'widgets/surah_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typography;
    final surahsAsync = ref.watch(allSurahsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('القرآن الكريم', style: typo.arabicDisplay),
                    IconButton(
                      onPressed: () => context.push(AppRouter.settings),
                      icon: Icon(Icons.settings_outlined, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: LastReadCard()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Surahs', style: typo.headlineMedium),
              ),
            ),
            surahsAsync.when(
              data: (surahs) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => SurahListTile(surah: surahs[index]),
                  childCount: surahs.length,
                ),
              ),
              loading: () => SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: colors.gold)),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Text('Error loading surahs', style: typo.bodyLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
