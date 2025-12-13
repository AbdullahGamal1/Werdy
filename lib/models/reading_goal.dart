// Reading Goal Model - نموذج أهداف القراءة

enum GoalPeriod {
  daily('يومي', 'Daily'),
  weekly('أسبوعي', 'Weekly'),
  monthly('شهري', 'Monthly'),
  custom('مخصص', 'Custom');

  final String arabicName;
  final String englishName;

  const GoalPeriod(this.arabicName, this.englishName);
}

enum GoalType {
  verses('آيات', 'Verses', 'عدد الآيات'),
  time('وقت', 'Time', 'مدة القراءة'),
  surahs('سور', 'Surahs', 'عدد السور'),
  juz('أجزاء', 'Juz', 'عدد الأجزاء');

  final String arabicName;
  final String englishName;
  final String description;

  const GoalType(this.arabicName, this.englishName, this.description);
}

class ReadingGoal {
  final String id;
  final String title;
  final GoalType type;
  final GoalPeriod period;
  final int target;
  final int progress;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final bool isActive;
  final DateTime? completedDate;

  ReadingGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.period,
    required this.target,
    this.progress = 0,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.isActive = true,
    this.completedDate,
  });

  double get progressPercentage => target > 0 ? (progress / target) * 100 : 0;

  bool get isOverdue => DateTime.now().isAfter(endDate) && !isCompleted;

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return Duration.zero;
    return endDate.difference(now);
  }

  ReadingGoal copyWith({
    String? id,
    String? title,
    GoalType? type,
    GoalPeriod? period,
    int? target,
    int? progress,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    bool? isActive,
    DateTime? completedDate,
  }) {
    return ReadingGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      period: period ?? this.period,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'period': period.name,
      'target': target,
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isActive': isActive,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory ReadingGoal.fromJson(Map<String, dynamic> json) {
    return ReadingGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.verses,
      ),
      period: GoalPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => GoalPeriod.daily,
      ),
      target: json['target'] as int,
      progress: json['progress'] as int? ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
    );
  }

  static ReadingGoal create({
    required String title,
    required GoalType type,
    required GoalPeriod period,
    required int target,
  }) {
    final now = DateTime.now();
    DateTime endDate;

    switch (period) {
      case GoalPeriod.daily:
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case GoalPeriod.weekly:
        final daysUntilSunday = 7 - now.weekday;
        endDate = now.add(Duration(days: daysUntilSunday));
        break;
      case GoalPeriod.monthly:
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case GoalPeriod.custom:
        endDate = now.add(const Duration(days: 30));
        break;
    }

    return ReadingGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
      period: period,
      target: target,
      startDate: now,
      endDate: endDate,
    );
  }
}

class GoalTemplate {
  final String id;
  final String titleArabic;
  final String titleEnglish;
  final GoalType type;
  final GoalPeriod period;
  final int suggestedTarget;
  final String descriptionArabic;
  final String descriptionEnglish;

  GoalTemplate({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.type,
    required this.period,
    required this.suggestedTarget,
    required this.descriptionArabic,
    required this.descriptionEnglish,
  });

  // Common goal templates
  static List<GoalTemplate> get templates => [
    GoalTemplate(
      id: 'daily_10_verses',
      titleArabic: '10 آيات يوميًا',
      titleEnglish: '10 Verses Daily',
      type: GoalType.verses,
      period: GoalPeriod.daily,
      suggestedTarget: 10,
      descriptionArabic: 'اقرأ 10 آيات كل يوم',
      descriptionEnglish: 'Read 10 verses every day',
    ),
    GoalTemplate(
      id: 'daily_1_page',
      titleArabic: 'صفحة واحدة يوميًا',
      titleEnglish: '1 Page Daily',
      type: GoalType.verses,
      period: GoalPeriod.daily,
      suggestedTarget: 15,
      descriptionArabic: 'اقرأ صفحة واحدة كل يوم',
      descriptionEnglish: 'Read one page every day',
    ),
    GoalTemplate(
      id: 'weekly_1_juz',
      titleArabic: 'جزء واحد أسبوعيًا',
      titleEnglish: '1 Juz Weekly',
      type: GoalType.juz,
      period: GoalPeriod.weekly,
      suggestedTarget: 1,
      descriptionArabic: 'أكمل جزءًا كاملًا كل أسبوع',
      descriptionEnglish: 'Complete one Juz every week',
    ),
    GoalTemplate(
      id: 'monthly_complete_quran',
      titleArabic: 'ختم القرآن شهريًا',
      titleEnglish: 'Complete Quran Monthly',
      type: GoalType.juz,
      period: GoalPeriod.monthly,
      suggestedTarget: 30,
      descriptionArabic: 'اختم القرآن الكريم كاملًا في شهر',
      descriptionEnglish: 'Complete the entire Quran in one month',
    ),
    GoalTemplate(
      id: 'daily_15_minutes',
      titleArabic: '15 دقيقة يوميًا',
      titleEnglish: '15 Minutes Daily',
      type: GoalType.time,
      period: GoalPeriod.daily,
      suggestedTarget: 15,
      descriptionArabic: 'اقضِ 15 دقيقة في القراءة يوميًا',
      descriptionEnglish: 'Spend 15 minutes reading daily',
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleArabic': titleArabic,
      'titleEnglish': titleEnglish,
      'type': type.name,
      'period': period.name,
      'suggestedTarget': suggestedTarget,
      'descriptionArabic': descriptionArabic,
      'descriptionEnglish': descriptionEnglish,
    };
  }

  factory GoalTemplate.fromJson(Map<String, dynamic> json) {
    return GoalTemplate(
      id: json['id'] as String,
      titleArabic: json['titleArabic'] as String,
      titleEnglish: json['titleEnglish'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.verses,
      ),
      period: GoalPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => GoalPeriod.daily,
      ),
      suggestedTarget: json['suggestedTarget'] as int,
      descriptionArabic: json['descriptionArabic'] as String,
      descriptionEnglish: json['descriptionEnglish'] as String,
    );
  }
}
