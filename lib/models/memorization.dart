// Memorization Model - نموذج الحفظ

enum MemorizationStatus {
  notStarted('لم يبدأ', 'Not Started'),
  inProgress('جاري الحفظ', 'In Progress'),
  reviewing('مراجعة', 'Reviewing'),
  memorized('محفوظ', 'Memorized'),
  needsReview('يحتاج مراجعة', 'Needs Review');

  final String arabicName;
  final String englishName;

  const MemorizationStatus(this.arabicName, this.englishName);
}

class MemorizationProgress {
  final int surahNumber;
  final String surahName;
  final int totalVerses;
  final Map<int, VerseMemorization> verses; // verseNumber -> status
  final DateTime? startDate;
  final DateTime? completedDate;
  final DateTime lastReviewDate;
  final int reviewCount;
  final double accuracy; // Percentage (0-100)

  MemorizationProgress({
    required this.surahNumber,
    required this.surahName,
    required this.totalVerses,
    this.verses = const {},
    this.startDate,
    this.completedDate,
    DateTime? lastReviewDate,
    this.reviewCount = 0,
    this.accuracy = 0.0,
  }) : lastReviewDate = lastReviewDate ?? DateTime.now();

  int get memorizedVerses => verses.values
      .where((v) => v.status == MemorizationStatus.memorized)
      .length;

  int get inProgressVerses => verses.values
      .where((v) => v.status == MemorizationStatus.inProgress)
      .length;

  double get completionPercentage =>
      totalVerses > 0 ? (memorizedVerses / totalVerses) * 100 : 0;

  MemorizationStatus get overallStatus {
    if (memorizedVerses == 0) return MemorizationStatus.notStarted;
    if (memorizedVerses == totalVerses) return MemorizationStatus.memorized;
    return MemorizationStatus.inProgress;
  }

  MemorizationProgress copyWith({
    int? surahNumber,
    String? surahName,
    int? totalVerses,
    Map<int, VerseMemorization>? verses,
    DateTime? startDate,
    DateTime? completedDate,
    DateTime? lastReviewDate,
    int? reviewCount,
    double? accuracy,
  }) {
    return MemorizationProgress(
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      totalVerses: totalVerses ?? this.totalVerses,
      verses: verses ?? this.verses,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      reviewCount: reviewCount ?? this.reviewCount,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'totalVerses': totalVerses,
      'verses': verses.map((k, v) => MapEntry(k.toString(), v.toJson())),
      'startDate': startDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'lastReviewDate': lastReviewDate.toIso8601String(),
      'reviewCount': reviewCount,
      'accuracy': accuracy,
    };
  }

  factory MemorizationProgress.fromJson(Map<String, dynamic> json) {
    final versesMap = <int, VerseMemorization>{};
    final versesData = json['verses'] as Map<String, dynamic>?;
    if (versesData != null) {
      versesData.forEach((key, value) {
        versesMap[int.parse(key)] = VerseMemorization.fromJson(
          value as Map<String, dynamic>,
        );
      });
    }

    return MemorizationProgress(
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String,
      totalVerses: json['totalVerses'] as int,
      verses: versesMap,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      lastReviewDate: DateTime.parse(json['lastReviewDate'] as String),
      reviewCount: json['reviewCount'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class VerseMemorization {
  final int verseNumber;
  final MemorizationStatus status;
  final DateTime? memorizedDate;
  final DateTime? nextReviewDate;
  final int mistakeCount;
  final List<String> notes;

  VerseMemorization({
    required this.verseNumber,
    this.status = MemorizationStatus.notStarted,
    this.memorizedDate,
    this.nextReviewDate,
    this.mistakeCount = 0,
    this.notes = const [],
  });

  VerseMemorization copyWith({
    int? verseNumber,
    MemorizationStatus? status,
    DateTime? memorizedDate,
    DateTime? nextReviewDate,
    int? mistakeCount,
    List<String>? notes,
  }) {
    return VerseMemorization(
      verseNumber: verseNumber ?? this.verseNumber,
      status: status ?? this.status,
      memorizedDate: memorizedDate ?? this.memorizedDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      mistakeCount: mistakeCount ?? this.mistakeCount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verseNumber': verseNumber,
      'status': status.name,
      'memorizedDate': memorizedDate?.toIso8601String(),
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'mistakeCount': mistakeCount,
      'notes': notes,
    };
  }

  factory VerseMemorization.fromJson(Map<String, dynamic> json) {
    return VerseMemorization(
      verseNumber: json['verseNumber'] as int,
      status: MemorizationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MemorizationStatus.notStarted,
      ),
      memorizedDate: json['memorizedDate'] != null
          ? DateTime.parse(json['memorizedDate'] as String)
          : null,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'] as String)
          : null,
      mistakeCount: json['mistakeCount'] as int? ?? 0,
      notes: (json['notes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class Quiz {
  final String id;
  final int surahNumber;
  final List<int> verseNumbers;
  final DateTime createdAt;
  final Map<int, QuizAnswer> answers; // verseNumber -> answer
  final bool isCompleted;

  Quiz({
    required this.id,
    required this.surahNumber,
    required this.verseNumbers,
    required this.createdAt,
    this.answers = const {},
    this.isCompleted = false,
  });

  int get correctAnswers => answers.values.where((a) => a.isCorrect).length;

  int get totalQuestions => verseNumbers.length;

  double get score =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  Quiz copyWith({
    String? id,
    int? surahNumber,
    List<int>? verseNumbers,
    DateTime? createdAt,
    Map<int, QuizAnswer>? answers,
    bool? isCompleted,
  }) {
    return Quiz(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumbers: verseNumbers ?? this.verseNumbers,
      createdAt: createdAt ?? this.createdAt,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'verseNumbers': verseNumbers,
      'createdAt': createdAt.toIso8601String(),
      'answers': answers.map((k, v) => MapEntry(k.toString(), v.toJson())),
      'isCompleted': isCompleted,
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final answersMap = <int, QuizAnswer>{};
    final answersData = json['answers'] as Map<String, dynamic>?;
    if (answersData != null) {
      answersData.forEach((key, value) {
        answersMap[int.parse(key)] = QuizAnswer.fromJson(
          value as Map<String, dynamic>,
        );
      });
    }

    return Quiz(
      id: json['id'] as String,
      surahNumber: json['surahNumber'] as int,
      verseNumbers: (json['verseNumbers'] as List<dynamic>).cast<int>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      answers: answersMap,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class QuizAnswer {
  final int verseNumber;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int mistakeCount;

  QuizAnswer({
    required this.verseNumber,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.mistakeCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'verseNumber': verseNumber,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'mistakeCount': mistakeCount,
    };
  }

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      verseNumber: json['verseNumber'] as int,
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      mistakeCount: json['mistakeCount'] as int? ?? 0,
    );
  }
}
