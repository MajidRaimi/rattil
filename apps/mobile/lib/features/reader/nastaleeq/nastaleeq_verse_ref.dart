import '../../../core/constants/quran_constants.dart';

const _kVerseKeyBase = 1000;

int nastaleeqVerseKey(int chapter, int number) =>
    chapter * _kVerseKeyBase + number;

int nastaleeqVerseChapter(int verseKey) => verseKey ~/ _kVerseKeyBase;

int nastaleeqVerseNumber(int verseKey) => verseKey % _kVerseKeyBase;

bool nastaleeqOpensWithBasmala(int chapter) =>
    chapter != QuranConstants.bismillahSurah &&
    chapter != QuranConstants.tawbahSurah;
