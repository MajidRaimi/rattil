import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import '../../data/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/supported_languages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/typography_ext.dart';
import '../../data/services/notification_service.dart';
import '../../providers/quran_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/tikrar_provider.dart';
import '../../providers/tutorial_provider.dart';
import '../../providers/wird_provider.dart';
import '../../providers/khatmah_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;
    final currentLocale = Locales.currentLocale(context);
    final currentLang = supportedLanguages.firstWhere(
      (l) => l.code == currentLocale?.languageCode,
      orElse: () => supportedLanguages[1],
    );

    return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 24),
              Text(
                Locales.string(context, 'settings'),
                style: typo.headlineMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              // ── Language ──
              _SectionCard(
                titleKey: 'language',
                children: [
                  _LanguageTile(
                    nativeName: currentLang.nativeName,
                    englishName: currentLang.englishName,
                    onTap: () => _showLanguagePicker(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Theme ──
              _ThemeSection(),
              const SizedBox(height: 16),

              // ── Help & Support ──
              _FaqSection(),
              const SizedBox(height: 12),

              // ── Replay Tutorial ──
              _ReplayTutorialTile(),
              const SizedBox(height: 16),

              // ── About ──
              _AboutSection(),
              const SizedBox(height: 24),

              // ── Clear Data ──
              _ClearDataButton(
                onTap: () => _showClearDataDialog(context, ref),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LanguagePickerSheet(),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typography;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          Locales.string(context, 'clear_data'),
          style: typo.titleMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          Locales.string(context, 'clear_data_confirm'),
          style: typo.bodyMedium.copyWith(
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Locales.string(context, 'wird_cancel'),
              style: typo.bodyLarge.copyWith(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _clearAllData(context, ref);
            },
            child: Text(
              Locales.string(context, 'clear_data'),
              style: typo.bodyLarge.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(quranRepositoryProvider);
    await repo.clearAllUserData();
    await ref.read(wirdConfigNotifierProvider.notifier).clearWird();
    await ref.read(khatmahConfigNotifierProvider.notifier).clearKhatmah();
    await ref.read(tikrarSessionsProvider.notifier).clearAllSessions();
    await NotificationService.cancelWirdReminder();

    ref.invalidate(bookmarkKeysProvider);
    ref.invalidate(allBookmarksProvider);
    ref.invalidate(memorizedPagesProvider);
    ref.invalidate(readingProgressProvider);
    ref.invalidate(wirdCompletedTodayProvider);
    ref.invalidate(khatmahCompletedTodayProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Locales.string(context, 'clear_data_success')),
        ),
      );
    }
  }
}

// ── Reusable section card ──

class _SectionCard extends StatelessWidget {
  final String titleKey;
  final List<Widget> children;

  const _SectionCard({required this.titleKey, required this.children});

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            Locales.string(context, titleKey).toUpperCase(),
            style: typo.bodySmall.copyWith(
              color: colors.goldDim,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Language tile ──

class _LanguageTile extends StatelessWidget {
  final String nativeName;
  final String englishName;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.nativeName,
    required this.englishName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: typo.bodyLarge.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    englishName,
                    style: typo.bodySmall.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Theme section ──

class _ThemeSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;
    final currentMode = ref.watch(appThemeModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            Locales.string(context, 'theme').toUpperCase(),
            style: typo.bodySmall.copyWith(
              color: colors.goldDim,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _ThemeChip(
                icon: Icons.phone_android,
                labelKey: 'theme_system',
                isSelected: currentMode == ThemeMode.system,
                targetMode: ThemeMode.system,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeChip(
                icon: Icons.light_mode_outlined,
                labelKey: 'theme_light',
                isSelected: currentMode == ThemeMode.light,
                targetMode: ThemeMode.light,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeChip(
                icon: Icons.dark_mode_outlined,
                labelKey: 'theme_dark',
                isSelected: currentMode == ThemeMode.dark,
                targetMode: ThemeMode.dark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeChip extends ConsumerWidget {
  final IconData icon;
  final String labelKey;
  final bool isSelected;
  final ThemeMode targetMode;

  const _ThemeChip({
    required this.icon,
    required this.labelKey,
    required this.isSelected,
    required this.targetMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;
    final langCode = Locales.currentLocale(context)?.languageCode ?? 'en';

    return GestureDetector(
          onTap: () {
            ref
                .read(appThemeModeProvider.notifier)
                .setThemeMode(targetMode);
            AnalyticsService.event('Theme Changed', props: {'to': targetMode.name});
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.gold.withValues(alpha: 0.12)
                  : colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? colors.gold.withValues(alpha: 0.5)
                    : colors.divider,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? colors.gold : colors.textTertiary,
                  size: 22,
                ),
                const SizedBox(height: 6),
                Text(
                  Locales.string(context, labelKey),
                  style: typo.bodySmall.copyWith(
                    color: isSelected ? colors.gold : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

// ── FAQ section ──

class _FaqSection extends StatelessWidget {
  static const _faqs = [
    ('faq_navigate_q', 'faq_navigate_a'),
    ('faq_wird_q', 'faq_wird_a'),
    ('faq_tikrar_q', 'faq_tikrar_a'),
    ('faq_offline_q', 'faq_offline_a'),
    ('faq_hifz_q', 'faq_hifz_a'),
  ];

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            Locales.string(context, 'help_support').toUpperCase(),
            style: typo.bodySmall.copyWith(
              color: colors.goldDim,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _faqs.length; i++) ...[
                if (i > 0)
                  Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: colors.divider),
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    iconColor: colors.textTertiary,
                    collapsedIconColor: colors.textTertiary,
                    title: Text(
                      Locales.string(context, _faqs[i].$1),
                      style: typo.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    children: [
                      Text(
                        Locales.string(context, _faqs[i].$2),
                        style: typo.bodyMedium.copyWith(
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Replay Tutorial tile ──

class _ReplayTutorialTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        // Reset tutorial status — the listener in _AppShellState will
        // detect the change and auto-start the tutorial.
        ref.read(tutorialStatusProvider.notifier).reset();
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.school_rounded, color: colors.gold, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Locales.string(context, 'tutorial_replay'),
                  style: typo.bodyLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── About section ──

class _AboutSection extends StatefulWidget {
  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            Locales.string(context, 'about').toUpperCase(),
            style: typo.bodySmall.copyWith(
              color: colors.goldDim,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _InfoTile(
                  labelKey: 'app_version',
                  value: _version),
              Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colors.divider),
              _InfoTile(
                  labelKey: 'translation',
                  value: Locales.string(context, 'saheeh_international')),
              Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colors.divider),
              _InfoTile(
                  labelKey: 'arabic_script',
                  value: Locales.string(context, 'uthmanic_hafs')),
              Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colors.divider),
              _LinkTile(
                  labelKey: 'privacy_policy',
                  value: Locales.string(context, 'privacy_policy'),
                  url: 'https://github.com/MajidRaimi/rattil/blob/main/PRIVACY_POLICY.md'),
              Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colors.divider),
              _LinkTile(
                  labelKey: 'contact_support',
                  value: Locales.string(context, 'contact_support'),
                  url: 'mailto:majidsraimi@gmail.com'),
              Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colors.divider),
              const _LinkTile(
                  labelKey: 'source_code',
                  value: 'GitHub',
                  url: 'https://github.com/MajidRaimi/rattil'),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String labelKey;
  final String value;

  const _InfoTile({required this.labelKey, required this.value});

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Locales.string(context, labelKey),
            style: typo.bodyLarge.copyWith(color: colors.textPrimary),
          ),
          Text(value, style: typo.bodyMedium),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String labelKey;
  final String value;
  final String url;

  const _LinkTile({
    required this.labelKey,
    required this.value,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Locales.string(context, labelKey),
              style: typo.bodyLarge.copyWith(color: colors.textPrimary),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: typo.bodyMedium.copyWith(color: colors.goldDim)),
                const SizedBox(width: 4),
                Icon(Icons.open_in_new, size: 14, color: colors.goldDim),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Clear Data button ──

class _ClearDataButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ClearDataButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.error.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            Locales.string(context, 'clear_data'),
            style: typo.bodyLarge.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Language picker sheet ──

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet();

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  final _searchController = TextEditingController();
  List<SupportedLanguage> _filtered = supportedLanguages;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = supportedLanguages;
      } else {
        _filtered = supportedLanguages
            .where((l) =>
                l.nativeName.toLowerCase().contains(query) ||
                l.englishName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final currentLocale = Locales.currentLocale(context)?.languageCode ?? 'en';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              Locales.string(context, 'language'),
              style: typo.headlineMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              style: typo.bodyLarge.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: Locales.string(context, 'search'),
                hintStyle: typo.bodyLarge.copyWith(color: colors.textTertiary),
                prefixIcon: Icon(Icons.search, color: colors.textTertiary),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final lang = _filtered[index];
                final isSelected = lang.code == currentLocale;
                final nativeDirection =
                    lang.isRtl ? TextDirection.rtl : TextDirection.ltr;
                return InkWell(
                  onTap: () {
                    Locales.change(context, lang.code);
                    AnalyticsService.event('Language Changed', props: {'to': lang.code});
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.nativeName,
                                textDirection: nativeDirection,
                                style: typo.bodyLarge.copyWith(
                                  color: isSelected
                                      ? colors.gold
                                      : colors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang.englishName,
                                style: typo.bodySmall.copyWith(
                                  color: isSelected
                                      ? colors.goldDim
                                      : colors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: colors.gold,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
