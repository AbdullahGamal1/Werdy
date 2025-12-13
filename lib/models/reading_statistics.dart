// Reading Statistics Model - نموذج إحصائيات القراءة

class ReadingSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int surahNumber;
  final int startVerse;
  final int? endVerse;
  final int versesRead;
  final Duration duration;
  final bool isCompleted;

  ReadingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.surahNumber,
    required this.startVerse,
    this.endVerse,
    this.versesRead = 0,
    this.duration = Duration.zero,
    this.isCompleted = false,
  });

  ReadingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? surahNumber,
    int? startVerse,
    int? endVerse,
    int? versesRead,
    Duration? duration,
    bool? isCompleted,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      surahNumber: surahNumber ?? this.surahNumber,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      versesRead: versesRead ?? this.versesRead,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'surahNumber': surahNumber,
      'startVerse': startVerse,
      'endVerse': endVerse,
      'versesRead': versesRead,
      'durationSeconds': duration.inSeconds,
      'isCompleted': isCompleted,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      surahNumber: json['surahNumber'] as int,
      startVerse: json['startVerse'] as int,
      endVerse: json['endVerse'] as int?,
      versesRead: json['versesRead'] as int? ?? 0,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static ReadingSession start({
    required int surahNumber,
    required int startVerse,
  }) {
    return ReadingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      surahNumber: surahNumber,
      startVerse: startVerse,
    );
  }
}

class ReadingStatistics {
  final DateTime date;
  final int totalMinutesRead;
  final int totalVersesRead;
  final int totalSessions;
  final List<ReadingSession> sessions;
  final Map<int, int> surahsRead; // surahNumber -> verses count

  ReadingStatistics({
    required this.date,
    this.totalMinutesRead = 0,
    this.totalVersesRead = 0,
    this.totalSessions = 0,
    this.sessions = const [],
    this.surahsRead = const {},
  });

  ReadingStatistics copyWith({
    DateTime? date,
    int? totalMinutesRead,
    int? totalVersesRead,
    int? totalSessions,
    List<ReadingSession>? sessions,
    Map<int, int>? surahsRead,
  }) {
    return ReadingStatistics(
      date: date ?? this.date,
      totalMinutesRead: totalMinutesRead ?? this.totalMinutesRead,
      totalVersesRead: totalVersesRead ?? this.totalVersesRead,
      totalSessions: totalSessions ?? this.totalSessions,
      sessions: sessions ?? this.sessions,
      surahsRead: surahsRead ?? this.surahsRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalMinutesRead': totalMinutesRead,
      'totalVersesRead': totalVersesRead,
      'totalSessions': totalSessions,
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'surahsRead': surahsRead.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  factory ReadingStatistics.fromJson(Map<String, dynamic> json) {
    final surahsMap = <int, int>{};
    final surahsData = json['surahsRead'] as Map<String, dynamic>?;
    if (surahsData != null) {
      surahsData.forEach((key, value) {
        surahsMap[int.parse(key)] = value as int;
      });
    }

    return ReadingStatistics(
      date: DateTime.parse(json['date'] as String),
      totalMinutesRead: json['totalMinutesRead'] as int? ?? 0,
      totalVersesRead: json['totalVersesRead'] as int? ?? 0,
      totalSessions: json['totalSessions'] as int? ?? 0,
      sessions:
          (json['sessions'] as List<dynamic>?)
              ?.map((s) => ReadingSession.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      surahsRead: surahsMap,
    );
  }
}

class WeeklyStatistics {
  final DateTime weekStart;
  final List<ReadingStatistics> dailyStats;
  final int totalMinutes;
  final int totalVerses;
  final int totalSessions;
  final double averageMinutesPerDay;

  WeeklyStatistics({required this.weekStart, required this.dailyStats})
    : totalMinutes = dailyStats.fold(
        0,
        (sum, stat) => sum + stat.totalMinutesRead,
      ),
      totalVerses = dailyStats.fold(
        0,
        (sum, stat) => sum + stat.totalVersesRead,
      ),
      totalSessions = dailyStats.fold(
        0,
        (sum, stat) => sum + stat.totalSessions,
      ),
      averageMinutesPerDay = dailyStats.isEmpty
          ? 0
          : dailyStats.fold(0, (sum, stat) => sum + stat.totalMinutesRead) /
                dailyStats.length;

  Map<String, dynamic> toJson() {
    return {
      'weekStart': weekStart.toIso8601String(),
      'dailyStats': dailyStats.map((s) => s.toJson()).toList(),
    };
  }

  factory WeeklyStatistics.fromJson(Map<String, dynamic> json) {
    return WeeklyStatistics(
      weekStart: DateTime.parse(json['weekStart'] as String),
      dailyStats: (json['dailyStats'] as List<dynamic>)
          .map((s) => ReadingStatistics.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthlyStatistics {
  final DateTime month;
  final List<ReadingStatistics> dailyStats;
  final int totalMinutes;
  final int totalVerses;
  final int totalSessions;
  final int daysActive;
  final int currentStreak;
  final int longestStreak;

  MonthlyStatistics({
    required this.month,
    required this.dailyStats,
    required this.currentStreak,
    required this.longestStreak,
  }) : totalMinutes = dailyStats.fold(
         0,
         (sum, stat) => sum + stat.totalMinutesRead,
       ),
       totalVerses = dailyStats.fold(
         0,
         (sum, stat) => sum + stat.totalVersesRead,
       ),
       totalSessions = dailyStats.fold(
         0,
         (sum, stat) => sum + stat.totalSessions,
       ),
       daysActive = dailyStats.where((s) => s.totalSessions > 0).length;

  Map<String, dynamic> toJson() {
    return {
      'month': month.toIso8601String(),
      'dailyStats': dailyStats.map((s) => s.toJson()).toList(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  factory MonthlyStatistics.fromJson(Map<String, dynamic> json) {
    return MonthlyStatistics(
      month: DateTime.parse(json['month'] as String),
      dailyStats: (json['dailyStats'] as List<dynamic>)
          .map((s) => ReadingStatistics.fromJson(s as Map<String, dynamic>))
          .toList(),
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
    );
  }
}

class Achievement {
  final String id;
  final String titleArabic;
  final String titleEnglish;
  final String descriptionArabic;
  final String descriptionEnglish;
  final String icon;
  final DateTime? unlockedDate;
  final bool isUnlocked;
  final int progress;
  final int target;

  Achievement({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.descriptionArabic,
    required this.descriptionEnglish,
    required this.icon,
    this.unlockedDate,
    this.isUnlocked = false,
    this.progress = 0,
    required this.target,
  });

  double get progressPercentage => target > 0 ? (progress / target) * 100 : 0;

  Achievement copyWith({
    String? id,
    String? titleArabic,
    String? titleEnglish,
    String? descriptionArabic,
    String? descriptionEnglish,
    String? icon,
    DateTime? unlockedDate,
    bool? isUnlocked,
    int? progress,
    int? target,
  }) {
    return Achievement(
      id: id ?? this.id,
      titleArabic: titleArabic ?? this.titleArabic,
      titleEnglish: titleEnglish ?? this.titleEnglish,
      descriptionArabic: descriptionArabic ?? this.descriptionArabic,
      descriptionEnglish: descriptionEnglish ?? this.descriptionEnglish,
      icon: icon ?? this.icon,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleArabic': titleArabic,
      'titleEnglish': titleEnglish,
      'descriptionArabic': descriptionArabic,
      'descriptionEnglish': descriptionEnglish,
      'icon': icon,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'isUnlocked': isUnlocked,
      'progress': progress,
      'target': target,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      titleArabic: json['titleArabic'] as String,
      titleEnglish: json['titleEnglish'] as String,
      descriptionArabic: json['descriptionArabic'] as String,
      descriptionEnglish: json['descriptionEnglish'] as String,
      icon: json['icon'] as String,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      progress: json['progress'] as int? ?? 0,
      target: json['target'] as int,
    );
  }
}
