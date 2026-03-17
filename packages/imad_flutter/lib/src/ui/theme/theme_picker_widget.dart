import 'package:flutter/material.dart';

import '../../di/core_module.dart';
import '../../domain/repository/preferences_repository.dart';
import 'mushaf_theme_scope.dart';
import 'reading_theme.dart';
import 'theme_view_model.dart';

/// A visual theme picker widget for selecting Mushaf reading themes.
///
/// Displays a grid of theme preview cards (Light, Dark, Sepia, Warm Dark)
/// with Arabic sample text and an AMOLED toggle. Uses [ThemeViewModel].
///
/// When a [MushafThemeScope] ancestor exists, this widget automatically
/// reads the initial theme from and writes changes to the scope, so the
/// [MushafPageView] reflects the selection immediately.
class ThemePickerWidget extends StatefulWidget {
  /// Called when the theme changes, providing the new [ReadingTheme].
  final ValueChanged<ReadingTheme>? onThemeChanged;

  const ThemePickerWidget({super.key, this.onThemeChanged});

  @override
  State<ThemePickerWidget> createState() => _ThemePickerWidgetState();
}

class _ThemePickerWidgetState extends State<ThemePickerWidget> {
  late final ThemeViewModel _viewModel;
  ReadingTheme _selectedTheme = ReadingTheme.light;

  @override
  void initState() {
    super.initState();
    _viewModel = ThemeViewModel(
      preferencesRepository: mushafGetIt<PreferencesRepository>(),
    );
    _viewModel.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read initial theme from scope if available
    final scopeNotifier = MushafThemeScope.maybeOf(context);
    if (scopeNotifier != null && _selectedTheme != scopeNotifier.readingTheme) {
      _selectedTheme = scopeNotifier.readingTheme;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _selectTheme(ReadingTheme theme) {
    setState(() => _selectedTheme = theme);

    // Update the scope so MushafPageView picks up the change
    MushafThemeScope.maybeOf(context)?.setTheme(theme);

    // Also notify the callback
    widget.onThemeChanged?.call(theme);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme grid
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: ReadingTheme.values.map((theme) {
                final themeData = ReadingThemeData.fromTheme(theme);
                final isSelected = _selectedTheme == theme;
                return _ThemeCard(
                  theme: theme,
                  themeData: themeData,
                  isSelected: isSelected,
                  onTap: () => _selectTheme(theme),
                );
              }).toList(),
            ),

            // AMOLED toggle
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('AMOLED Mode'),
                subtitle: const Text('Pure black for OLED screens'),
                secondary: const Icon(Icons.brightness_2_rounded),
                value: _viewModel.useAmoled,
                onChanged: (value) {
                  _viewModel.setAmoledMode(value);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme Preview Card
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  final ReadingTheme theme;
  final ReadingThemeData themeData;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.themeData,
    required this.isSelected,
    required this.onTap,
  });

  String get _themeName {
    switch (theme) {
      case ReadingTheme.light:
        return 'Light';
      case ReadingTheme.dark:
        return 'Dark';
      case ReadingTheme.sepia:
        return 'Sepia';
      case ReadingTheme.warmDark:
        return 'Warm Dark';
    }
  }

  IconData get _themeIcon {
    switch (theme) {
      case ReadingTheme.light:
        return Icons.wb_sunny_rounded;
      case ReadingTheme.dark:
        return Icons.dark_mode_rounded;
      case ReadingTheme.sepia:
        return Icons.auto_stories_rounded;
      case ReadingTheme.warmDark:
        return Icons.nightlight_round;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: themeData.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? appTheme.colorScheme.primary
                : Colors.transparent,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Theme content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and name
                  Row(
                    children: [
                      Icon(_themeIcon, size: 18, color: themeData.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        _themeName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: themeData.textColor,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Arabic sample text
                  Text(
                    'بِسْمِ اللَّهِ',
                    style: TextStyle(
                      fontSize: 18,
                      color: themeData.textColor,
                      fontFamily: 'serif',
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    'الرَّحْمَنِ الرَّحِيمِ',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeData.secondaryTextColor,
                      fontFamily: 'serif',
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            // Selected checkmark
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: appTheme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
