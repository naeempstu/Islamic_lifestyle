import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/app_enums.dart';
import 'quran_models.dart';

class QuranRepository {
  static const _kBookmarks = 'quran_bookmarks';
  static const _kCachedQuran = 'cached_quran_data';

  /// Fetch complete Quran from API with fallback to local data
  Future<QuranData> loadQuranData() async {
    try {
      return await _fetchFromAPI();
    } catch (e) {
      print('API fetch failed, falling back to local data: $e');
      return loadOfflineData();
    }
  }

  /// Fetch Quran from Al-Quran Cloud API
  Future<QuranData> _fetchFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if cached data exists
    final cachedData = prefs.getString(_kCachedQuran);
    if (cachedData != null) {
      try {
        return _parseQuranData(jsonDecode(cachedData) as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing cached data: $e');
      }
    }

    // Fetch Arabic text
    final arabicResponse = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani'),
    ).timeout(const Duration(seconds: 15));

    if (arabicResponse.statusCode != 200) {
      throw Exception('Failed to fetch Arabic Quran');
    }

    final arabicData = jsonDecode(arabicResponse.body);

    // Fetch English translation
    final englishResponse = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/quran/en.asad'),
    ).timeout(const Duration(seconds: 15));

    if (englishResponse.statusCode != 200) {
      throw Exception('Failed to fetch English Quran');
    }

    final englishData = jsonDecode(englishResponse.body);

    // Fetch Bengali translation
    final bengaliResponse = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/quran/bn.bengali'),
    ).timeout(const Duration(seconds: 15));

    if (bengaliResponse.statusCode != 200) {
      throw Exception('Failed to fetch Bengali Quran');
    }

    final bengaliData = jsonDecode(bengaliResponse.body);

    // Merge data and cache it
    final mergedData = _mergeQuranData(
      arabicData['data'] as Map<String, dynamic>,
      englishData['data'] as Map<String, dynamic>,
      bengaliData['data'] as Map<String, dynamic>,
    );

    // Cache the data
    await prefs.setString(_kCachedQuran, jsonEncode(mergedData));

    return _parseQuranData(mergedData);
  }

  /// Merge Arabic, English, and Bengali Quran data
  Map<String, dynamic> _mergeQuranData(
    Map<String, dynamic> arabicData,
    Map<String, dynamic> englishData,
    Map<String, dynamic> bengaliData,
  ) {
    final arabicSurahs = arabicData['surahs'] as List;
    final englishSurahs = englishData['surahs'] as List;
    final bengaliSurahs = bengaliData['surahs'] as List;

    final mergedSurahs = <Map<String, dynamic>>[];

    for (int i = 0; i < arabicSurahs.length; i++) {
      final arabicSurah = arabicSurahs[i] as Map<String, dynamic>;
      final englishSurah = englishSurahs[i] as Map<String, dynamic>;
      final bengaliSurah = bengaliSurahs[i] as Map<String, dynamic>;

      final arabicAyahs = (arabicSurah['ayahs'] as List?) ?? [];
      final englishAyahs = (englishSurah['ayahs'] as List?) ?? [];
      final bengaliAyahs = (bengaliSurah['ayahs'] as List?) ?? [];

      final mergedAyahs = <Map<String, dynamic>>[];

      for (int j = 0; j < arabicAyahs.length; j++) {
        final arabicAyah = arabicAyahs[j] as Map<String, dynamic>;
        final englishAyah =
            j < englishAyahs.length ? englishAyahs[j] as Map<String, dynamic> : {};
        final bengaliAyah =
            j < bengaliAyahs.length ? bengaliAyahs[j] as Map<String, dynamic> : {};

        mergedAyahs.add({
          'number': arabicAyah['numberInSurah'] ?? (j + 1),
          'arabic': arabicAyah['text'] ?? '',
          'en': englishAyah['text'] ?? '',
          'bn': bengaliAyah['text'] ?? '',
        });
      }

      mergedSurahs.add({
        'id': arabicSurah['number'],
        'nameEn': arabicSurah['englishName'] ?? '',
        'nameBn': arabicSurah['name'] ?? '',
        'nameAr': arabicSurah['name'] ?? '',
        'ayahCount': arabicSurah['numberOfAyahs'],
        'ayahs': mergedAyahs,
      });
    }

    return {'surahs': mergedSurahs};
  }

  /// Parse merged Quran data into QuranData model
  QuranData _parseQuranData(Map<String, dynamic> data) {
    final surahsDecoded = (data['surahs'] as List).cast<Map<String, dynamic>>();

    final surahs = <QuranSurah>[];
    for (final s in surahsDecoded) {
      final ayahsDecoded = (s['ayahs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      final ayahs = ayahsDecoded
          .map(
            (a) => QuranAyah(
              number: a['number'] as int,
              arabic: a['arabic'] as String? ?? '',
              en: a['en'] as String? ?? '',
              bn: a['bn'] as String? ?? '',
            ),
          )
          .toList();

      surahs.add(
        QuranSurah(
          id: s['id'] as int,
          nameEn: s['nameEn'] as String? ?? '',
          nameBn: s['nameBn'] as String? ?? '',
          ayahs: ayahs,
          ayahCount: s['ayahCount'] as int?,
        ),
      );
    }

    return QuranData(surahs: surahs);
  }

  Future<QuranData> loadOfflineData() async {
    final raw = await rootBundle.loadString('assets/quran/complete_quran.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final surahsDecoded = (decoded['surahs'] as List).cast<Map<String, dynamic>>();
    final ayahsDataRaw = decoded['ayahs_data'] as Map<String, dynamic>? ?? {};

    final surahs = <QuranSurah>[];
    for (final s in surahsDecoded) {
      // First try to get ayahs from within surah object (for backward compatibility)
      var ayahsDecoded = (s['ayahs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      
      // If no ayahs in surah, try to get from ayahs_data using surah id
      if (ayahsDecoded.isEmpty) {
        final surahId = (s['id'] as int).toString();
        final ayahsFromData = ayahsDataRaw[surahId] as List?;
        if (ayahsFromData != null) {
          ayahsDecoded = ayahsFromData.cast<Map<String, dynamic>>();
        }
      }

      final ayahs = ayahsDecoded
          .map(
            (a) => QuranAyah(
              number: a['number'] as int,
              arabic: a['arabic'] as String? ?? '',
              en: a['en'] as String? ?? '',
              bn: a['bn'] as String? ?? '',
            ),
          )
          .toList();

      surahs.add(
        QuranSurah(
          id: s['id'] as int,
          nameEn: s['nameEn'] as String,
          nameBn: s['nameBn'] as String,
          ayahs: ayahs,
          ayahCount: s['ayahCount'] as int?,
        ),
      );
    }

    return QuranData(surahs: surahs);
  }

  Future<QuranBookmark?> getBookmarkFor({
    required int surahId,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBookmarks);
    if (raw == null) return null;
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    for (final item in list) {
      if (item['surahId'] == surahId && item['ayahNumber'] == ayahNumber) {
        return QuranBookmark(surahId: surahId, ayahNumber: ayahNumber);
      }
    }
    return null;
  }

  Future<void> toggleBookmark(QuranBookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBookmarks);
    final list = <Map<String, dynamic>>[];
    if (raw != null && raw.isNotEmpty) {
      list.addAll((jsonDecode(raw) as List).cast<Map<String, dynamic>>());
    }

    final exists = list.any((item) =>
        item['surahId'] == bookmark.surahId &&
        item['ayahNumber'] == bookmark.ayahNumber);

    if (exists) {
      list.removeWhere((item) =>
          item['surahId'] == bookmark.surahId &&
          item['ayahNumber'] == bookmark.ayahNumber);
    } else {
      list.add({
        'surahId': bookmark.surahId,
        'ayahNumber': bookmark.ayahNumber,
      });
    }

    await prefs.setString(_kBookmarks, jsonEncode(list));
  }

  Future<List<QuranBookmark>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBookmarks);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list
        .map(
          (item) => QuranBookmark(
            surahId: item['surahId'] as int,
            ayahNumber: item['ayahNumber'] as int,
          ),
        )
        .toList();
  }

  Future<QuranAyah> getAyahOfDay({
    required QuranData data,
    required DateTime date,
  }) async {
    final allAyahs = <QuranAyah>[];
    for (final s in data.surahs) {
      allAyahs.addAll(s.ayahs);
    }
    if (allAyahs.isEmpty) {
      throw StateError('No offline Quran ayahs found.');
    }

    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final idx = dayOfYear % allAyahs.length;
    return allAyahs[idx];
  }

  String localizedTranslation({
    required QuranAyah ayah,
    required AppLanguage language,
  }) {
    return language == AppLanguage.bn ? ayah.bn : ayah.en;
  }
}

