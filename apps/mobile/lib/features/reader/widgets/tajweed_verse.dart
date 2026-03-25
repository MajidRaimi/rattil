import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:qcf_quran_plus/src/data/quran_data.dart';

/// Renders a single verse with tajweed coloring using QCF per-page fonts.
/// Falls back to plain Uthmani text if QCF font fails to load.
class TajweedVerse extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;
  final bool isDark;

  const TajweedVerse({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    this.isDark = false,
  });

  @override
  State<TajweedVerse> createState() => _TajweedVerseState();
}

class _TajweedVerseState extends State<TajweedVerse> {
  bool _qcfReady = false;
  String _qcfText = '';
  String _fallbackText = '';
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadVerse();
  }

  Future<void> _loadVerse() async {
    // Look up verse data
    final verseData = quran.cast<Map<String, dynamic>>().firstWhere(
      (v) => v['sora'] == widget.surahNumber && v['aya_no'] == widget.verseNumber,
      orElse: () => <String, dynamic>{},
    );

    _fallbackText = (verseData['aya_text_emlaey'] as String?) ?? '';
    _qcfText = ((verseData['qcfData'] as String?) ?? '').replaceAll('\n', ' ').trim();
    _page = (verseData['page'] as int?) ?? 1;

    if (_qcfText.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    // Try to load the QCF font for this page
    try {
      await QcfFontLoader.ensureFontLoaded(_page);
      if (mounted) setState(() => _qcfReady = true);
    } catch (_) {
      // Font loading failed — show fallback
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // QCF font loaded — render with tajweed colors
    if (_qcfReady && _qcfText.isNotEmpty) {
      return _buildQcfText();
    }

    // Fallback — plain Uthmani text
    if (_fallbackText.isNotEmpty) {
      return _buildFallbackText();
    }

    return const SizedBox(height: 40);
  }

  Widget _buildQcfText() {
    final style = QuranTextStyles.qcfStyle(
      pageNumber: _page,
      fontSize: 28,
    );

    Widget text = Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        _qcfText,
        style: style,
        textAlign: TextAlign.center,
      ),
    );

    if (widget.isDark) {
      text = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ]),
        child: text,
      );
    }

    return text;
  }

  Widget _buildFallbackText() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        _fallbackText,
        style: TextStyle(
          fontFamily: 'UthmanicHafs',
          fontSize: 26,
          height: 1.8,
          color: widget.isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
