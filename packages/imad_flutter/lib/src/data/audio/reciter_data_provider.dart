import '../../domain/models/reciter_info.dart';

class ReciterDataProvider {
  ReciterDataProvider._();

  static const Set<int> bundledTimingIds = {
    1, 5, 9, 10, 31, 32, 51, 53, 60, 62, 67, 74, 78, 106, 112, 118, 159, 256,
  };

  static const List<ReciterInfo> allReciters = [
    ReciterInfo(
      id: 123,
      nameArabic: 'مشاري العفاسي',
      nameEnglish: 'Mishary Rashid Al-Afasy',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server8.mp3quran.net/afs/',
    ),
    ReciterInfo(
      id: 54,
      nameArabic: 'عبدالرحمن السديس',
      nameEnglish: 'Abdul Rahman Al-Sudais',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server11.mp3quran.net/sds/',
    ),
    ReciterInfo(
      id: 112,
      nameArabic: 'محمد صديق المنشاوي',
      nameEnglish: 'Mohammed Siddiq Al-Minshawi',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server10.mp3quran.net/minsh/',
    ),
    ReciterInfo(
      id: 118,
      nameArabic: 'محمود خليل الحصري',
      nameEnglish: 'Mahmoud Khalil Al-Hussary',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server13.mp3quran.net/husr/',
    ),
    ReciterInfo(
      id: 51,
      nameArabic: 'عبدالباسط عبدالصمد',
      nameEnglish: 'Abdul Basit Abdul Samad (Mujawwad)',
      rewaya: 'المصحف المجود',
      folderUrl: 'https://server7.mp3quran.net/basit/Almusshaf-Al-Mojawwad/',
    ),
    ReciterInfo(
      id: 53,
      nameArabic: 'عبدالباسط عبدالصمد',
      nameEnglish: 'Abdul Basit Abdul Samad',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server7.mp3quran.net/basit/',
    ),
    ReciterInfo(
      id: 133,
      nameArabic: 'ماهر المعيقلي',
      nameEnglish: 'Maher Al-Muaiqly (Mujawwad)',
      rewaya: 'المصحف المجود',
      folderUrl: 'https://server12.mp3quran.net/maher/Almusshaf-Al-Mojawwad/',
    ),
    ReciterInfo(
      id: 30,
      nameArabic: 'سعد الغامدي',
      nameEnglish: 'Saad Al-Ghamdi',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server7.mp3quran.net/s_gmd/',
    ),
    ReciterInfo(
      id: 31,
      nameArabic: 'سعود الشريم',
      nameEnglish: 'Saud Al-Shuraim',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server7.mp3quran.net/shur/',
    ),
    ReciterInfo(
      id: 92,
      nameArabic: 'ياسر الدوسري',
      nameEnglish: 'Yasser Al-Dosari',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server11.mp3quran.net/yasser/',
    ),
    ReciterInfo(
      id: 4,
      nameArabic: 'شيخ أبو بكر الشاطري',
      nameEnglish: 'Abu Bakr Al-Shatri',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server11.mp3quran.net/shatri/',
    ),
    ReciterInfo(
      id: 62,
      nameArabic: 'عبدالله عواد الجهني',
      nameEnglish: 'Abdullah Awad Al-Juhani',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server13.mp3quran.net/jhn/',
    ),
    ReciterInfo(
      id: 217,
      nameArabic: 'بندر بليله',
      nameEnglish: 'Bandar Baleela',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server6.mp3quran.net/balilah/',
    ),
    ReciterInfo(
      id: 221,
      nameArabic: 'رعد محمد الكردي',
      nameEnglish: 'Raad Muhammad Al-Kurdi',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server6.mp3quran.net/kurdi/',
    ),
    ReciterInfo(
      id: 81,
      nameArabic: 'فارس عباد',
      nameEnglish: 'Fares Abbad',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server8.mp3quran.net/frs_a/',
    ),
    ReciterInfo(
      id: 12,
      nameArabic: 'إدريس أبكر',
      nameEnglish: 'Idris Abkar',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server6.mp3quran.net/abkr/',
    ),
    ReciterInfo(
      id: 5,
      nameArabic: 'أحمد بن علي العجمي',
      nameEnglish: 'Ahmad Al-Ajmy',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server10.mp3quran.net/ajm/',
    ),
    ReciterInfo(
      id: 67,
      nameArabic: 'عبدالمحسن القاسم',
      nameEnglish: 'Abdul Mohsen Al-Qasim',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server8.mp3quran.net/qasm/',
    ),
    ReciterInfo(
      id: 74,
      nameArabic: 'علي بن عبدالرحمن الحذيفي',
      nameEnglish: 'Ali Al-Hudhaify',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server9.mp3quran.net/hthfi/',
    ),
    ReciterInfo(
      id: 60,
      nameArabic: 'عبدالله بصفر',
      nameEnglish: 'Abdullah Basfar',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server6.mp3quran.net/bsfr/',
    ),
    ReciterInfo(
      id: 1,
      nameArabic: 'إبراهيم الأخضر',
      nameEnglish: 'Ibrahim Al-Akhdar',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server6.mp3quran.net/akdr/',
    ),
    ReciterInfo(
      id: 9,
      nameArabic: 'أحمد نعينع',
      nameEnglish: 'Ahmad Nauina',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server11.mp3quran.net/ahmad_nu/',
    ),
    ReciterInfo(
      id: 10,
      nameArabic: 'أكرم العلاقمي',
      nameEnglish: 'Akram Al-Alaqmi',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server9.mp3quran.net/akrm/',
    ),
    ReciterInfo(
      id: 32,
      nameArabic: 'سهل ياسين',
      nameEnglish: 'Sahl Yassin',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server6.mp3quran.net/shl/',
    ),
    ReciterInfo(
      id: 78,
      nameArabic: 'عماد زهير حافظ',
      nameEnglish: 'Emad Zuhair Hafez',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server6.mp3quran.net/hafz/',
    ),
    ReciterInfo(
      id: 106,
      nameArabic: 'محمد الطبلاوي',
      nameEnglish: 'Mohammad Al-Tablawi',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server12.mp3quran.net/tblawi/',
    ),
    ReciterInfo(
      id: 159,
      nameArabic: 'خالد المهنا',
      nameEnglish: 'Khalid Al-Muhanna',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server11.mp3quran.net/mohna/',
    ),
    ReciterInfo(
      id: 256,
      nameArabic: 'أحمد خليل شاهين',
      nameEnglish: 'Ahmad Khalil Shaheen',
      rewaya: 'حفص عن عاصم',
      folderUrl: 'https://server16.mp3quran.net/shaheen/Rewayat-Hafs-A-n-Assem/',
    ),
  ];

  /// Reciters discovered at runtime through the mp3quran catalogue. Registered
  /// by the host app before playback so [getReciterById] can resolve them.
  static final List<ReciterInfo> remoteReciters = [];

  static void registerRemote(ReciterInfo reciter) {
    if (getReciterById(reciter.id) != null) return;
    remoteReciters.add(reciter);
  }

  static ReciterInfo? getReciterById(int reciterId) {
    for (final reciter in allReciters) {
      if (reciter.id == reciterId) return reciter;
    }
    for (final reciter in remoteReciters) {
      if (reciter.id == reciterId) return reciter;
    }
    return null;
  }

  static List<int> getAllReciterIds() =>
      allReciters.map((r) => r.id).toList();

  static List<ReciterInfo> searchReciters(
    String query, {
    String languageCode = 'en',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return allReciters;
    return allReciters.where((reciter) {
      return reciter.nameArabic.toLowerCase().contains(normalizedQuery) ||
          reciter.nameEnglish.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  static List<ReciterInfo> getRecitersByRewaya(String rewaya) {
    final normalizedRewaya = rewaya.trim().toLowerCase();
    return allReciters
        .where((r) => r.rewaya.toLowerCase().contains(normalizedRewaya))
        .toList();
  }

  static List<ReciterInfo> getHafsReciters() =>
      allReciters.where((r) => r.isHafs).toList();

  static ReciterInfo getDefaultReciter() => allReciters.first;
}
