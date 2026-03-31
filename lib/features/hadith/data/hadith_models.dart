class HadithCollection {
  final int id;
  final String nameEn;
  final String nameBn;
  final String authorEn;
  final String authorBn;
  final int hadithCount;
  final List<Hadith> hadith;

  HadithCollection({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.authorEn,
    required this.authorBn,
    required this.hadithCount,
    this.hadith = const [],
  });

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    return HadithCollection(
      id: json['id'] as int? ?? 0,
      nameEn: json['nameEn'] as String? ?? '',
      nameBn: json['nameBn'] as String? ?? '',
      authorEn: json['authorEn'] as String? ?? '',
      authorBn: json['authorBn'] as String? ?? '',
      hadithCount: json['hadithCount'] as int? ?? 0,
      hadith:
          (json['hadith'] as List?)
              ?.map((h) => Hadith.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameBn': nameBn,
    'authorEn': authorEn,
    'authorBn': authorBn,
    'hadithCount': hadithCount,
    'hadith': hadith.map((h) => h.toJson()).toList(),
  };
}

class Hadith {
  final int number;
  final String text;
  final String textBn;
  final String narrator;
  final String narratorBn;
  final String? explanation;
  final String? explanationBn;
  final String? reference;

  Hadith({
    required this.number,
    required this.text,
    this.textBn = '',
    required this.narrator,
    this.narratorBn = '',
    this.explanation,
    this.explanationBn,
    this.reference,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      number: json['number'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      textBn: json['textBn'] as String? ?? '',
      narrator: json['narrator'] as String? ?? '',
      narratorBn: json['narratorBn'] as String? ?? '',
      explanation: json['explanation'] as String?,
      explanationBn: json['explanationBn'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'text': text,
    'textBn': textBn,
    'narrator': narrator,
    'narratorBn': narratorBn,
    'explanation': explanation,
    'explanationBn': explanationBn,
    'reference': reference,
  };
}

class HadithData {
  final List<HadithCollection> collections;

  HadithData({required this.collections});

  factory HadithData.fromJson(Map<String, dynamic> json) {
    return HadithData(
      collections:
          (json['collections'] as List?)
              ?.map((c) => HadithCollection.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'collections': collections.map((c) => c.toJson()).toList(),
  };
}
