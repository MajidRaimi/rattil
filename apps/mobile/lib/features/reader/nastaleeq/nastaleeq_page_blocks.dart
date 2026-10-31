import 'package:imad_flutter/imad_flutter.dart' as imad;

import 'nastaleeq_text.dart';
import 'nastaleeq_verse_ref.dart';

class NastaleeqVerseSpan {
  final int chapter;
  final int number;
  final String text;

  const NastaleeqVerseSpan({
    required this.chapter,
    required this.number,
    required this.text,
  });

  int get key => nastaleeqVerseKey(chapter, number);
}

sealed class NastaleeqPageBlock {
  const NastaleeqPageBlock();
}

final class NastaleeqVerseBlock extends NastaleeqPageBlock {
  final List<NastaleeqVerseSpan> verses;

  const NastaleeqVerseBlock(this.verses);
}

final class NastaleeqHeaderBlock extends NastaleeqPageBlock {
  final String title;

  const NastaleeqHeaderBlock(this.title);
}

final class NastaleeqBasmalaBlock extends NastaleeqPageBlock {
  final String text;

  const NastaleeqBasmalaBlock(this.text);
}

int _compareReadingOrder(imad.PageVerseData a, imad.PageVerseData b) {
  final byChapter = a.chapter.compareTo(b.chapter);
  return byChapter != 0 ? byChapter : a.number.compareTo(b.number);
}

List<NastaleeqPageBlock> buildNastaleeqPageBlocks(
  List<imad.PageVerseData> verses,
  NastaleeqText text,
) {
  final blocks = <NastaleeqPageBlock>[];
  var run = <NastaleeqVerseSpan>[];

  void flush() {
    if (run.isEmpty) return;
    blocks.add(NastaleeqVerseBlock(List.unmodifiable(run)));
    run = [];
  }

  for (final verse in [...verses]..sort(_compareReadingOrder)) {
    if (verse.number == 1) {
      flush();
      blocks.add(NastaleeqHeaderBlock(text.title(verse.chapter)));
      if (nastaleeqOpensWithBasmala(verse.chapter)) {
        blocks.add(NastaleeqBasmalaBlock(text.basmala));
      }
    }
    run.add(
      NastaleeqVerseSpan(
        chapter: verse.chapter,
        number: verse.number,
        text: '${text.verse(verse.chapter, verse.number)} ',
      ),
    );
  }
  flush();
  return blocks;
}
