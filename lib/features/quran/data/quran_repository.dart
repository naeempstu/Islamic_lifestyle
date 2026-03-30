import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/app_enums.dart';
import 'quran_models.dart';

class QuranRepository {
  static const _kBookmarks = 'quran_bookmarks';

  Future<QuranData> loadOfflineData() async {
    final raw = await rootBundle.loadString('assets/quran/sample_quran.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final surahsDecoded = (decoded['surahs'] as List).cast<Map<String, dynamic>>();

    final surahs = <QuranSurah>[];
    for (final s in surahsDecoded) {
      final ayahsDecoded = (s['ayahs'] as List).cast<Map<String, dynamic>>();
      final ayahs = ayahsDecoded
          .map(
            (a) => QuranAyah(
              number: a['number'] as int,
              arabic: a['arabic'] as String,
              en: a['en'] as String,
              bn: a['bn'] as String,
            ),
          )
          .toList();

      surahs.add(
        QuranSurah(
          id: s['id'] as int,
          nameEn: s['nameEn'] as String,
          nameBn: s['nameBn'] as String,
          ayahs: ayahs,
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

