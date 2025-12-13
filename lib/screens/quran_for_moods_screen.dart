import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:werdy/utils/app_theme.dart';
import 'package:werdy/screens/surah_detail_screen.dart';

class QuranForMoodsScreen extends StatelessWidget {
  const QuranForMoodsScreen({super.key});

  final Map<String, Map<String, dynamic>> moodData = const {
    'Sad': {
      'label': 'حزين',
      'emoji': '😢',
      'color': Colors.blueGrey,
      'verses': [
        {
          'surah': 93,
          'verse': 5,
        }, // Ad-Duha: And your Lord is going to give you, and you will be satisfied.
        {
          'surah': 94,
          'verse': 5,
        }, // Ash-Sharh: For indeed, with hardship [will be] ease.
        {
          'surah': 12,
          'verse': 86,
        }, // Yusuf: I only complain of my suffering and my grief to Allah.
        {
          'surah': 3,
          'verse': 139,
        }, // Al-Imran: So do not weaken and do not grieve.
      ],
    },
    'Anxious': {
      'label': 'قلق',
      'emoji': '😰',
      'color': Colors.teal,
      'verses': [
        {
          'surah': 13,
          'verse': 28,
        }, // Ar-Ra'd: Unquestionably, by the remembrance of Allah hearts are assured.
        {
          'surah': 2,
          'verse': 45,
        }, // Al-Baqarah: And seek help through patience and prayer.
        {
          'surah': 20,
          'verse': 2,
        }, // Taha: We have not sent down to you the Qur'an that you be distressed.
      ],
    },
    'Happy': {
      'label': 'سعيد',
      'emoji': '😊',
      'color': Colors.orange,
      'verses': [
        {
          'surah': 14,
          'verse': 7,
        }, // Ibrahim: If you are grateful, I will surely increase you.
        {
          'surah': 55,
          'verse': 13,
        }, // Ar-Rahman: So which of the favors of your Lord would you deny?
        {
          'surah': 16,
          'verse': 18,
        }, // An-Nahl: And if you should count the favors of Allah, you could not enumerate them.
      ],
    },
    'Tired': {
      'label': 'مرهق',
      'emoji': '😫',
      'color': Colors.brown,
      'verses': [
        {
          'surah': 2,
          'verse': 286,
        }, // Al-Baqarah: Allah does not charge a soul except [with that within] its capacity.
        {
          'surah': 94,
          'verse': 6,
        }, // Ash-Sharh: Indeed, with hardship [will be] ease.
      ],
    },
    'Lost': {
      'label': 'تائه',
      'emoji': '🌫️',
      'color': Colors.purple,
      'verses': [
        {'surah': 1, 'verse': 6}, // Al-Fatiha: Guide us to the straight path.
        {
          'surah': 65,
          'verse': 3,
        }, // At-Talaq: And whoever relies upon Allah - then He is sufficient for him.
        {'surah': 2, 'verse': 186}, // Al-Baqarah: Indeed I am near.
      ],
    },
    'Angry': {
      'label': 'غاضب',
      'emoji': '😠',
      'color': Colors.redAccent,
      'verses': [
        {
          'surah': 3,
          'verse': 134,
        }, // Al-Imran: Who restrain anger and who pardon the people.
        {
          'surah': 41,
          'verse': 34,
        }, // Fussilat: Repel [evil] by that [deed] which is better.
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('علاج للقلوب'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'كيف تشعر اليوم؟',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'اختر حالتك لنقترح عليك آيات تلامس قلبك',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moodData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final key = moodData.keys.elementAt(index);
              final item = moodData[key]!;

              return InkWell(
                onTap: () {
                  _showVersesForMood(context, item);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (item['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['emoji'], style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 8),
                      Text(
                        item['label'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: item['color'],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVersesForMood(BuildContext context, Map<String, dynamic> moodItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'آيات لـ ${moodItem['label']}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.all(24),
                    itemCount: (moodItem['verses'] as List).length,
                    separatorBuilder: (_, __) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final verseInfo = (moodItem['verses'] as List)[index];
                      final surahNum = verseInfo['surah'] as int;
                      final verseNum = verseInfo['verse'] as int;

                      final verseText = quran.getVerse(surahNum, verseNum);
                      final surahName = quran.getSurahNameArabic(surahNum);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahDetailScreen(
                                surahNumber: surahNum,
                                surahName: surahName,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              verseText,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(
                                fontSize: 20,
                                height: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$surahName - آية $verseNum',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
