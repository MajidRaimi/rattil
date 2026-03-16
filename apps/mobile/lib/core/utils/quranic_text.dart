/// Quranic annotation marks (waqf signs, rounded zero, rub el hizb, etc.)
/// that may render as visible glyphs in non-mushaf contexts.
final quranicMarks = RegExp(r'[\u06D6-\u06ED]');

/// Strip Quranic annotation marks from text for display outside the mushaf.
String stripQuranicMarks(String text) => text.replaceAll(quranicMarks, '');
