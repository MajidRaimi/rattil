class SupportedLanguage {
  final String code;
  final String nativeName;
  final String englishName;
  final bool isRtl;

  const SupportedLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    this.isRtl = false,
  });
}

const supportedLanguages = <SupportedLanguage>[
  // Arabic first, English second
  SupportedLanguage(code: 'ar', nativeName: 'العربية', englishName: 'Arabic', isRtl: true),
  SupportedLanguage(code: 'en', nativeName: 'English', englishName: 'English'),
  // Rest alphabetical by English name
  SupportedLanguage(code: 'am', nativeName: 'አማርኛ', englishName: 'Amharic'),
  SupportedLanguage(code: 'az', nativeName: 'Azərbaycan', englishName: 'Azerbaijani'),
  SupportedLanguage(code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali'),
  SupportedLanguage(code: 'bs', nativeName: 'Bosanski', englishName: 'Bosnian'),
  SupportedLanguage(code: 'zh', nativeName: '中文', englishName: 'Chinese'),
  SupportedLanguage(code: 'cs', nativeName: 'Čeština', englishName: 'Czech'),
  SupportedLanguage(code: 'nl', nativeName: 'Nederlands', englishName: 'Dutch'),
  SupportedLanguage(code: 'tl', nativeName: 'Filipino', englishName: 'Filipino'),
  SupportedLanguage(code: 'fr', nativeName: 'Français', englishName: 'French'),
  SupportedLanguage(code: 'de', nativeName: 'Deutsch', englishName: 'German'),
  SupportedLanguage(code: 'ha', nativeName: 'Hausa', englishName: 'Hausa'),
  SupportedLanguage(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi'),
  SupportedLanguage(code: 'id', nativeName: 'Bahasa Indonesia', englishName: 'Indonesian'),
  SupportedLanguage(code: 'it', nativeName: 'Italiano', englishName: 'Italian'),
  SupportedLanguage(code: 'ja', nativeName: '日本語', englishName: 'Japanese'),
  SupportedLanguage(code: 'kk', nativeName: 'Қазақша', englishName: 'Kazakh'),
  SupportedLanguage(code: 'ko', nativeName: '한국어', englishName: 'Korean'),
  SupportedLanguage(code: 'ku', nativeName: 'کوردی', englishName: 'Kurdish', isRtl: true),
  SupportedLanguage(code: 'ky', nativeName: 'Кыргызча', englishName: 'Kyrgyz'),
  SupportedLanguage(code: 'ms', nativeName: 'Bahasa Melayu', englishName: 'Malay'),
  SupportedLanguage(code: 'no', nativeName: 'Norsk', englishName: 'Norwegian'),
  SupportedLanguage(code: 'ps', nativeName: 'پښتو', englishName: 'Pashto', isRtl: true),
  SupportedLanguage(code: 'fa', nativeName: 'فارسی', englishName: 'Persian', isRtl: true),
  SupportedLanguage(code: 'pl', nativeName: 'Polski', englishName: 'Polish'),
  SupportedLanguage(code: 'pt', nativeName: 'Português', englishName: 'Portuguese'),
  SupportedLanguage(code: 'ro', nativeName: 'Română', englishName: 'Romanian'),
  SupportedLanguage(code: 'ru', nativeName: 'Русский', englishName: 'Russian'),
  SupportedLanguage(code: 'sd', nativeName: 'سنڌي', englishName: 'Sindhi', isRtl: true),
  SupportedLanguage(code: 'so', nativeName: 'Soomaali', englishName: 'Somali'),
  SupportedLanguage(code: 'es', nativeName: 'Español', englishName: 'Spanish'),
  SupportedLanguage(code: 'sw', nativeName: 'Kiswahili', englishName: 'Swahili'),
  SupportedLanguage(code: 'sv', nativeName: 'Svenska', englishName: 'Swedish'),
  SupportedLanguage(code: 'tg', nativeName: 'Тоҷикӣ', englishName: 'Tajik'),
  SupportedLanguage(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil'),
  SupportedLanguage(code: 'th', nativeName: 'ไทย', englishName: 'Thai'),
  SupportedLanguage(code: 'tr', nativeName: 'Türkçe', englishName: 'Turkish'),
  SupportedLanguage(code: 'uk', nativeName: 'Українська', englishName: 'Ukrainian'),
  SupportedLanguage(code: 'ur', nativeName: 'اردو', englishName: 'Urdu', isRtl: true),
  SupportedLanguage(code: 'uz', nativeName: "O'zbek", englishName: 'Uzbek'),
  SupportedLanguage(code: 'vi', nativeName: 'Tiếng Việt', englishName: 'Vietnamese'),
  SupportedLanguage(code: 'wo', nativeName: 'Wolof', englishName: 'Wolof'),
  SupportedLanguage(code: 'yo', nativeName: 'Yorùbá', englishName: 'Yoruba'),
];
