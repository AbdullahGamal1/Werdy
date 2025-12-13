import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werdy/models/reading_goal.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/services/goals_service.dart';
import 'package:werdy/utils/app_strings.dart';
import 'package:werdy/utils/app_theme.dart';

class ReadingGoalScreen extends StatefulWidget {
  const ReadingGoalScreen({super.key});

  @override
  State<ReadingGoalScreen> createState() => _ReadingGoalScreenState();
}

class _ReadingGoalScreenState extends State<ReadingGoalScreen> {
  List<ReadingGoal> _activeGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    await GoalsService().loadGoals();
    if (mounted) {
      setState(() {
        _activeGoals = GoalsService().getActiveGoals();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('reading_goals', settings.languageCode),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCreateGoalCard(context, settings),
                  const SizedBox(height: 24),
                  if (_activeGoals.isEmpty)
                    Center(
                      child: Text(
                        settings.languageCode == 'ar'
                            ? 'لا توجد أهداف نشطة حالياً'
                            : 'No active goals currently',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ..._activeGoals.map(
                      (goal) => _buildGoalCard(goal, settings, isDark),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCreateGoalCard(BuildContext context, SettingsProvider settings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF067D73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                AppStrings.get('create_goal', settings.languageCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            settings.languageCode == 'ar'
                ? 'حدد أهدافك للقراءة وتتبع تقدمك يومياً'
                : 'Set your reading goals and track your progress daily',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to create goal form or show dialog
              _showCreateGoalDialog(context, settings);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppStrings.get('create_goal', settings.languageCode)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    ReadingGoal goal,
    SettingsProvider settings,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settings.languageCode == 'ar'
                      ? goal.period.arabicName
                      : goal.period.englishName,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: goal.progressPercentage / 100,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.progress} / ${goal.target}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${goal.progressPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context, SettingsProvider settings) {
    // Basic dialog to pick a template for now
    showDialog(
      context: context,
      builder: (context) {
        final templates = GoalTemplate.templates;
        return AlertDialog(
          title: Text(AppStrings.get('create_goal', settings.languageCode)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return ListTile(
                  title: Text(
                    settings.languageCode == 'ar'
                        ? template.titleArabic
                        : template.titleEnglish,
                  ),
                  subtitle: Text(
                    settings.languageCode == 'ar'
                        ? template.descriptionArabic
                        : template.descriptionEnglish,
                  ),
                  onTap: () async {
                    await GoalsService().createGoalFromTemplate(template);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadGoals();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
