class DuaItem {
  final String key;
  final String titleEn;
  final String titleBn;
  final String arabic;
  final String transliterationEn;
  final String en;
  final String bn;

  const DuaItem({
    required this.key,
    required this.titleEn,
    required this.titleBn,
    required this.arabic,
    required this.transliterationEn,
    required this.en,
    required this.bn,
  });
}

class DuaCategory {
  final String key;
  final String titleEn;
  final String titleBn;
  final List<DuaItem> items;

  const DuaCategory({
    required this.key,
    required this.titleEn,
    required this.titleBn,
    required this.items,
  });
}

