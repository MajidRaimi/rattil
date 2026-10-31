import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_ext.dart';
import '../../data/services/analytics_service.dart';
import '../../providers/display_design_provider.dart';
import '../../providers/mushaf_script_provider.dart';

class DisplayDesignScreen extends ConsumerWidget {
  const DisplayDesignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;
    final mode = ref.watch(displayDesignModeProvider);
    final script = ref.watch(mushafScriptModeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
        ),
        title: Text(
          Locales.string(context, 'display_design'),
          style: typo.titleMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 8),
          Text(
            Locales.string(context, 'display_design_desc'),
            style: typo.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _OptionCard(
            children: [
              _DisplayModeRow(
                icon: Icons.fullscreen_rounded,
                titleKey: 'display_immersive',
                descKey: 'display_immersive_desc',
                mode: ReaderDisplayMode.immersive,
                isSelected: mode == ReaderDisplayMode.immersive,
              ),
              _OptionDivider(),
              _DisplayModeRow(
                icon: Icons.push_pin_outlined,
                titleKey: 'display_always_visible',
                descKey: 'display_always_visible_desc',
                mode: ReaderDisplayMode.alwaysVisible,
                isSelected: mode == ReaderDisplayMode.alwaysVisible,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            Locales.string(context, 'mushaf_script'),
            style: typo.titleMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Locales.string(context, 'mushaf_script_desc'),
            style: typo.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _OptionCard(
            children: [
              _ScriptRow(
                icon: Icons.menu_book_rounded,
                titleKey: 'script_madinah',
                descKey: 'script_madinah_desc',
                script: MushafScript.madinah,
                isSelected: script == MushafScript.madinah,
              ),
              _OptionDivider(),
              _ScriptRow(
                icon: Icons.brush_rounded,
                titleKey: 'script_nastaleeq',
                descKey: 'script_nastaleeq_desc',
                script: MushafScript.nastaleeq,
                isSelected: script == MushafScript.nastaleeq,
              ),
              _OptionDivider(),
              _ScriptRow(
                icon: Icons.account_balance_rounded,
                titleKey: 'script_nastaleeq_kfgqpc',
                descKey: 'script_nastaleeq_kfgqpc_desc',
                script: MushafScript.nastaleeqKfgqpc,
                isSelected: script == MushafScript.nastaleeqKfgqpc,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final List<Widget> children;

  const _OptionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _OptionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: context.colors.divider,
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.isSelected,
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
            Icon(
              icon,
              color: isSelected ? colors.gold : colors.textTertiary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Locales.string(context, titleKey),
                    style: typo.bodyLarge.copyWith(
                      color: isSelected ? colors.gold : colors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Locales.string(context, descKey),
                    style: typo.bodySmall.copyWith(
                      color: colors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                key: ValueKey(isSelected),
                color: isSelected ? colors.gold : colors.textTertiary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisplayModeRow extends ConsumerWidget {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final ReaderDisplayMode mode;
  final bool isSelected;

  const _DisplayModeRow({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.mode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OptionRow(
      icon: icon,
      titleKey: titleKey,
      descKey: descKey,
      isSelected: isSelected,
      onTap: () {
        ref.read(displayDesignModeProvider.notifier).setMode(mode);
        AnalyticsService.event('Display Design Changed',
            props: {'to': mode.name});
      },
    );
  }
}

class _ScriptRow extends ConsumerWidget {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final MushafScript script;
  final bool isSelected;

  const _ScriptRow({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.script,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _OptionRow(
      icon: icon,
      titleKey: titleKey,
      descKey: descKey,
      isSelected: isSelected,
      onTap: () {
        ref.read(mushafScriptModeProvider.notifier).setScript(script);
        AnalyticsService.event('Mushaf Script Changed',
            props: {'to': script.name});
      },
    );
  }
}
