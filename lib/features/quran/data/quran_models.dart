class Surah {
  final int number;
  final String nameArabic;
  String nameBengali;
  final String nameEnglish;
  final int ayahCount;
  final String revelationType; // 'Meccan' or 'Medinan'

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameBengali,
    required this.nameEnglish,
    required this.ayahCount,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int? ?? 0,
      nameArabic: json['name'] as String? ?? '',
      nameBengali: json['nameBengali'] as String? ?? '',
      nameEnglish: json['englishName'] as String? ?? '',
      ayahCount: json['numberOfAyahs'] as int? ?? 0,
      revelationType: json['revelationType'] as String? ?? 'Meccan',
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name': nameArabic,
        'nameBengali': nameBengali,
        'englishName': nameEnglish,
        'numberOfAyahs': ayahCount,
        'revelationType': revelationType,
      };
}

class Ayah {
  final int number;
  final int surahNumber;
  final String textArabic;
  final String textBengaliTranslation;
  final String textEnglishTransliteration;
  final String bengaliPronunciation;

  Ayah({
    required this.number,
    required this.surahNumber,
    required this.textArabic,
    required this.textBengaliTranslation,
    required this.textEnglishTransliteration,
    required this.bengaliPronunciation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json, int surahNum) {
    final englishTranslit = json['transliteration'] as String? ?? '';
    return Ayah(
      number: json['numberInSurah'] as int? ?? 0,
      surahNumber: surahNum,
      textArabic: json['text'] as String? ?? '',
      textBengaliTranslation: json['bengaliTranslation'] as String? ?? '',
      textEnglishTransliteration: englishTranslit,
      bengaliPronunciation: _convertToBengaliPronunciation(englishTranslit),
    );
  }

  Map<String, dynamic> toJson() => {
        'numberInSurah': number,
        'text': textArabic,
        'transliteration': textEnglishTransliteration,
        'bengaliTranslation': textBengaliTranslation,
        'bengaliPronunciation': bengaliPronunciation,
      };
}

// English to Bengali Pronunciation Converter
String _convertToBengaliPronunciation(String englishTranslit) {
  if (englishTranslit.isEmpty) return '';

  String result = englishTranslit.toLowerCase();

  // Multi-character patterns (must be done first)
  final multiCharPatterns = {
    'th': 'থ',
    'dh': 'ধ',
    'kh': 'খ',
    'gh': 'ঘ',
    'sh': 'শ',
    'ph': 'ফ',
    'zh': 'ঝ',
    'ch': 'চ',
    'jh': 'ঝ',
    'bh': 'ভ',
  };

  multiCharPatterns.forEach((key, value) {
    result = result.replaceAll(key, value);
  });

  // Single character mappings
  final singleCharMap = {
    'h': 'হ',
    'k': 'ক',
    'g': 'গ',
    'n': 'ন',
    't': 'ট',
    'd': 'ড',
    'p': 'প',
    'b': 'ব',
    'm': 'ম',
    'y': 'য',
    'r': 'র',
    'l': 'ল',
    'w': 'ব',
    'f': 'ফ',
    'q': 'ক',
    'j': 'জ',
    's': 'স',
    'c': 'ছ',
    'x': 'ক্স',
    'z': 'জ',
    'v': 'ভ',
  };

  singleCharMap.forEach((key, value) {
    result = result.replaceAll(key, value);
  });

  // Vowel mappings
  final vowelMap = {
    'ā': 'া',
    'ī': 'ী',
    'ū': 'ু',
    'a': 'া',
    'i': 'ি',
    'u': 'ু',
    'e': 'ে',
    'o': 'ো',
  };

  vowelMap.forEach((key, value) {
    result = result.replaceAll(key, value);
  });

  // Clean up
  result = result.replaceAll(RegExp(r'[^\u0980-\u09FF]'), '');

  return result;
}

class QuranData {
  final List<Surah> surahs;
  final Map<int, List<Ayah>> ayahs; // surah_number -> list of ayahs

  QuranData({
    required this.surahs,
    required this.ayahs,
  });

  factory QuranData.fromJson(Map<String, dynamic> json) {
    final surahsJson = (json['surahs'] as List?) ?? [];
    final ayahsJson = (json['ayahs'] as Map?) ?? {};

    final surahs = surahsJson
        .map((s) => Surah.fromJson(s as Map<String, dynamic>))
        .toList();

    final ayahs = <int, List<Ayah>>{};
    for (final entry in ayahsJson.entries) {
      final surahNum = int.tryParse(entry.key) ?? 0;
      final ayahList = (entry.value as List?)
              ?.map((a) => Ayah.fromJson(a as Map<String, dynamic>, surahNum))
              .toList() ??
          [];
      ayahs[surahNum] = ayahList;
    }

    return QuranData(surahs: surahs, ayahs: ayahs);
  }

  Map<String, dynamic> toJson() => {
        'surahs': surahs.map((s) => s.toJson()).toList(),
        'ayahs': {
          for (final entry in ayahs.entries) entry.key.toString(): entry.value
        },
      };
}

// Bengali Surah Name Mappings
const bengaliSurahNames = {
  1: 'আল-ফাতিহা',
  2: 'আল-বাকারা',
  3: 'আলে ইমরান',
  4: 'আন-নিসা',
  5: 'আল-মায়িদা',
  6: 'আল-আনআম',
  7: 'আল-আরাফ',
  8: 'আল-আনফাল',
  9: 'আত-তাওবা',
  10: 'ইউনুস',
  11: 'হুদ',
  12: 'ইউসুফ',
  13: 'আর-রাদ',
  14: 'ইব্রাহিম',
  15: 'আল-হিজর',
  16: 'আন-নাহল',
  17: 'আল-ইসরা',
  18: 'আল-কাহফ',
  19: 'মারইয়াম',
  20: 'তা-হা',
  21: 'আল-আম্বিয়া',
  22: 'আল-হাজ',
  23: 'আল-মু\'মিনুন',
  24: 'আন-নূর',
  25: 'আল-ফুরকান',
  26: 'আশ-শুআরা',
  27: 'আন-নামল',
  28: 'আল-কাসাস',
  29: 'আল-আনকাবুত',
  30: 'আর-রুম',
  31: 'লুকমান',
  32: 'আস-সাজদা',
  33: 'আল-আহযাব',
  34: 'সাবা',
  35: 'ফাতির',
  36: 'ইয়াসিন',
  37: 'আস-সাফফাত',
  38: 'সাদ',
  39: 'আজ-জুমার',
  40: 'গাফির',
  41: 'হা-মিম',
  42: 'আশ-শুরা',
  43: 'আজ-জুখরুফ',
  44: 'আদ-দুখান',
  45: 'আল-জাথিয়া',
  46: 'আল-আহকাফ',
  47: 'মুহাম্মাদ',
  48: 'আল-ফাতহ',
  49: 'আল-হুজুরাত',
  50: 'কাফ',
  51: 'আজ-জারিয়াত',
  52: 'আত-তুর',
  53: 'আন-নাজম',
  54: 'আল-কামার',
  55: 'আর-রাহমান',
  56: 'আল-ওয়াকিয়া',
  57: 'আল-হাদিদ',
  58: 'আল-মুজাদালা',
  59: 'আল-হাশর',
  60: 'আল-মুমতাহিনা',
  61: 'আস-সাফ',
  62: 'আল-জুমুআ',
  63: 'আল-মুনাফিকুন',
  64: 'আত-তাগাবুন',
  65: 'আত-তালাক',
  66: 'আত-তাহরিম',
  67: 'আল-মুলক',
  68: 'আল-কলম',
  69: 'আল-হাক্কা',
  70: 'আল-মাআরিজ',
  71: 'নুহ',
  72: 'আল-জিন',
  73: 'আল-মুজাম্মিল',
  74: 'আল-মুদাছির',
  75: 'আল-কিয়ামা',
  76: 'আল-ইনসান',
  77: 'আল-মুরসালাত',
  78: 'আন-নাবা',
  79: 'আন-নাজিয়াত',
  80: 'আবাসা',
  81: 'আত-তাকউইর',
  82: 'আল-ইনফিতার',
  83: 'আল-মুতাফ্ফিফিন',
  84: 'আল-ইনশিকাক',
  85: 'আল-বুরুজ',
  86: 'আত-তারিক',
  87: 'আল-আলা',
  88: 'আল-গাশিয়া',
  89: 'আল-ফাজর',
  90: 'আল-বালাদ',
  91: 'আশ-শামস',
  92: 'আল-লাইল',
  93: 'আদ-দুহা',
  94: 'আশ-শারহ',
  95: 'আত-তিন',
  96: 'আল-আলাক',
  97: 'আল-কাদর',
  98: 'আল-বাইয়িনা',
  99: 'আজ-জিলজাল',
  100: 'আল-আদিয়াত',
  101: 'আল-কারিয়া',
  102: 'আত-তাকাসুর',
  103: 'আল-আসর',
  104: 'আল-হুমাজা',
  105: 'আল-ফিল',
  106: 'কুরাইশ',
  107: 'আল-মাউন',
  108: 'আল-কাউসার',
  109: 'আল-কাফিরুন',
  110: 'আন-নাসর',
  111: 'আল-মাসাদ',
  112: 'আল-ইখলাস',
  113: 'আল-ফালাক',
  114: 'আন-নাস',
};
