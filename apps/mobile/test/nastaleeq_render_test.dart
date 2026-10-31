import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:quran/quran.dart' as quran;
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_edition.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_page.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_page_map.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_page_view.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_printed_fit.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_printed_line.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_printed_page.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_text_provider.dart';

import 'support/nastaleeq_test_support.dart';

const bool captureGoldens = bool.fromEnvironment('NASTALEEQ_GOLDENS');

const List<int> sampledMadinahPages = [
  1,
  2,
  3,
  7,
  42,
  48,
  176,
  187,
  296,
  331,
  341,
  418,
  443,
  604,
];

const List<int> sampledPrintedPages = [
  1,
  2,
  3,
  6,
  50,
  76,
  151,
  253,
  293,
  341,
  349,
  369,
  573,
  590,
  604,
  610,
];

const List<int> resumedPrintedPages = [3, 23, 383];

const List<int> driftingPrintedPages = [3, 4, 23, 28];

const Key captureKey = ValueKey('nastaleeq-capture');
const double edgeTolerance = 0.5;

const Size iphone17ProLogicalSize = Size(402, 874);
const double iphone17ProPixelRatio = 3;

void configureIphone17Pro(WidgetTester tester) {
  tester.view
    ..devicePixelRatio = iphone17ProPixelRatio
    ..physicalSize = iphone17ProLogicalSize * iphone17ProPixelRatio
    ..padding = const FakeViewPadding(
      top: 62 * iphone17ProPixelRatio,
      bottom: 34 * iphone17ProPixelRatio,
    );
  addTearDown(tester.view.reset);
}

Finder flowingPageFinder(int pageNumber) => find.byWidgetPredicate(
  (widget) => widget is NastaleeqPage && widget.pageNumber == pageNumber,
);

Finder printedPageFinder(int pageNumber) => find.byWidgetPredicate(
  (widget) => widget is NastaleeqPrintedPage && widget.pageNumber == pageNumber,
);

double pageScaleFactor(WidgetTester tester, Finder page) {
  final fitted = find.descendant(of: page, matching: find.byType(FittedBox));
  final column = find.descendant(of: fitted, matching: find.byType(Column));
  final fittedBox = tester.renderObject<RenderBox>(fitted);
  final columnBox = tester.renderObject<RenderBox>(column.first);
  return fittedBox.size.width / columnBox.size.width;
}

void expectPrintedLinesFit(WidgetTester tester, Finder page) {
  final lineFinder = find.descendant(
    of: page,
    matching: find.byType(NastaleeqPrintedLine),
  );
  final lines = tester.widgetList<NastaleeqPrintedLine>(lineFinder).toList();
  final slotHeights = <double>{};
  for (final (index, line) in lines.indexed) {
    final slot = tester.getSize(lineFinder.at(index));
    slotHeights.add(slot.height);
    if (line.plan case NastaleeqVersesPlan(:final fit)) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: lineFinder.at(index),
          matching: find.byType(RichText),
        ),
      );
      final width = paragraph.getMaxIntrinsicWidth(double.infinity);
      expect(width, lessThanOrEqualTo(slot.width + edgeTolerance));
      expect(paragraph.textSize.height, lessThanOrEqualTo(slot.height));
      if (fit.justified) {
        expect(width, closeTo(slot.width, edgeTolerance));
      }
    }
  }
  expect(slotHeights, hasLength(1));
}

Future<void> writeHighResolutionCapture(
  WidgetTester tester,
  String path,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: iphone17ProPixelRatio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  });
}

Future<void> captureGolden(WidgetTester tester, String name) async {
  if (!captureGoldens) return;
  await writeHighResolutionCapture(
    tester,
    'test/goldens/nastaleeq/$name@3x.png',
  );
  await expectLater(
    find.byKey(captureKey),
    matchesGoldenFile('goldens/nastaleeq/$name.png'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late NastaleeqPageMap printedMap;

  setUpAll(() async {
    await loadNastaleeqFonts();
    await imad.VerseDataProvider.instance.initialize();
    container = ProviderContainer();
    for (final edition in NastaleeqEdition.values) {
      await container.read(nastaleeqTextProvider(edition).future);
    }
    printedMap = container
        .read(nastaleeqTextProvider(NastaleeqEdition.digitalKhatt))
        .requireValue
        .pageMap;
  });

  tearDownAll(() => container.dispose());

  Future<void> pumpReader(
    WidgetTester tester, {
    required NastaleeqEdition edition,
    int initialPage = 1,
    ValueChanged<int>? onPageChanged,
    void Function(int chapter, int verse)? onVerseLongPress,
  }) async {
    configureIphone17Pro(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: RepaintBoundary(
              key: captureKey,
              child: NastaleeqPageView(
                edition: edition,
                initialPage: initialPage,
                onPageChanged: onPageChanged,
                onVerseLongPress: onVerseLongPress,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  NastaleeqPageViewState readerState(WidgetTester tester) =>
      tester.state<NastaleeqPageViewState>(find.byType(NastaleeqPageView));

  Future<void> openPrintedPage(WidgetTester tester, int pageNumber) async {
    readerState(tester).revealVerse(printedMap.anchorVerseOf(pageNumber));
    await tester.pump();
    await tester.pump();
  }

  for (final pageNumber in sampledMadinahPages) {
    testWidgets('kfgqpc page $pageNumber fits without overflow', (
      tester,
    ) async {
      await pumpReader(
        tester,
        edition: NastaleeqEdition.kfgqpc,
        initialPage: pageNumber,
      );
      final page = flowingPageFinder(pageNumber);
      expect(page, findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(pageScaleFactor(tester, page), closeTo(1, 0.001));
      await captureGolden(tester, 'kfgqpc/page-$pageNumber');
    });
  }

  for (final pageNumber in sampledPrintedPages) {
    testWidgets('digitalKhatt printed page $pageNumber justifies every line', (
      tester,
    ) async {
      await pumpReader(tester, edition: NastaleeqEdition.digitalKhatt);
      await openPrintedPage(tester, pageNumber);
      final page = printedPageFinder(pageNumber);
      expect(page, findsOneWidget);
      expect(tester.takeException(), isNull);
      expectPrintedLinesFit(tester, page);
      await captureGolden(tester, 'digitalKhatt/page-$pageNumber');
    });
  }

  testWidgets('digitalKhatt highlights a selected verse as one band', (
    tester,
  ) async {
    await pumpReader(tester, edition: NastaleeqEdition.digitalKhatt);
    readerState(tester).goToPage(6, highlightVerseKey: 2031);
    await tester.pump();
    await tester.pump();
    expect(printedPageFinder(6), findsOneWidget);
    expect(tester.takeException(), isNull);
    await captureGolden(tester, 'digitalKhatt/page-6-selected');
  });

  testWidgets('digitalKhatt long press picks the verse under the finger', (
    tester,
  ) async {
    final pressed = <int>[];
    await pumpReader(
      tester,
      edition: NastaleeqEdition.digitalKhatt,
      onVerseLongPress: (chapter, verse) =>
          pressed.add(nastaleeqVerseKey(chapter, verse)),
    );
    await openPrintedPage(tester, 6);
    final thirdLine = find
        .descendant(
          of: printedPageFinder(6),
          matching: find.byType(NastaleeqPrintedLine),
        )
        .at(2);
    final rect = tester.getRect(thirdLine);
    await tester.longPressAt(rect.centerRight.translate(-8, 0));
    await tester.longPressAt(rect.centerLeft.translate(8, 0));
    expect(pressed, [2030, 2031]);
  });

  Widget resumedReader(int initialPage, int initialVerseKey) =>
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: NastaleeqPageView(
            edition: NastaleeqEdition.digitalKhatt,
            initialPage: initialPage,
            initialVerseKey: initialVerseKey,
          ),
        ),
      );

  for (final pageNumber in resumedPrintedPages) {
    testWidgets('resumes printed page $pageNumber from its saved verse', (
      tester,
    ) async {
      final verseKey = printedMap.anchorVerseOf(pageNumber);
      configureIphone17Pro(tester);
      await tester.pumpWidget(
        resumedReader(
          quran.getPageNumber(
            nastaleeqVerseChapter(verseKey),
            nastaleeqVerseNumber(verseKey),
          ),
          verseKey,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(printedPageFinder(pageNumber), findsOneWidget);
    });
  }

  testWidgets('ignores a saved verse that is not on the initial page', (
    tester,
  ) async {
    configureIphone17Pro(tester);
    await tester.pumpWidget(
      resumedReader(7, printedMap.anchorVerseOf(resumedPrintedPages.first)),
    );
    await tester.pump();
    await tester.pump();
    final expected = printedMap.pageOfVerse(nastaleeqMadinahPageStart(7));
    expect(printedPageFinder(expected), findsOneWidget);
  });

  testWidgets('switching editions keeps the reader on the same verse', (
    tester,
  ) async {
    final reported = <int>[];
    Widget reader(NastaleeqEdition edition) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: NastaleeqPageView(edition: edition, onPageChanged: reported.add),
      ),
    );
    configureIphone17Pro(tester);
    await tester.pumpWidget(reader(NastaleeqEdition.digitalKhatt));
    await tester.pump();
    await tester.pump();
    readerState(tester).revealVerse(printedMap.anchorVerseOf(6));
    await tester.pump();
    expect(printedPageFinder(6), findsOneWidget);

    await tester.pumpWidget(reader(NastaleeqEdition.kfgqpc));
    await tester.pump();
    await tester.pump();
    expect(flowingPageFinder(6), findsOneWidget);
    expect(reported.last, 6);

    readerState(tester).goToPage(7);
    await tester.pump();
    await tester.pumpWidget(reader(NastaleeqEdition.digitalKhatt));
    await tester.pump();
    await tester.pump();
    final expected = printedMap.pageOfVerse(nastaleeqMadinahPageStart(7));
    expect(printedPageFinder(expected), findsOneWidget);
    expect(reported.last, 7);
  });

  for (final pageNumber in driftingPrintedPages) {
    testWidgets('round trips printed page $pageNumber through KFGQPC', (
      tester,
    ) async {
      Widget reader(NastaleeqEdition edition) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: NastaleeqPageView(edition: edition)),
      );
      configureIphone17Pro(tester);
      await tester.pumpWidget(reader(NastaleeqEdition.digitalKhatt));
      await tester.pump();
      await tester.pump();
      await openPrintedPage(tester, pageNumber);
      for (var round = 0; round < 3; round++) {
        await tester.pumpWidget(reader(NastaleeqEdition.kfgqpc));
        await tester.pump();
        await tester.pump();
        await tester.pumpWidget(reader(NastaleeqEdition.digitalKhatt));
        await tester.pump();
        await tester.pump();
        expect(printedPageFinder(pageNumber), findsOneWidget);
      }
    });
  }

  testWidgets('opens every surah on the page that shows its first verse', (
    tester,
  ) async {
    await pumpReader(
      tester,
      edition: NastaleeqEdition.digitalKhatt,
      initialPage: quran.totalPagesCount,
    );
    for (var chapter = 1; chapter <= 114; chapter++) {
      final verseKey = nastaleeqVerseKey(chapter, 1);
      readerState(
        tester,
      ).goToPage(quran.getPageNumber(chapter, 1), targetVerseKey: verseKey);
      await tester.pump();
      expect(
        printedPageFinder(printedMap.pageOfVerse(verseKey)),
        findsOneWidget,
        reason: 'surah $chapter',
      );
      expect(readerState(tester).anchorVerseKey, verseKey);
    }
  });
}
