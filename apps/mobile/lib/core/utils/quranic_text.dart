/// Quranic annotation marks (waqf signs, rounded zero, rub el hizb, etc.)
/// that may render as visible glyphs in non-mushaf contexts.
final quranicMarks = RegExp(r'[\u06D6-\u06ED]');

/// Strip Quranic annotation marks from text for display outside the mushaf.
String stripQuranicMarks(String text) => text.replaceAll(quranicMarks, '');

/// Normalize Arabic text for comparison (strip diacritics, unify letter forms).
String normalizeArabicForComparison(String text) {
  var r = text;
  // Strip all diacritics, Quranic marks, and annotation characters
  r = r.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0600-\u0605\u0890-\u0891\u08E2\uFD3E\uFD3F]'), '');
  // Normalize alef variants → ا
  r = r.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
  // Normalize taa marbuta → ه
  r = r.replaceAll('ة', 'ه');
  // Normalize alef maqsura → ي
  r = r.replaceAll('ى', 'ي');
  // Remove tatweel
  r = r.replaceAll('\u0640', '');
  return r;
}

/// Split Arabic text into words, filtering out empty/marker-only tokens.
List<String> splitArabicWords(String text) {
  // Strip Quranic marks and annotation characters before splitting
  final cleaned = text
      .replaceAll(quranicMarks, '')
      .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0600-\u0605\u0890-\u0891\u08E2\uFD3E\uFD3F]'), '');
  return cleaned.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
}

/// Levenshtein edit distance between two strings.
int _editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final prev = List<int>.generate(b.length + 1, (i) => i);
  final curr = List<int>.filled(b.length + 1, 0);

  for (int i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (int j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      curr[j] = [
        curr[j - 1] + 1,
        prev[j] + 1,
        prev[j - 1] + cost,
      ].reduce((a, b) => a < b ? a : b);
    }
    prev.setAll(0, curr);
  }
  return curr[b.length];
}

/// Check if two Arabic words are a fuzzy match.
/// Allows up to 1 character difference for short words, 2 for longer words.
bool fuzzyMatchArabic(String a, String b) => _fuzzyMatch(a, b);

bool _fuzzyMatch(String a, String b) {
  if (a == b) return true;
  final maxDist = a.length <= 3 ? 1 : 2;
  return _editDistance(a, b) <= maxDist;
}

/// Count consecutive matching words from the start (with fuzzy matching).
int countMatchingWords(List<String> expected, List<String> transcribed) {
  int matched = 0;
  final limit = expected.length < transcribed.length
      ? expected.length
      : transcribed.length;
  for (int i = 0; i < limit; i++) {
    final e = normalizeArabicForComparison(expected[i]);
    final t = normalizeArabicForComparison(transcribed[i]);
    if (_fuzzyMatch(e, t)) {
      matched++;
    } else {
      break;
    }
  }
  return matched;
}

enum WordMatch { correct, wrong }

/// Compare transcribed words against a portion of expected words (for partial recitation).
/// Returns (matchedCount, failedWordIndex). failedIndex is null if all matched.
(int, int?) comparePartial({
  required List<String> expectedWords,
  required List<String> transcribedWords,
  required int startOffset,
}) {
  int matched = 0;
  final remaining = expectedWords.length - startOffset;
  final limit = remaining < transcribedWords.length
      ? remaining
      : transcribedWords.length;

  for (int i = 0; i < limit; i++) {
    final e = normalizeArabicForComparison(expectedWords[startOffset + i]);
    final t = normalizeArabicForComparison(transcribedWords[i]);
    if (_fuzzyMatch(e, t)) {
      matched++;
    } else {
      return (matched, startOffset + i);
    }
  }
  return (matched, null);
}

class VerseMatchResult {
  final int ayahIndex;
  final List<WordMatch> wordMatches;
  final bool allCorrect;

  VerseMatchResult({required this.ayahIndex, required this.wordMatches})
      : allCorrect = wordMatches.every((m) => m == WordMatch.correct);
}

/// Compare transcribed text against one or more expected verses.
/// Supports multi-verse recitation — matches words sequentially across verses.
List<VerseMatchResult> compareTranscription({
  required List<List<String>> expectedVerses,
  required List<String> transcribedWords,
  required List<int> ayahIndices,
}) {
  final results = <VerseMatchResult>[];
  int tIdx = 0;

  for (int v = 0; v < expectedVerses.length; v++) {
    final expected = expectedVerses[v];
    final matches = <WordMatch>[];

    for (int w = 0; w < expected.length; w++) {
      if (tIdx < transcribedWords.length) {
        final e = normalizeArabicForComparison(expected[w]);
        final t = normalizeArabicForComparison(transcribedWords[tIdx]);
        matches.add(_fuzzyMatch(e, t) ? WordMatch.correct : WordMatch.wrong);
        tIdx++;
      } else {
        matches.add(WordMatch.wrong);
      }
    }

    results.add(VerseMatchResult(
      ayahIndex: ayahIndices[v],
      wordMatches: matches,
    ));

    // Stop processing more verses if this one had errors
    if (!results.last.allCorrect) break;
    // Stop if no more transcribed words to match against
    if (tIdx >= transcribedWords.length) break;
  }

  return results;
}
