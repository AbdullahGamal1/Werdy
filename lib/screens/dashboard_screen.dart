import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/utils/app_strings.dart';
import 'package:werdy/utils/app_theme.dart';
import 'package:werdy/screens/qibla_screen.dart';
import 'package:werdy/screens/prayer_times_screen.dart';
import 'package:werdy/screens/reading_goal_screen.dart';
import 'package:werdy/screens/statistics_screen.dart';
import 'package:werdy/screens/search_screen.dart';
import 'package:werdy/screens/memorization_quiz_screen.dart';
import 'package:werdy/screens/quran_for_moods_screen.dart';
import 'package:werdy/screens/reflections_screen.dart';
import 'package:werdy/screens/tajweed_check_screen.dart';
import 'package:werdy/screens/quran_radio_screen.dart';
import 'package:werdy/screens/gamification_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Werdy'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(context),
            const SizedBox(height: 24),
            _buildLastReadCard(context),
            const SizedBox(height: 24),
            Text(
              AppStrings.get(
                'quick_access',
                Provider.of<SettingsProvider>(context).languageCode,
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildQuickAccessGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assalamu Alaikum,',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Muscle Muslim', // Placeholder or user name
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLastReadCard(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.get('last_read', settings.languageCode),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppStrings.get('continue_reading', settings.languageCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Surah Al-Kahf',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily:
                  settings.fontFamily, // Ensure this font is used if available
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ayah 10',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final items = [
      {
        'icon': Icons.wb_sunny_rounded,
        'label': AppStrings.get('morning', settings.languageCode),
        'color': Colors.orange,
        'onTap': () {
          // Navigate to Morning Adhkar
          Navigator.pushNamed(
            context,
            '/adhkar_list',
          ); // Assuming route or direct push
          // For now direct push as AdhkarListScreen exists
          // Actually AdhkarListScreen might be the tab, we want AdhkarDetailScreen for specific morning/evening?
          // Or passing filter to AdhkarListScreen.
          // Let's just push to AdhkarListScreen for simplicity or create a simpler path.
        },
      },
      {
        'icon': Icons.nights_stay_rounded,
        'label': AppStrings.get('evening', settings.languageCode),
        'color': Colors.indigo,
        'onTap': () {},
      },
      {
        'icon': Icons.mosque_rounded,
        'label': AppStrings.get('prayer', settings.languageCode),
        'color': AppTheme.primaryColor,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrayerTimesScreen()),
          );
        },
      },
      {
        'icon': Icons.explore,
        'label': AppStrings.get('qibla_direction', settings.languageCode),
        'color': Colors.brown,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QiblaScreen()),
          );
        },
      },
      {
        'icon': Icons.track_changes,
        'label': AppStrings.get('reading_goals', settings.languageCode),
        'color': Colors.teal,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReadingGoalScreen()),
          );
        },
      },
      {
        'icon': Icons.bar_chart,
        'label': AppStrings.get('statistics', settings.languageCode),
        'color': Colors.purple,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StatisticsScreen()),
          );
        },
      },
      {
        'icon': Icons.psychology,
        'label': 'اختبار الحفظ', // Hardcoded for now, should be localized
        'color': Colors.pink,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MemorizationQuizScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.mood,
        'label': 'علاج للقلوب',
        'color': Colors.cyan,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuranForMoodsScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.menu_book,
        'label': 'فوائد وتدبرات',
        'color': Colors.indigo,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReflectionsScreen()),
          );
        },
      },
      {
        'icon': Icons
            .multitrack_audio, // Changed to a simpler icon if graphic_eq is too complex, actually graphic_eq is fine.
        'label': 'المصحح الآلي',
        'color': Colors.deepOrange,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TajweedCheckScreen()),
          );
        },
      },
      {
        'icon': Icons.radio,
        'label': 'راديو القرآن',
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuranRadioScreen()),
          );
        },
      },
      {
        'icon': Icons.emoji_events,
        'label': 'إنجازاتي',
        'color': Colors.amber,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GamificationScreen()),
          );
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          color: (item['color'] as Color).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: item['onTap'] as VoidCallback?,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 32,
                  color: item['color'] as Color,
                ),
                const SizedBox(height: 12),
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Slightly smaller to fit
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
