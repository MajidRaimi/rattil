import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;
import '../../core/constants/supported_languages.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/typography_ext.dart';
import '../../providers/theme_provider.dart';

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

    return ThemeSwitchingArea(
      child: Scaffold(
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
            _ThemeSection(),
            const SizedBox(height: 16),
            _SectionCard(
              titleKey: 'about',
              children: [
                _InfoTile(labelKey: 'app_name', value: Locales.string(context, 'app_name')),
                _InfoTile(labelKey: 'total_surahs', value: '${quran.totalSurahCount}'),
                _InfoTile(labelKey: 'total_ayahs', value: '${quran.totalVerseCount}'),
                _InfoTile(labelKey: 'total_juz', value: '${quran.totalJuzCount}'),
                _InfoTile(labelKey: 'total_pages', value: '${quran.totalPagesCount}'),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              titleKey: 'data',
              children: [
                _InfoTile(labelKey: 'translation', value: Locales.string(context, 'saheeh_international')),
                _InfoTile(labelKey: 'arabic_script', value: Locales.string(context, 'uthmanic_hafs')),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
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
}

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
    final langCode =
        Locales.currentLocale(context)?.languageCode ?? 'en';

    return ThemeSwitcher.withTheme(
      builder: (context, switcher, currentTheme) {
        return GestureDetector(
          onTap: () {
            final newTheme = switch (targetMode) {
              ThemeMode.light => AppTheme.light(langCode),
              ThemeMode.dark => AppTheme.dark(langCode),
              _ => WidgetsBinding
                          .instance.platformDispatcher.platformBrightness ==
                      Brightness.dark
                  ? AppTheme.dark(langCode)
                  : AppTheme.light(langCode),
            };
            switcher.changeTheme(theme: newTheme);
            ref
                .read(appThemeModeProvider.notifier)
                .setThemeMode(targetMode);
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
                    color:
                        isSelected ? colors.gold : colors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
