import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werdy/models/reading_statistics.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/services/statistics_service.dart';
import 'package:werdy/utils/app_strings.dart';
import 'package:werdy/utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart'; // Ensure it's in pubspec

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  WeeklyStatistics? _weeklyStats;
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    await StatisticsService().loadData();
    await StatisticsService().initializeAchievements();

    // Get stats for current week (starting Sunday or Saturday? Let's say last 7 days)
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));

    final weekly = StatisticsService().getWeeklyStatistics(weekStart);
    final achievements = StatisticsService().getAchievements();

    if (mounted) {
      setState(() {
        _weeklyStats = weekly;
        _achievements = achievements;
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
          AppStrings.get('statistics', settings.languageCode),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(settings),
                  const SizedBox(height: 24),
                  Text(
                    settings.languageCode == 'ar'
                        ? 'النشاط الأسبوعي'
                        : 'Weekly Activity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(isDark),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('achievements', settings.languageCode),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementsList(settings, isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(SettingsProvider settings) {
    if (_weeklyStats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            settings.languageCode == 'ar' ? 'الدقائق' : 'Minutes',
            _weeklyStats!.totalMinutes.toString(),
            Icons.timer_outlined,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            AppStrings.get('verses', settings.languageCode),
            _weeklyStats!.totalVerses.toString(),
            Icons.menu_book,
            AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    if (_weeklyStats == null) return const SizedBox.shrink();

    return Container(
      height: 200,
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
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (_weeklyStats!.dailyStats
                  .map((e) => e.totalMinutesRead)
                  .fold<int>(0, (p, e) => p > e ? p : e)
                  .toDouble() +
              5), // Max + buffer
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < _weeklyStats!.dailyStats.length) {
                    final stat = _weeklyStats!.dailyStats[value.toInt()];
                    // Return first letter of day name or similar
                    // Just simplified
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        stat.date.day.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: _weeklyStats!.dailyStats.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.totalMinutesRead.toDouble(),
                  color: AppTheme.primaryColor,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAchievementsList(SettingsProvider settings, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        final isUnlocked = achievement.isUnlocked;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isUnlocked
                ? Border.all(color: Colors.amber.withOpacity(0.5))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.amber.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.languageCode == 'ar'
                          ? achievement.titleArabic
                          : achievement.titleEnglish,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                    Text(
                      settings.languageCode == 'ar'
                          ? achievement.descriptionArabic
                          : achievement.descriptionEnglish,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: achievement.progressPercentage / 100,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        minHeight: 4,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isUnlocked)
                const Icon(Icons.check_circle, color: Colors.amber),
            ],
          ),
        );
      },
    );
  }
}
