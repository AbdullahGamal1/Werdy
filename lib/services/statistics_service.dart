// Statistics Service - خدمة الإحصائيات

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reading_statistics.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  static const String _sessionsKey = 'reading_sessions';
  static const String _statsKey = 'reading_statistics';
  static const String _achievementsKey = 'achievements';

  ReadingSession? _currentSession;
  List<ReadingSession> _allSessions = [];
  Map<String, ReadingStatistics> _dailyStats = {}; // date string -> stats
  List<Achievement> _achievements = [];

  // Start a new reading session
  ReadingSession startSession({
    required int surahNumber,
    required int startVerse,
  }) {
    _currentSession = ReadingSession.start(
      surahNumber: surahNumber,
      startVerse: startVerse,
    );
    return _currentSession!;
  }

  // End current session
  Future<ReadingSession?> endSession({int? endVerse, int? versesRead}) async {
    if (_currentSession == null) return null;

    final endTime = DateTime.now();
    final duration = endTime.difference(_currentSession!.startTime);

    _currentSession = _currentSession!.copyWith(
      endTime: endTime,
      endVerse: endVerse,
      versesRead: versesRead ?? _currentSession!.versesRead,
      duration: duration,
      isCompleted: true,
    );

    _allSessions.add(_currentSession!);
    await _updateDailyStats(_currentSession!);
    await _saveData();

    // Check achievements
    await _checkAchievements();

    final completedSession = _currentSession;
    _currentSession = null;

    return completedSession;
  }

  // Update current session progress
  void updateSessionProgress({int? currentVerse, int? versesRead}) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      endVerse: currentVerse,
      versesRead: versesRead ?? _currentSession!.versesRead,
    );
  }

  // Get current active session
  ReadingSession? getCurrentSession() {
    return _currentSession;
  }

  // Update daily statistics
  Future<void> _updateDailyStats(ReadingSession session) async {
    final dateKey = _getDateKey(session.startTime);

    final stats =
        _dailyStats[dateKey] ??
        ReadingStatistics(
          date: session.startTime,
          sessions: [],
          surahsRead: {},
        );

    final newSessions = List<ReadingSession>.from(stats.sessions)..add(session);
    final newSurahsRead = Map<int, int>.from(stats.surahsRead);
    newSurahsRead[session.surahNumber] =
        (newSurahsRead[session.surahNumber] ?? 0) + session.versesRead;

    _dailyStats[dateKey] = stats.copyWith(
      totalMinutesRead: stats.totalMinutesRead + session.duration.inMinutes,
      totalVersesRead: stats.totalVersesRead + session.versesRead,
      totalSessions: stats.totalSessions + 1,
      sessions: newSessions,
      surahsRead: newSurahsRead,
    );
  }

  // Get statistics for today
  ReadingStatistics getTodayStatistics() {
    final today = DateTime.now();
    final dateKey = _getDateKey(today);

    return _dailyStats[dateKey] ??
        ReadingStatistics(date: today, sessions: [], surahsRead: {});
  }

  // Get statistics for a specific date
  ReadingStatistics getStatisticsForDate(DateTime date) {
    final dateKey = _getDateKey(date);

    return _dailyStats[dateKey] ??
        ReadingStatistics(date: date, sessions: [], surahsRead: {});
  }

  // Get weekly statistics
  WeeklyStatistics getWeeklyStatistics(DateTime weekStart) {
    final dailyStats = <ReadingStatistics>[];

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      dailyStats.add(getStatisticsForDate(date));
    }

    return WeeklyStatistics(weekStart: weekStart, dailyStats: dailyStats);
  }

  // Get monthly statistics
  MonthlyStatistics getMonthlyStatistics(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final dailyStats = <ReadingStatistics>[];

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      dailyStats.add(getStatisticsForDate(date));
    }

    final currentStreak = _calculateCurrentStreak();
    final longestStreak = _calculateLongestStreak();

    return MonthlyStatistics(
      month: firstDay,
      dailyStats: dailyStats,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }

  // Calculate current reading streak
  int _calculateCurrentStreak() {
    int streak = 0;
    var date = DateTime.now();

    while (true) {
      final stats = getStatisticsForDate(date);
      if (stats.totalSessions == 0) break;

      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Calculate longest reading streak
  int _calculateLongestStreak() {
    int longest = 0;
    int current = 0;

    final sortedDates = _dailyStats.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      final stats = _dailyStats[sortedDates[i]]!;

      if (stats.totalSessions > 0) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }

    return longest;
  }

  // Achievements management
  Future<void> initializeAchievements() async {
    _achievements = [
      Achievement(
        id: 'first_read',
        titleArabic: 'القراءة الأولى',
        titleEnglish: 'First Read',
        descriptionArabic: 'أكمل جلسة قراءة واحدة',
        descriptionEnglish: 'Complete one reading session',
        icon: '📖',
        target: 1,
      ),
      Achievement(
        id: 'verse_master_10',
        titleArabic: 'قارئ 10 آيات',
        titleEnglish: '10 Verses Reader',
        descriptionArabic: 'اقرأ 10 آيات',
        descriptionEnglish: 'Read 10 verses',
        icon: '🌟',
        target: 10,
      ),
      Achievement(
        id: 'verse_master_100',
        titleArabic: 'قارئ 100 آية',
        titleEnglish: '100 Verses Master',
        descriptionArabic: 'اقرأ 100 آية',
        descriptionEnglish: 'Read 100 verses',
        icon: '⭐',
        target: 100,
      ),
      Achievement(
        id: 'streak_7',
        titleArabic: 'ملتزم أسبوعي',
        titleEnglish: 'Weekly Committed',
        descriptionArabic: 'اقرأ لمدة 7 أيام متتالية',
        descriptionEnglish: 'Read for 7 consecutive days',
        icon: '🔥',
        target: 7,
      ),
      Achievement(
        id: 'streak_30',
        titleArabic: 'ملتزم شهري',
        titleEnglish: 'Monthly Committed',
        descriptionArabic: 'اقرأ لمدة 30 يومًا متتاليًا',
        descriptionEnglish: 'Read for 30 consecutive days',
        icon: '🏆',
        target: 30,
      ),
    ];

    await _loadAchievements();
  }

  Future<void> _checkAchievements() async {
    final totalVerses = _dailyStats.values.fold<int>(
      0,
      (sum, stats) => sum + stats.totalVersesRead,
    );
    final currentStreak = _calculateCurrentStreak();
    final totalSessions = _allSessions.length;

    for (var achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      int progress = 0;

      switch (achievement.id) {
        case 'first_read':
          progress = totalSessions;
          break;
        case 'verse_master_10':
        case 'verse_master_100':
          progress = totalVerses;
          break;
        case 'streak_7':
        case 'streak_30':
          progress = currentStreak;
          break;
      }

      if (progress >= achievement.target) {
        _achievements[_achievements.indexOf(achievement)] = achievement
            .copyWith(
              isUnlocked: true,
              unlockedDate: DateTime.now(),
              progress: achievement.target,
            );
      } else {
        _achievements[_achievements.indexOf(achievement)] = achievement
            .copyWith(progress: progress);
      }
    }

    await _saveAchievements();
  }

  List<Achievement> getAchievements() {
    return List.unmodifiable(_achievements);
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  // Data persistence
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save sessions
    final sessionsJson = json.encode(
      _allSessions.map((s) => s.toJson()).toList(),
    );
    await prefs.setString(_sessionsKey, sessionsJson);

    // Save daily stats
    final statsJson = json.encode(
      _dailyStats.map((k, v) => MapEntry(k, v.toJson())),
    );
    await prefs.setString(_statsKey, statsJson);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load sessions
    final sessionsJson = prefs.getString(_sessionsKey);
    if (sessionsJson != null) {
      final List<dynamic> decoded = json.decode(sessionsJson);
      _allSessions = decoded
          .map((item) => ReadingSession.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Load daily stats
    final statsJson = prefs.getString(_statsKey);
    if (statsJson != null) {
      final Map<String, dynamic> decoded = json.decode(statsJson);
      _dailyStats = decoded.map(
        (k, v) =>
            MapEntry(k, ReadingStatistics.fromJson(v as Map<String, dynamic>)),
      );
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = json.encode(
      _achievements.map((a) => a.toJson()).toList(),
    );
    await prefs.setString(_achievementsKey, achievementsJson);
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);

    if (achievementsJson != null) {
      final List<dynamic> decoded = json.decode(achievementsJson);
      _achievements = decoded
          .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
