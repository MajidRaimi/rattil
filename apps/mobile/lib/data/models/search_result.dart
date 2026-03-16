class SearchResultItem {
  final int surahNumber;
  final int ayahNumber;
  final String textUthmani;
  final String nameArabic;
  final String nameEnglish;
  final String? translation;

  const SearchResultItem({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textUthmani,
    required this.nameArabic,
    required this.nameEnglish,
    this.translation,
  });
}
