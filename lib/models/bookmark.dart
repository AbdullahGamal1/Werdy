// Bookmark Model - نموذج العلامات المرجعية

enum BookmarkType { lastRead, bookmark, favorite }

class Bookmark {
  final String id;
  final BookmarkType type;
  final int surahNumber;
  final int verseNumber;
  final String? surahName;
  final String? verseText;
  final String? note;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;

  Bookmark({
    required this.id,
    required this.type,
    required this.surahNumber,
    required this.verseNumber,
    this.surahName,
    this.verseText,
    this.note,
    required this.createdAt,
    this.lastAccessedAt,
  });

  Bookmark copyWith({
    String? id,
    BookmarkType? type,
    int? surahNumber,
    int? verseNumber,
    String? surahName,
    String? verseText,
    String? note,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      type: type ?? this.type,
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      surahName: surahName ?? this.surahName,
      verseText: verseText ?? this.verseText,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'surahName': surahName,
      'verseText': verseText,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      type: BookmarkType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BookmarkType.bookmark,
      ),
      surahNumber: json['surahNumber'] as int,
      verseNumber: json['verseNumber'] as int,
      surahName: json['surahName'] as String?,
      verseText: json['verseText'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : null,
    );
  }

  // Create a new bookmark
  static Bookmark create({
    required BookmarkType type,
    required int surahNumber,
    required int verseNumber,
    String? surahName,
    String? verseText,
    String? note,
  }) {
    return Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      surahName: surahName,
      verseText: verseText,
      note: note,
      createdAt: DateTime.now(),
    );
  }
}

class FavoriteVerse extends Bookmark {
  final List<String> tags;
  final int? highlightColor;

  FavoriteVerse({
    required super.id,
    required super.surahNumber,
    required super.verseNumber,
    super.surahName,
    super.verseText,
    super.note,
    required super.createdAt,
    super.lastAccessedAt,
    this.tags = const [],
    this.highlightColor,
  }) : super(type: BookmarkType.favorite);

  @override
  FavoriteVerse copyWith({
    String? id,
    int? surahNumber,
    int? verseNumber,
    String? surahName,
    String? verseText,
    String? note,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    List<String>? tags,
    int? highlightColor,
  }) {
    return FavoriteVerse(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      surahName: surahName ?? this.surahName,
      verseText: verseText ?? this.verseText,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      tags: tags ?? this.tags,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['tags'] = tags;
    json['highlightColor'] = highlightColor;
    return json;
  }

  factory FavoriteVerse.fromJson(Map<String, dynamic> json) {
    return FavoriteVerse(
      id: json['id'] as String,
      surahNumber: json['surahNumber'] as int,
      verseNumber: json['verseNumber'] as int,
      surahName: json['surahName'] as String?,
      verseText: json['verseText'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      highlightColor: json['highlightColor'] as int?,
    );
  }
}

class LastReadPosition extends Bookmark {
  final int pageNumber;
  final double scrollOffset;

  LastReadPosition({
    required super.surahNumber,
    required super.verseNumber,
    super.surahName,
    required super.createdAt,
    this.pageNumber = 0,
    this.scrollOffset = 0.0,
  }) : super(
         id: 'last_read',
         type: BookmarkType.lastRead,
         lastAccessedAt: DateTime.now(),
       );

  @override
  LastReadPosition copyWith({
    int? surahNumber,
    int? verseNumber,
    String? surahName,
    DateTime? createdAt,
    int? pageNumber,
    double? scrollOffset,
  }) {
    return LastReadPosition(
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      surahName: surahName ?? this.surahName,
      createdAt: createdAt ?? this.createdAt,
      pageNumber: pageNumber ?? this.pageNumber,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['pageNumber'] = pageNumber;
    json['scrollOffset'] = scrollOffset;
    return json;
  }

  factory LastReadPosition.fromJson(Map<String, dynamic> json) {
    return LastReadPosition(
      surahNumber: json['surahNumber'] as int,
      verseNumber: json['verseNumber'] as int,
      surahName: json['surahName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pageNumber: json['pageNumber'] as int? ?? 0,
      scrollOffset: (json['scrollOffset'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static LastReadPosition create({
    required int surahNumber,
    required int verseNumber,
    String? surahName,
    int pageNumber = 0,
    double scrollOffset = 0.0,
  }) {
    return LastReadPosition(
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      surahName: surahName,
      createdAt: DateTime.now(),
      pageNumber: pageNumber,
      scrollOffset: scrollOffset,
    );
  }
}
