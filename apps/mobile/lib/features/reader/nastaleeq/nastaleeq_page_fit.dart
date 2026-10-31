import 'package:flutter/painting.dart';

import 'nastaleeq_edition.dart';
import 'nastaleeq_layout.dart';
import 'nastaleeq_page_blocks.dart';
import 'nastaleeq_typography.dart';

const _kMinFontSize = 9.0;
const _kMaxFontSize = 40.0;
const _kFitIterations = 16;
const _kFitSafety = 2.0;
const _kProbeColor = Color(0xFF000000);

const _kHeaderChrome =
    kNastaleeqHeaderOuterV * 2 +
    kNastaleeqHeaderInnerV * 2 +
    kNastaleeqHeaderBorder * 2;
const _kHeaderInset = kNastaleeqHeaderInnerH * 2 + kNastaleeqHeaderBorder * 2;

class NastaleeqFitRequest {
  final int pageNumber;
  final NastaleeqEdition edition;
  final List<NastaleeqPageBlock> blocks;
  final double maxWidth;
  final double maxHeight;
  final TextScaler scaler;
  final TextStyle base;
  final TextHeightBehavior? heightBehavior;

  const NastaleeqFitRequest({
    required this.pageNumber,
    required this.edition,
    required this.blocks,
    required this.maxWidth,
    required this.maxHeight,
    required this.scaler,
    required this.base,
    required this.heightBehavior,
  });

  String get cacheKey =>
      '${edition.name}:$pageNumber:${maxWidth.round()}:${maxHeight.round()}:'
      '${scaler.scale(100).round()}';
}

double _layoutHeight(
  InlineSpan text,
  double maxWidth,
  TextScaler scaler,
  TextHeightBehavior? heightBehavior, {
  StrutStyle? strutStyle,
}) {
  final painter = TextPainter(
    text: text,
    textDirection: TextDirection.rtl,
    textScaler: scaler,
    textHeightBehavior: heightBehavior,
    strutStyle: strutStyle,
  )..layout(maxWidth: maxWidth);
  final height = painter.height;
  painter.dispose();
  return height;
}

double _measureBlock(
  NastaleeqPageBlock block,
  NastaleeqTypography typography,
  NastaleeqFitRequest request,
) => switch (block) {
  NastaleeqVerseBlock(:final verses) =>
    _layoutHeight(
          buildNastaleeqParagraphSpan(verses, typography.body(_kProbeColor)),
          request.maxWidth,
          request.scaler,
          kNastaleeqParagraphHeightBehavior,
          strutStyle: typography.paragraphStrut,
        ) +
        kNastaleeqParagraphGap,
  NastaleeqHeaderBlock(:final title) =>
    _layoutHeight(
          TextSpan(text: title, style: typography.header(_kProbeColor)),
          request.maxWidth - _kHeaderInset,
          request.scaler,
          request.heightBehavior,
        ) +
        _kHeaderChrome,
  NastaleeqBasmalaBlock(:final text) =>
    _layoutHeight(
          TextSpan(text: text, style: typography.basmala(_kProbeColor)),
          request.maxWidth,
          request.scaler,
          request.heightBehavior,
        ) +
        kNastaleeqBasmalaGap,
};

double _measurePage(NastaleeqFitRequest request, double fontSize) {
  final typography = NastaleeqTypography(
    edition: request.edition,
    base: request.base,
    fontSize: fontSize,
  );
  return request.blocks.fold(
    0.0,
    (total, block) => total + _measureBlock(block, typography, request),
  );
}

final Map<String, double> _fitCache = {};

double fitNastaleeqFontSize(NastaleeqFitRequest request) {
  if (request.maxWidth <= 0 || request.maxHeight <= 0) return _kMinFontSize;
  final key = request.cacheKey;
  final cached = _fitCache[key];
  if (cached != null) return cached;
  final fitted = _searchFontSize(request);
  _fitCache[key] = fitted;
  return fitted;
}

double _searchFontSize(NastaleeqFitRequest request) {
  final budget = request.maxHeight - _kFitSafety;
  if (_measurePage(request, _kMaxFontSize) <= budget) return _kMaxFontSize;
  var low = _kMinFontSize;
  var high = _kMaxFontSize;
  for (var i = 0; i < _kFitIterations; i++) {
    final mid = (low + high) / 2;
    if (_measurePage(request, mid) <= budget) {
      low = mid;
    } else {
      high = mid;
    }
  }
  return low;
}
