import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../../core/models/app_enums.dart';
import 'duas_models.dart';

class DuasRepository {
  Future<List<DuaCategory>> loadDuaCategories() async {
    final raw = await rootBundle.loadString('assets/data/duas.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    final categories = <DuaCategory>[];
    for (final entry in decoded.entries) {
      final key = entry.key;
      final itemsDecoded = (entry.value as List).cast<Map<String, dynamic>>();
      final items = itemsDecoded.map((item) {
        return DuaItem(
          key: item['key'] as String,
          titleEn: item['titleEn'] as String,
          titleBn: item['titleBn'] as String,
          arabic: item['arabic'] as String,
          transliterationEn: item['transliterationEn'] as String,
          en: item['en'] as String,
          bn: item['bn'] as String,
        );
      }).toList();

      categories.add(
        DuaCategory(
          key: key,
          titleEn: _titleEn(key),
          titleBn: _titleBn(key),
          items: items,
        ),
      );
    }

    return categories;
  }

  String localizedTitle(DuaCategory category, AppLanguage language) {
    return language == AppLanguage.bn ? category.titleBn : category.titleEn;
  }

  String _titleEn(String key) => switch (key) {
        'stress' => 'For Stress',
        'illness' => 'For Illness',
        'travel' => 'For Travel',
        'sleep' => 'For Sleep',
        _ => key,
      };

  String _titleBn(String key) => switch (key) {
        'stress' => 'চিন্তা কমাতে',
        'illness' => 'রোগে আরোগ্য চাইতে',
        'travel' => 'ভ্রমণে নিরাপত্তার জন্য',
        'sleep' => 'ঘুমের আগে',
        _ => key,
      };
}

