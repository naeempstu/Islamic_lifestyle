import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'quran_models.dart';

class QuranRepository {
  static const _kCachedSurahList = 'cached_surah_list';
  static const _kCachedSurah = 'cached_surah_';
  static const _kBookmarkedAyahs = 'bookmarked_ayahs';
  static const _kDailyAyah = 'daily_ayah';
  static const _kDailyAyahDate = 'daily_ayah_date';

  /// Fetch all Surah metadata
  Future<List<Surah>> fetchSurahList() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check cache first
      final cached = prefs.getString(_kCachedSurahList);
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded
            .map((s) => Surah.fromJson(s as Map<String, dynamic>))
            .toList();
      }

      // Fetch from API
      final response = await http
          .get(
            Uri.parse('https://api.alquran.cloud/v1/surah'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final surahsJson =
            (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final surahs = surahsJson.map((s) => Surah.fromJson(s)).toList();

        // Add Bengali names
        for (var surah in surahs) {
          surah.nameBengali =
              bengaliSurahNames[surah.number] ?? surah.nameEnglish;
        }

        // Cache the list
        await prefs.setString(
          _kCachedSurahList,
          jsonEncode(surahsJson),
        );

        return surahs;
      } else {
        throw Exception('Failed to load surah list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching surah list: $e');
      return [];
    }
  }

  /// Fetch complete Surah with ayahs (Arabic + English Transliteration + Bengali Translation)
  Future<Map<String, dynamic>> fetchSurah(int surahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_kCachedSurah$surahNumber';

      // Check cache first
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        return jsonDecode(cached) as Map<String, dynamic>;
      }

      // Fetch from multiple endpoints
      final arabicResponse = await http
          .get(
            Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber'),
          )
          .timeout(const Duration(seconds: 10));

      final bengaliResponse = await http
          .get(
            Uri.parse(
                'https://api.alquran.cloud/v1/surah/$surahNumber/bn.bengali'),
          )
          .timeout(const Duration(seconds: 10));

      if (arabicResponse.statusCode == 200 &&
          bengaliResponse.statusCode == 200) {
        final arabicData =
            jsonDecode(arabicResponse.body) as Map<String, dynamic>;
        final bengaliData =
            jsonDecode(bengaliResponse.body) as Map<String, dynamic>;

        final arabicAyahs = (arabicData['data']?['ayahs'] as List?) ?? [];
        final bengaliAyahs = (bengaliData['data']?['ayahs'] as List?) ?? [];

        // Merge data
        final mergedAyahs = <Map<String, dynamic>>[];
        for (int i = 0; i < arabicAyahs.length; i++) {
          final arabicAyah = Map<String, dynamic>.from(arabicAyahs[i] as Map);
          arabicAyah['bengaliTranslation'] =
              bengaliAyahs.isNotEmpty && i < bengaliAyahs.length
                  ? (bengaliAyahs[i] as Map)['text']
                  : '';
          mergedAyahs.add(arabicAyah);
        }

        final result = {
          'surah': arabicData['data'],
          'ayahs': mergedAyahs,
        };

        // Cache it
        await prefs.setString(cacheKey, jsonEncode(result));
        return result;
      } else {
        throw Exception('Failed to fetch surah');
      }
    } catch (e) {
      print('Error fetching surah $surahNumber: $e');
      return {};
    }
  }

  /// Fetch English transliteration for a specific ayah
  Future<String> fetchAyahTransliteration(
      int surahNumber, int ayahNumber) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                'https://api.quran.com/api/v4/quran/verses/uthmani?chapter_number=$surahNumber&verse_number=$ayahNumber'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final verses = (data['verses'] as List?) ?? [];
        if (verses.isNotEmpty) {
          final verseData = verses[0] as Map<String, dynamic>;
          // Try to get transliteration from additional fields
          return verseData['transliteration'] as String? ?? '';
        }
      }
    } catch (e) {
      print('Error fetching transliteration: $e');
    }
    return '';
  }

  /// Toggle bookmark for ayah
  Future<void> toggleBookmark(int surahNumber, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_kBookmarkedAyahs) ?? [];
    final key = '$surahNumber:$ayahNumber';

    if (bookmarks.contains(key)) {
      bookmarks.remove(key);
    } else {
      bookmarks.add(key);
    }

    await prefs.setStringList(_kBookmarkedAyahs, bookmarks);
  }

  /// Get all bookmarked ayahs
  Future<List<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kBookmarkedAyahs) ?? [];
  }

  /// Check if ayah is bookmarked
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.contains('$surahNumber:$ayahNumber');
  }

  /// Get ayah of the day
  Future<Map<String, dynamic>> getAyahOfDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString(_kDailyAyahDate);

      // Return cached ayah if same day
      if (lastDate == today) {
        final cached = prefs.getString(_kDailyAyah);
        if (cached != null) {
          return jsonDecode(cached) as Map<String, dynamic>;
        }
      }

      // Select random ayah
      final random =
          DateTime.now().millisecondsSinceEpoch % 6236; // Total ayahs in Quran
      final surahList = await fetchSurahList();

      int currentIndex = 0;
      for (final surah in surahList) {
        if (currentIndex + surah.ayahCount > random) {
          final ayahNum = random - currentIndex + 1;
          final surahData = await fetchSurah(surah.number);
          final ayahs = surahData['ayahs'] as List? ?? [];
          if (ayahs.isNotEmpty && ayahNum <= ayahs.length) {
            final ayah = ayahs[ayahNum - 1];
            final result = {
              'surah_number': surah.number,
              'surah_name': surah.nameBengali,
              'ayah_number': ayahNum,
              'ayah': ayah,
            };
            await prefs.setString(_kDailyAyah, jsonEncode(result));
            await prefs.setString(_kDailyAyahDate, today);
            return result;
          }
        }
        currentIndex += surah.ayahCount;
      }

      return {};
    } catch (e) {
      print('Error getting ayah of day: $e');
      return {};
    }
  }

  /// Load offline data (fallback)
  Future<QuranData> loadOfflineData() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/quran/sample_quran.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return QuranData.fromJson(jsonData);
    } catch (e) {
      print('Error loading offline quran data: $e');
      return QuranData(surahs: [], ayahs: {});
    }
  }
}

// No custom debugPrint - using standard print()
