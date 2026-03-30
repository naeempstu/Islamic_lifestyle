class DhikrItem {
  final String key;
  final String titleEn;
  final String titleBn;
  final String arabic;
  final String en;
  final String bn;
  final int defaultCount;

  const DhikrItem({
    required this.key,
    required this.titleEn,
    required this.titleBn,
    required this.arabic,
    required this.en,
    required this.bn,
    required this.defaultCount,
  });
}

class DhikrCategory {
  final String key;
  final String titleEn;
  final String titleBn;
  final List<DhikrItem> items;

  const DhikrCategory({
    required this.key,
    required this.titleEn,
    required this.titleBn,
    required this.items,
  });
}

