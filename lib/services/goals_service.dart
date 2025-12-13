// Goals Service - خدمة الأهداف

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reading_goal.dart';
import 'notification_service.dart';

class GoalsService {
  static final GoalsService _instance = GoalsService._internal();
  factory GoalsService() => _instance;
  GoalsService._internal();

  static const String _goalsKey = 'reading_goals';

  List<ReadingGoal> _goals = [];

  // Load goals from storage
  Future<void> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);

    if (goalsJson != null) {
      final List<dynamic> decoded = json.decode(goalsJson);
      _goals = decoded
          .map((item) => ReadingGoal.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  // Save goals to storage
  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = json.encode(_goals.map((g) => g.toJson()).toList());
    await prefs.setString(_goalsKey, goalsJson);
  }

  // Create a new goal
  Future<ReadingGoal> createGoal({
    required String title,
    required GoalType type,
    required GoalPeriod period,
    required int target,
  }) async {
    final goal = ReadingGoal.create(
      title: title,
      type: type,
      period: period,
      target: target,
    );

    _goals.add(goal);
    await _saveGoals();

    // Schedule reminder notification
    await _scheduleGoalReminder(goal);

    return goal;
  }

  // Create goal from template
  Future<ReadingGoal> createGoalFromTemplate(GoalTemplate template) async {
    return createGoal(
      title: template.titleArabic,
      type: template.type,
      period: template.period,
      target: template.suggestedTarget,
    );
  }

  // Update goal progress
  Future<void> updateGoalProgress(String goalId, int newProgress) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final goal = _goals[index];
    final updatedGoal = goal.copyWith(progress: newProgress);

    // Check if goal is completed
    if (newProgress >= goal.target && !goal.isCompleted) {
      _goals[index] = updatedGoal.copyWith(
        isCompleted: true,
        completedDate: DateTime.now(),
      );

      // Send completion notification
      await _sendGoalCompletedNotification(goal);
    } else {
      _goals[index] = updatedGoal;
    }

    await _saveGoals();
  }

  // Increment goal progress
  Future<void> incrementGoalProgress(String goalId, int increment) async {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    await updateGoalProgress(goalId, goal.progress + increment);
  }

  // Update reading goals based on activity
  Future<void> updateGoalsFromActivity({
    int? versesRead,
    int? minutesRead,
    int? surahsCompleted,
    int? juzCompleted,
  }) async {
    for (var goal in _goals.where((g) => g.isActive && !g.isCompleted)) {
      int? increment;

      switch (goal.type) {
        case GoalType.verses:
          increment = versesRead;
          break;
        case GoalType.time:
          increment = minutesRead;
          break;
        case GoalType.surahs:
          increment = surahsCompleted;
          break;
        case GoalType.juz:
          increment = juzCompleted;
          break;
      }

      if (increment != null && increment > 0) {
        await incrementGoalProgress(goal.id, increment);
      }
    }
  }

  // Get all goals
  List<ReadingGoal> getAllGoals() {
    return List.unmodifiable(_goals);
  }

  // Get active goals
  List<ReadingGoal> getActiveGoals() {
    return _goals.where((g) => g.isActive && !g.isCompleted).toList();
  }

  // Get completed goals
  List<ReadingGoal> getCompletedGoals() {
    return _goals.where((g) => g.isCompleted).toList();
  }

  // Get goals by period
  List<ReadingGoal> getGoalsByPeriod(GoalPeriod period) {
    return _goals.where((g) => g.period == period && g.isActive).toList();
  }

  // Update goal
  Future<void> updateGoal(ReadingGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _saveGoals();
    }
  }

  // Delete goal
  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    await _saveGoals();
  }

  // Mark goal as inactive
  Future<void> deactivateGoal(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(isActive: false);
      await _saveGoals();
    }
  }

  // Reactivate goal
  Future<void> reactivateGoal(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(isActive: true);
      await _saveGoals();
    }
  }

  // Check for overdue goals
  List<ReadingGoal> getOverdueGoals() {
    return _goals.where((g) => g.isOverdue).toList();
  }

  // Reset expired goals for recurring periods
  Future<void> resetExpiredRecurringGoals() async {
    final now = DateTime.now();

    for (var goal in _goals) {
      if (goal.isActive && now.isAfter(goal.endDate) && !goal.isCompleted) {
        // For daily goals, reset if it's a new day
        if (goal.period == GoalPeriod.daily) {
          final newGoal = ReadingGoal.create(
            title: goal.title,
            type: goal.type,
            period: goal.period,
            target: goal.target,
          );
          _goals.add(newGoal);
        }
      }
    }

    await _saveGoals();
  }

  // Schedule goal reminder notification
  Future<void> _scheduleGoalReminder(ReadingGoal goal) async {
    final notificationService = NotificationService();

    // Schedule notification 2 hours before goal deadline
    final reminderTime = goal.endDate.subtract(const Duration(hours: 2));

    if (reminderTime.isAfter(DateTime.now())) {
      await notificationService.scheduleNotificationAtTime(
        goal.id.hashCode % 1000 + 100, // Unique ID
        'تذكير بالهدف',
        'لديك ${goal.timeRemaining.inHours} ساعة لإكمال هدف: ${goal.title}',
        reminderTime,
      );
    }
  }

  // Send goal completed notification
  Future<void> _sendGoalCompletedNotification(ReadingGoal goal) async {
    final notificationService = NotificationService();

    await notificationService.showNotification(
      id: goal.id.hashCode % 1000 + 100,
      title: '🎉 تهانينا!',
      body: 'لقد أكملت هدف: ${goal.title}',
    );
  }

  // Get today's goals
  List<ReadingGoal> getTodaysGoals() {
    final today = DateTime.now();
    return _goals.where((g) {
      return g.isActive &&
          !g.isCompleted &&
          g.startDate.isBefore(today) &&
          g.endDate.isAfter(today);
    }).toList();
  }

  // Calculate overall progress percentage
  double getOverallProgress() {
    final activeGoals = getActiveGoals();
    if (activeGoals.isEmpty) return 0.0;

    final totalProgress = activeGoals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.progressPercentage,
    );

    return totalProgress / activeGoals.length;
  }
}
