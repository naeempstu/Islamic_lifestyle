import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'hadith_models.dart';

class HadithRepository {
  static const _kCachedHadith = 'cached_hadith_data';

  /// Fetch hadith collections from API with fallback to local data
  Future<HadithData> loadHadithData() async {
    try {
      print('Attempting to fetch hadith from API...');
      final apiData = await _fetchFromAPI();
      if (apiData.collections.isNotEmpty) {
        print(
            'Successfully loaded ${apiData.collections.length} collections from API');
        return apiData;
      }
    } catch (e) {
      print('Hadith API fetch failed: $e');
    }

    try {
      print('Falling back to offline hadith data...');
      final offlineData = await loadOfflineData();
      if (offlineData.collections.isNotEmpty) {
        print('Hadith loaded from offline data');
        return offlineData;
      }
    } catch (e) {
      print('Error loading offline hadith data: $e');
    }

    return HadithData(collections: []);
  }

  /// Fetch popular hadith collections from Sunnah API
  Future<HadithData> _fetchFromAPI() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if cached data exists
    final cachedData = prefs.getString(_kCachedHadith);
    if (cachedData != null) {
      try {
        return HadithData.fromJson(
            jsonDecode(cachedData) as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing cached hadith: $e');
      }
    }

    // Fetch Sahih Bukhari
    final collections = <HadithCollection>[];

    try {
      // Fetch Bukhari metadata
      final bukhari = await _fetchCollection(
        'sahih-al-bukhari',
        'Sahih Al-Bukhari',
        'সহীহ আল-বুখারী',
        'Muhammad al-Bukhari',
        'মুহাম্মাদ আল-বুখারী',
      );
      if (bukhari != null) collections.add(bukhari);

      // Fetch Muslim metadata
      final muslim = await _fetchCollection(
        'sahih-muslim',
        'Sahih Muslim',
        'সহীহ মুসলিম',
        'Muslim ibn al-Hajjaj',
        'মুসলিম ইবনু হাজ্জাজ',
      );
      if (muslim != null) collections.add(muslim);

      // Fetch Tirmidhi metadata
      final tirmidhi = await _fetchCollection(
        'jami-at-tirmidhi',
        'Jami at-Tirmidhi',
        'জামি আত-তিরমিযি',
        'At-Tirmidhi',
        'আত-তিরমিযি',
      );
      if (tirmidhi != null) collections.add(tirmidhi);

      // Fetch Abu Dawood metadata
      final abuDawood = await _fetchCollection(
        'sunan-abi-dawood',
        'Sunan Abu Dawood',
        'সুনান আবূ দাউদ',
        'Abu Dawood',
        'আবূ দাউদ',
      );
      if (abuDawood != null) collections.add(abuDawood);

      // Fetch Nasai metadata
      final nasai = await _fetchCollection(
        'sunan-an-nasai',
        'Sunan An-Nasai',
        'সুনান আন-নাসাই',
        'An-Nasai',
        'আন-নাসাই',
      );
      if (nasai != null) collections.add(nasai);

      // Fetch Ibn Majah metadata
      final ibnMajah = await _fetchCollection(
        'sunan-ibn-majah',
        'Sunan Ibn Majah',
        'সুনান ইবনু মাজাহ',
        'Ibn Majah',
        'ইবনু মাজাহ',
      );
      if (ibnMajah != null) collections.add(ibnMajah);
    } catch (e) {
      print('Error fetching hadith collections: $e');
    }

    // If no collections loaded from API, fall back to offline data
    if (collections.isEmpty) {
      print('No hadith collections from API, using offline data');
      return await loadOfflineData();
    }

    final data = HadithData(collections: collections);

    // Cache the data
    await prefs.setString(_kCachedHadith, jsonEncode(data.toJson()));

    return data;
  }

  /// Fetch a single hadith collection with sample hadith
  Future<HadithCollection?> _fetchCollection(
    String slug,
    String nameEn,
    String nameBn,
    String authorEn,
    String authorBn,
  ) async {
    try {
      // Fetch from Sunnah.com API
      final response = await http
          .get(
            Uri.parse('https://api.sunnah.com/v1/collections/$slug'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hadithCount = data['hadithCount'] as int? ?? 0;

        // Fetch first 20 hadith as sample
        var hadithList = <Hadith>[];
        try {
          final hadithResponse = await http
              .get(
                Uri.parse(
                    'https://api.sunnah.com/v1/collections/$slug/hadith?limit=20'),
              )
              .timeout(const Duration(seconds: 10));

          if (hadithResponse.statusCode == 200) {
            final hadithData = jsonDecode(hadithResponse.body);
            final hadithsArray = hadithData['hadith'] as List?;
            if (hadithsArray != null) {
              hadithList = hadithsArray
                  .map((h) => Hadith(
                        number: h['hadithNumber'] ?? h['number'] ?? 0,
                        text: h['body'] ?? h['text'] ?? '',
                        narrator: h['narrator'] ?? '',
                        explanation: h['explanation'],
                        reference: h['reference'],
                      ))
                  .toList();
              print('Fetched ${hadithList.length} hadith from $slug');
            }
          }
        } catch (e) {
          print('Error fetching hadith from $slug: $e');
        }

        return HadithCollection(
          id: slug.hashCode,
          nameEn: nameEn,
          nameBn: nameBn,
          authorEn: authorEn,
          authorBn: authorBn,
          hadithCount: hadithCount,
          hadith: hadithList,
        );
      }
    } catch (e) {
      print('Error fetching collection $slug: $e');
    }

    return null;
  }

  /// Load hadith data from local JSON
  Future<HadithData> loadOfflineData() async {
    try {
      print('Loading hadith from offline JSON...');
      final raw = await rootBundle.loadString('assets/data/hadith_sample.json');
      if (raw.isEmpty) {
        print('Offline hadith file is empty');
        return HadithData(collections: []);
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final data = HadithData.fromJson(decoded);
      print(
          'Successfully loaded ${data.collections.length} hadith collections from offline data');
      return data;
    } catch (e) {
      print('Error loading offline hadith data: $e');
      // Return empty data if offline file doesn't exist
      return HadithData(collections: []);
    }
  }
}
