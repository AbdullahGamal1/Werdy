// Hadith Model - نموذج الأحاديث

enum HadithSource {
  bukhari('صحيح البخاري', 'Sahih Al-Bukhari'),
  muslim('صحيح مسلم', 'Sahih Muslim'),
  abuDawud('سنن أبي داود', 'Sunan Abu Dawud'),
  tirmidhi('جامع الترمذي', 'Jami` at-Tirmidhi'),
  nasai('سنن النسائي', 'Sunan an-Nasa\'i'),
  ibnMajah('سنن ابن ماجه', 'Sunan Ibn Majah'),
  ahmad('مسند أحمد', 'Musnad Ahmad'),
  malik('موطأ مالك', 'Muwatta Malik');

  final String arabicName;
  final String englishName;

  const HadithSource(this.arabicName, this.englishName);
}

enum HadithCategory {
  aqeedah('العقيدة', 'Faith & Beliefs'),
  akhlaq('الأخلاق', 'Manners & Ethics'),
  worship('العبادات', 'Acts of Worship'),
  fasting('الصيام', 'Fasting'),
  hajj('الحج', 'Hajj & Umrah'),
  zakat('الزكاة', 'Zakat & Charity'),
  family('الأسرة', 'Family'),
  society('المجتمع', 'Society'),
  knowledge('العلم', 'Knowledge'),
  jihad('الجهاد', 'Jihad'),
  endTimes('الفتن وأشراط الساعة', 'End Times'),
  paradise('الجنة والنار', 'Paradise & Hell'),
  prophets('قصص الأنبياء', 'Stories of Prophets'),
  general('عام', 'General');

  final String arabicName;
  final String englishName;

  const HadithCategory(this.arabicName, this.englishName);
}

class Hadith {
  final String id;
  final HadithSource source;
  final int number; // Hadith number in the collection
  final String arabicText;
  final String? englishTranslation;
  final String? narrator; // الراوي
  final HadithCategory category;
  final List<String> tags;
  final String? grade; // صحيح، حسن، ضعيف
  final String? explanation; // شرح مختصر
  final bool isFavorite;

  Hadith({
    required this.id,
    required this.source,
    required this.number,
    required this.arabicText,
    this.englishTranslation,
    this.narrator,
    required this.category,
    this.tags = const [],
    this.grade,
    this.explanation,
    this.isFavorite = false,
  });

  Hadith copyWith({
    String? id,
    HadithSource? source,
    int? number,
    String? arabicText,
    String? englishTranslation,
    String? narrator,
    HadithCategory? category,
    List<String>? tags,
    String? grade,
    String? explanation,
    bool? isFavorite,
  }) {
    return Hadith(
      id: id ?? this.id,
      source: source ?? this.source,
      number: number ?? this.number,
      arabicText: arabicText ?? this.arabicText,
      englishTranslation: englishTranslation ?? this.englishTranslation,
      narrator: narrator ?? this.narrator,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      grade: grade ?? this.grade,
      explanation: explanation ?? this.explanation,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get reference => '${source.arabicName} - ${number.toString()}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source.name,
      'number': number,
      'arabicText': arabicText,
      'englishTranslation': englishTranslation,
      'narrator': narrator,
      'category': category.name,
      'tags': tags,
      'grade': grade,
      'explanation': explanation,
      'isFavorite': isFavorite,
    };
  }

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] as String,
      source: HadithSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => HadithSource.bukhari,
      ),
      number: json['number'] as int,
      arabicText: json['arabicText'] as String,
      englishTranslation: json['englishTranslation'] as String?,
      narrator: json['narrator'] as String?,
      category: HadithCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HadithCategory.general,
      ),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      grade: json['grade'] as String?,
      explanation: json['explanation'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

class HadithCollection {
  final HadithCategory category;
  final List<Hadith> hadiths;

  HadithCollection({required this.category, required this.hadiths});

  int get count => hadiths.length;

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'hadiths': hadiths.map((h) => h.toJson()).toList(),
    };
  }

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    return HadithCollection(
      category: HadithCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HadithCategory.general,
      ),
      hadiths: (json['hadiths'] as List<dynamic>)
          .map((h) => Hadith.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}
