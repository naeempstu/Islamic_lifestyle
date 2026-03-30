class QuranAyah {
  final int number;
  final String arabic;
  final String en;
  final String bn;

  const QuranAyah({
    required this.number,
    required this.arabic,
    required this.en,
    required this.bn,
  });
}

class QuranSurah {
  final int id;
  final String nameEn;
  final String nameBn;
  final List<QuranAyah> ayahs;

  const QuranSurah({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.ayahs,
  });
}

class QuranData {
  final List<QuranSurah> surahs;

  const QuranData({required this.surahs});
}

class QuranBookmark {
  final int surahId;
  final int ayahNumber;

  const QuranBookmark({
    required this.surahId,
    required this.ayahNumber,
  });

  String get key => '$surahId-$ayahNumber';
}

