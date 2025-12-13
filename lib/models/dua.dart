// Dua Model - نموذج الأدعية

enum DuaCategory {
  morning('أذكار الصباح', 'Morning Adhkar'),
  evening('أذكار المساء', 'Evening Adhkar'),
  sleep('أذكار النوم', 'Sleeping Duas'),
  wakeup('أذكار الاستيقاظ', 'Waking Up Duas'),
  prayer('أدعية الصلاة', 'Prayer Duas'),
  eating('أذكار الطعام', 'Eating Duas'),
  travel('أدعية السفر', 'Travel Duas'),
  ruqyah('الرقية الشرعية', 'Ruqyah Shariah'),
  prophets('أدعية الأنبياء', 'Prophets\' Duas'),
  quran('أدعية من القرآن', 'Quranic Duas'),
  general('أدعية عامة', 'General Duas'),
  protection('أدعية الحفظ', 'Protection Duas'),
  forgiveness('أدعية الاستغفار', 'Forgiveness Duas'),
  difficulty('أدعية الكرب', 'Difficulty Duas');

  final String arabicName;
  final String englishName;

  const DuaCategory(this.arabicName, this.englishName);
}

class Dua {
  final String id;
  final String arabicText;
  final String? transliteration;
  final String? translation;
  final String? meaning;
  final DuaCategory category;
  final String? source; // Reference (e.g., "رواه البخاري")
  final String? occasion; // When to recite
  final int? repetitions;
  final List<String> benefits;
  final bool isFavorite;

  Dua({
    required this.id,
    required this.arabicText,
    this.transliteration,
    this.translation,
    this.meaning,
    required this.category,
    this.source,
    this.occasion,
    this.repetitions,
    this.benefits = const [],
    this.isFavorite = false,
  });

  Dua copyWith({
    String? id,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? meaning,
    DuaCategory? category,
    String? source,
    String? occasion,
    int? repetitions,
    List<String>? benefits,
    bool? isFavorite,
  }) {
    return Dua(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      meaning: meaning ?? this.meaning,
      category: category ?? this.category,
      source: source ?? this.source,
      occasion: occasion ?? this.occasion,
      repetitions: repetitions ?? this.repetitions,
      benefits: benefits ?? this.benefits,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'meaning': meaning,
      'category': category.name,
      'source': source,
      'occasion': occasion,
      'repetitions': repetitions,
      'benefits': benefits,
      'isFavorite': isFavorite,
    };
  }

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as String,
      arabicText: json['arabicText'] as String,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      meaning: json['meaning'] as String?,
      category: DuaCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => DuaCategory.general,
      ),
      source: json['source'] as String?,
      occasion: json['occasion'] as String?,
      repetitions: json['repetitions'] as int?,
      benefits: (json['benefits'] as List<dynamic>?)?.cast<String>() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

class DuaCollection {
  final DuaCategory category;
  final String title;
  final String description;
  final List<Dua> duas;
  final int totalCount;

  DuaCollection({
    required this.category,
    required this.title,
    required this.description,
    required this.duas,
  }) : totalCount = duas.length;

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'title': title,
      'description': description,
      'duas': duas.map((d) => d.toJson()).toList(),
    };
  }

  factory DuaCollection.fromJson(Map<String, dynamic> json) {
    return DuaCollection(
      category: DuaCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => DuaCategory.general,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      duas: (json['duas'] as List<dynamic>)
          .map((d) => Dua.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
