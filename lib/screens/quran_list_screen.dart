import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/screens/surah_detail_screen.dart';
import 'package:werdy/utils/app_strings.dart';
import 'package:werdy/utils/arab_numeral_converter.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(AppStrings.get('holy_quran', settings.languageCode)),
            centerTitle: false,
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_outline),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.get(
                    'search_surah',
                    settings.languageCode,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final surahNumber = index + 1;
              final surahName = quran.getSurahName(surahNumber);
              final surahNameArabic = quran.getSurahNameArabic(surahNumber);
              final englishNameTranslation = quran.getSurahNameEnglish(
                surahNumber,
              );

              if (_searchQuery.isNotEmpty &&
                  !surahName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) &&
                  !surahNameArabic.contains(_searchQuery) &&
                  !englishNameTranslation.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  )) {
                return const SizedBox.shrink();
              }

              return _buildSurahTile(
                context,
                surahNumber,
                surahName,
                surahNameArabic,
                englishNameTranslation,
              );
            }, childCount: 114),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTile(
    BuildContext context,
    int number,
    String name,
    String arabicName,
    String translation,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(
                  surahNumber: number,
                  surahName: arabicName, // Always pass Arabic name
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number.toArabic(), // Use Arabic Numerals
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri', // Ensure Arabic font
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    arabicName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // Fix for Dark Mode: White text in dark, Primary in light
                      color: isDark
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontFamily: 'Amiri', // Ensure Arabic font
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
