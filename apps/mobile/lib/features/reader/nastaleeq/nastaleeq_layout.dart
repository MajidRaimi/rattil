import 'package:flutter/widgets.dart';

const kNastaleeqOpeningPageCount = 2;
const kNastaleeqPagePadding = EdgeInsets.symmetric(
  horizontal: 22,
  vertical: 16,
);
const kNastaleeqParagraphGap = 6.0;
const kNastaleeqBasmalaGap = 10.0;
const kNastaleeqHeaderOuterV = 14.0;
const kNastaleeqHeaderInnerV = 10.0;
const kNastaleeqHeaderInnerH = 18.0;
const kNastaleeqHeaderBorder = 1.2;
const kNastaleeqPrintedHeaderMarginV = 4.0;
const kNastaleeqDefaultHighlight = Color(0xFFD4A843);

EdgeInsets nastaleeqPagePadding(BuildContext context) =>
    kNastaleeqPagePadding + MediaQuery.paddingOf(context);

bool isNastaleeqOpeningPage(int pageNumber) =>
    pageNumber <= kNastaleeqOpeningPageCount;

sealed class NastaleeqLayoutSpec {
  const NastaleeqLayoutSpec();

  int get pageCount;
}

final class NastaleeqFlowingSpec extends NastaleeqLayoutSpec {
  @override
  final int pageCount;

  const NastaleeqFlowingSpec({required this.pageCount});
}

final class NastaleeqPrintedSpec extends NastaleeqLayoutSpec {
  @override
  final int pageCount;
  final int linesPerPage;
  final int openingPageLines;
  final int closingPageLines;
  final double lineWidthEm;
  final double minSlotEm;

  const NastaleeqPrintedSpec({
    required this.pageCount,
    required this.linesPerPage,
    required this.openingPageLines,
    required this.closingPageLines,
    required this.lineWidthEm,
    required this.minSlotEm,
  });

  int linesOn(int pageNumber) => switch (pageNumber) {
    _ when isNastaleeqOpeningPage(pageNumber) => openingPageLines,
    _ when pageNumber == pageCount => closingPageLines,
    _ => linesPerPage,
  };
}
