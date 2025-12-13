// Translation Model - نموذج الترجمات

enum TranslationLanguage {
  english('English', 'en', 'الإنجليزية'),
  french('Français', 'fr', 'الفرنسية'),
  urdu('اردو', 'ur', 'الأردية'),
  indonesian('Bahasa Indonesia', 'id', 'الإندونيسية'),
  turkish('Türkçe', 'tr', 'التركية'),
  german('Deutsch', 'de', 'الألمانية'),
  spanish('Español', 'es', 'الإسبانية');

  final String name;
  final String code;
  final String arabicName;

  const TranslationLanguage(this.name, this.code, this.arabicName);
}

class Translation {
  final String id;
  final TranslationLanguage language;
  final String translatorName;
  final String translatorNameArabic;
  final String description;
  final bool isDownloaded;
  final DateTime? lastUpdated;

  Translation({
    required this.id,
    required this.language,
    required this.translatorName,
    required this.translatorNameArabic,
    required this.description,
    this.isDownloaded = false,
    this.lastUpdated,
  });

  // Popular translations
  static List<Translation> get availableTranslations => [
    Translation(
      id: 'en_sahih_international',
      language: TranslationLanguage.english,
      translatorName: 'Sahih International',
      translatorNameArabic: 'صحيح انترناشيونال',
      description: 'Clear and accurate English translation',
    ),
    Translation(
      id: 'en_yusuf_ali',
      language: TranslationLanguage.english,
      translatorName: 'Abdullah Yusuf Ali',
      translatorNameArabic: 'عبد الله يوسف علي',
      description: 'Classic English translation with commentary',
    ),
    Translation(
      id: 'fr_hamidullah',
      language: TranslationLanguage.french,
      translatorName: 'Muhammad Hamidullah',
      translatorNameArabic: 'محمد حميد الله',
      description: 'French translation by renowned scholar',
    ),
    Translation(
      id: 'ur_jalandhry',
      language: TranslationLanguage.urdu,
      translatorName: 'Fateh Muhammad Jalandhry',
      translatorNameArabic: 'فتح محمد جالندهري',
      description: 'Popular Urdu translation',
    ),
    Translation(
      id: 'id_indonesian',
      language: TranslationLanguage.indonesian,
      translatorName: 'Indonesian Ministry of Religious Affairs',
      translatorNameArabic: 'وزارة الشؤون الدينية الإندونيسية',
      description: 'Official Indonesian translation',
    ),
  ];

  Translation copyWith({
    String? id,
    TranslationLanguage? language,
    String? translatorName,
    String? translatorNameArabic,
    String? description,
    bool? isDownloaded,
    DateTime? lastUpdated,
  }) {
    return Translation(
      id: id ?? this.id,
      language: language ?? this.language,
      translatorName: translatorName ?? this.translatorName,
      translatorNameArabic: translatorNameArabic ?? this.translatorNameArabic,
      description: description ?? this.description,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language.code,
      'translatorName': translatorName,
      'translatorNameArabic': translatorNameArabic,
      'description': description,
      'isDownloaded': isDownloaded,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'] as String,
      language: TranslationLanguage.values.firstWhere(
        (e) => e.code == json['language'],
        orElse: () => TranslationLanguage.english,
      ),
      translatorName: json['translatorName'] as String,
      translatorNameArabic: json['translatorNameArabic'] as String,
      description: json['description'] as String,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }
}

class TranslatedVerse {
  final int surahNumber;
  final int verseNumber;
  final String arabicText;
  final Map<String, String> translations; // translationId -> translated text

  TranslatedVerse({
    required this.surahNumber,
    required this.verseNumber,
    required this.arabicText,
    this.translations = const {},
  });

  // Get translation by ID
  String? getTranslation(String translationId) {
    return translations[translationId];
  }

  // Get translation by language
  String? getTranslationByLanguage(TranslationLanguage language) {
    final entry = translations.entries.firstWhere(
      (e) => e.key.startsWith(language.code),
      orElse: () => const MapEntry('', ''),
    );
    return entry.value.isNotEmpty ? entry.value : null;
  }

  TranslatedVerse copyWith({
    int? surahNumber,
    int? verseNumber,
    String? arabicText,
    Map<String, String>? translations,
  }) {
    return TranslatedVerse(
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      arabicText: arabicText ?? this.arabicText,
      translations: translations ?? this.translations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'arabicText': arabicText,
      'translations': translations,
    };
  }

  factory TranslatedVerse.fromJson(Map<String, dynamic> json) {
    return TranslatedVerse(
      surahNumber: json['surahNumber'] as int,
      verseNumber: json['verseNumber'] as int,
      arabicText: json['arabicText'] as String,
      translations:
          (json['translations'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          {},
    );
  }
}

class TranslationSettings {
  final List<String> enabledTranslationIds;
  final bool showArabicText;
  final bool sideBySideView;
  final String? primaryTranslationId;
  final double translationFontSize;

  TranslationSettings({
    this.enabledTranslationIds = const [],
    this.showArabicText = true,
    this.sideBySideView = true,
    this.primaryTranslationId,
    this.translationFontSize = 16.0,
  });

  TranslationSettings copyWith({
    List<String>? enabledTranslationIds,
    bool? showArabicText,
    bool? sideBySideView,
    String? primaryTranslationId,
    double? translationFontSize,
  }) {
    return TranslationSettings(
      enabledTranslationIds:
          enabledTranslationIds ?? this.enabledTranslationIds,
      showArabicText: showArabicText ?? this.showArabicText,
      sideBySideView: sideBySideView ?? this.sideBySideView,
      primaryTranslationId: primaryTranslationId ?? this.primaryTranslationId,
      translationFontSize: translationFontSize ?? this.translationFontSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabledTranslationIds': enabledTranslationIds,
      'showArabicText': showArabicText,
      'sideBySideView': sideBySideView,
      'primaryTranslationId': primaryTranslationId,
      'translationFontSize': translationFontSize,
    };
  }

  factory TranslationSettings.fromJson(Map<String, dynamic> json) {
    return TranslationSettings(
      enabledTranslationIds:
          (json['enabledTranslationIds'] as List<dynamic>?)?.cast<String>() ??
          [],
      showArabicText: json['showArabicText'] as bool? ?? true,
      sideBySideView: json['sideBySideView'] as bool? ?? true,
      primaryTranslationId: json['primaryTranslationId'] as String?,
      translationFontSize:
          (json['translationFontSize'] as num?)?.toDouble() ?? 16.0,
    );
  }
}
