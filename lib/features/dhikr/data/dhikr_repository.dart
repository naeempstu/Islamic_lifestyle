import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../../core/models/app_enums.dart';
import 'dhikr_models.dart';

class DhikrRepository {
  Future<List<DhikrCategory>> loadDhikrCategories() async {
    final raw = await rootBundle.loadString('assets/data/dhikr.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    List<DhikrCategory> categories = [];
    for (final entry in decoded.entries) {
      final catKey = entry.key;
      final itemsDecoded = (entry.value as List).cast<Map<String, dynamic>>();
      final items = itemsDecoded
          .map(
            (item) => DhikrItem(
              key: item['key'] as String,
              titleEn: item['titleEn'] as String,
              titleBn: item['titleBn'] as String,
              arabic: item['arabic'] as String,
              en: item['en'] as String,
              bn: item['bn'] as String,
              defaultCount: (item['defaultCount'] as num).toInt(),
            ),
          )
          .toList();

      categories.add(
        DhikrCategory(
          key: catKey,
          titleEn: _titleEn(catKey),
          titleBn: _titleBn(catKey),
          items: items,
        ),
      );
    }

    return categories;
  }

  String localizedTitle(DhikrCategory category, AppLanguage language) {
    return language == AppLanguage.bn ? category.titleBn : category.titleEn;
  }

  String _titleEn(String key) => switch (key) {
        'morning' => 'Morning',
        'evening' => 'Evening',
        'after_salah' => 'After Salah',
        _ => key,
      };

  String _titleBn(String key) => switch (key) {
        'morning' => 'সকালের',
        'evening' => 'সন্ধ্যার',
        'after_salah' => 'নামাজের পর',
        _ => key,
      };
}

