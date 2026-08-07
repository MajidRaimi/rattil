import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:quran/quran.dart' as quran;

import '../../../core/theme/typography_ext.dart';
import '../../../providers/surah_player_provider.dart';
import 'reciter_picker_sheet.dart';

String _formatDuration(int milliseconds, {bool withHours = false}) {
  final total = (milliseconds / 1000).round();
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  final paddedSeconds = seconds.toString().padLeft(2, '0');

  if (withHours || hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$paddedSeconds';
  }
  return '$minutes:$paddedSeconds';
}

class SurahPlayerBar extends ConsumerWidget {
  const SurahPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = ref.watch(surahPlayerProvider);
    final request = session.request;
    if (request == null) return const SizedBox.shrink();

    final playerState = ref.watch(surahPlayerStateProvider).valueOrNull;
    final reciter = imad.ReciterDataProvider.getReciterById(request.reciterId);
    final isArabic = Locales.currentLocale(context)?.languageCode == 'ar';
    final failed = session.status == SurahLoadStatus.failed;
    final loading =
        session.status == SurahLoadStatus.loading ||
        (playerState?.isBuffering ?? false);
    final playing = playerState?.isPlaying ?? false;
    final positionMs = playerState?.currentPositionMs ?? 0;
    final durationMs = playerState?.durationMs ?? 0;
    final notifier = ref.read(surahPlayerProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? colors.divider.withValues(alpha: 0.5)
              : colors.divider.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _TransportButton(
                  icon: failed
                      ? Icons.refresh_rounded
                      : playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  loading: loading && !failed,
                  onTap: () {
                    if (failed) {
                      notifier.retry();
                    } else if (playing) {
                      notifier.pause();
                    } else {
                      notifier.resume();
                    }
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        request.chapterTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        failed
                            ? Locales.string(context, 'playback_failed')
                            : reciter?.getDisplayName(
                                    languageCode: isArabic ? 'ar' : 'en',
                                  ) ??
                                  Locales.string(context, 'now_playing'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.bodySmall.copyWith(
                          color: failed ? colors.error : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!failed && durationMs > 0)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${_formatDuration(positionMs, withHours: durationMs >= 3600000)}'
                      ' / '
                      '${_formatDuration(durationMs)}',
                      style: typo.bodySmall.copyWith(
                        color: colors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () => notifier.setExpanded(!session.expanded),
                  icon: AnimatedRotation(
                    turns: session.expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 22,
                      color: colors.textTertiary,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            if (!failed && durationMs > 0)
              SizedBox(
                height: 18,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: colors.gold,
                    inactiveTrackColor: colors.divider,
                    thumbColor: colors.gold,
                    overlayColor: colors.gold.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: positionMs.clamp(0, durationMs).toDouble(),
                    max: durationMs.toDouble(),
                    onChanged: (value) => notifier.seekTo(value.round()),
                  ),
                ),
              ),
            if (session.expanded)
              _PlayerSettings(session: session, isArabic: isArabic),
          ],
        ),
      ),
    );
  }
}

class _PlayerSettings extends ConsumerWidget {
  final SurahPlayerSession session;
  final bool isArabic;

  const _PlayerSettings({required this.session, required this.isArabic});

  void _openReciterPicker(BuildContext context, WidgetRef ref) {
    final request = session.request;
    if (request == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: ReciterPickerSheet(
          currentReciterId: request.reciterId,
          surahName: request.chapterTitle,
          onReciterSelected: (reciter) {
            ref.read(selectedReciterIdProvider.notifier).select(reciter.id);
            ref.read(surahPlayerProvider.notifier).changeReciter(reciter.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typography;
    final request = session.request;
    if (request == null) return const SizedBox.shrink();

    final notifier = ref.read(surahPlayerProvider.notifier);
    final reciter = imad.ReciterDataProvider.getReciterById(request.reciterId);
    final verseCount = quran.getVerseCount(request.chapterNumber);
    final range = session.range ?? AyahRange(1, verseCount);

    final labelStyle = typo.bodySmall.copyWith(color: colors.textSecondary);

    void applyRange(int start, int end) {
      final clampedStart = start.clamp(1, verseCount);
      final clampedEnd = end.clamp(clampedStart, verseCount);
      notifier.setRange(AyahRange(clampedStart, clampedEnd));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 12, color: colors.divider.withValues(alpha: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _openReciterPicker(context, ref),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        Locales.string(context, 'tikrar_reciter'),
                        style: labelStyle,
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          reciter?.getDisplayName(
                                languageCode: isArabic ? 'ar' : 'en',
                              ) ??
                              '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typo.bodySmall.copyWith(
                            color: colors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
              if (session.rangeAvailable)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AyahStepper(
                          label: Locales.string(context, 'player_from_ayah'),
                          value: range.start,
                          onChanged: (v) => applyRange(v, range.end),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _AyahStepper(
                          label: Locales.string(context, 'player_to_ayah'),
                          value: range.end,
                          onChanged: (v) => applyRange(range.start, v),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          Locales.string(
                            context,
                            'player_range_unavailable',
                          ),
                          style: typo.bodySmall.copyWith(
                            color: colors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Text(
                      Locales.string(context, 'player_on_finish'),
                      style: labelStyle,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          for (final entry in <(SurahEndBehaviour, String)>[
                            (
                              SurahEndBehaviour.nextSurah,
                              'player_next_surah',
                            ),
                            (SurahEndBehaviour.repeat, 'player_repeat'),
                            (SurahEndBehaviour.stop, 'player_stop'),
                          ])
                            Expanded(
                              child: _BehaviourChip(
                                label: Locales.string(context, entry.$2),
                                selected: session.endBehaviour == entry.$1,
                                onTap: () => notifier.setEndBehaviour(entry.$1),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: notifier.stop,
                icon: Icon(Icons.stop_rounded, size: 18, color: colors.error),
                label: Text(
                  Locales.string(context, 'player_stop_playback'),
                  style: typo.bodySmall.copyWith(color: colors.error),
                ),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AyahStepper extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _AyahStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: typo.bodySmall.copyWith(
            color: colors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              onTap: () => onChanged(value - 1),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: typo.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _StepButton(
              icon: Icons.add_rounded,
              onTap: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.divider.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 30,
          height: 28,
          child: Icon(icon, size: 16, color: colors.textSecondary),
        ),
      ),
    );
  }
}

class _BehaviourChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BehaviourChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected
            ? colors.gold.withValues(alpha: 0.16)
            : colors.divider.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: selected ? colors.gold : Colors.transparent,
                width: 0.8,
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.bodySmall.copyWith(
                fontSize: 11,
                color: selected ? colors.gold : colors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransportButton extends StatelessWidget {
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;

  const _TransportButton({
    required this.icon,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.gold,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: loading
              ? Padding(
                  padding: const EdgeInsets.all(9),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.background,
                  ),
                )
              : Icon(icon, color: colors.background, size: 20),
        ),
      ),
    );
  }
}
