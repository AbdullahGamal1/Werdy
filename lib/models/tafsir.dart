// Tafsir Model - نموذج التفسير

enum TafsirSource {
  ibnKathir('ابن كثير', 'ibn_kathir'),
  tabari('الطبري', 'tabari'),
  saadi('السعدي', 'saadi'),
  muyassar('الميسر', 'muyassar');

  final String arabicName;
  final String id;

  const TafsirSource(this.arabicName, this.id);
}

class TafsirVerse {
  final int surahNumber;
  final int verseNumber;
  final String verseText;
  final Map<TafsirSource, String> tafsirs; // Multiple tafsir sources

  TafsirVerse({
    required this.surahNumber,
    required this.verseNumber,
    required this.verseText,
    this.tafsirs = const {},
  });

  // Get tafsir for a specific source
  String? getTafsir(TafsirSource source) {
    return tafsirs[source];
  }

  // Convert to/from JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'verseText': verseText,
      'tafsirs': tafsirs.map((key, value) => MapEntry(key.id, value)),
    };
  }

  factory TafsirVerse.fromJson(Map<String, dynamic> json) {
    final tafsirMap = <TafsirSource, String>{};
    final tafsirData = json['tafsirs'] as Map<String, dynamic>?;

    if (tafsirData != null) {
      for (var source in TafsirSource.values) {
        if (tafsirData.containsKey(source.id)) {
          tafsirMap[source] = tafsirData[source.id] as String;
        }
      }
    }

    return TafsirVerse(
      surahNumber: json['surahNumber'] as int,
      verseNumber: json['verseNumber'] as int,
      verseText: json['verseText'] as String,
      tafsirs: tafsirMap,
    );
  }
}

class TafsirData {
  final TafsirSource source;
  final String name;
  final String description;
  final bool isDownloaded;
  final DateTime? lastUpdated;

  TafsirData({
    required this.source,
    required this.name,
    required this.description,
    this.isDownloaded = false,
    this.lastUpdated,
  });

  TafsirData copyWith({
    TafsirSource? source,
    String? name,
    String? description,
    bool? isDownloaded,
    DateTime? lastUpdated,
  }) {
    return TafsirData(
      source: source ?? this.source,
      name: name ?? this.name,
      description: description ?? this.description,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
