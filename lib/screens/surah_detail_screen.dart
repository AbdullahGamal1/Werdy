import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/services/tafsir_service.dart';
import 'package:werdy/services/translation_service.dart';
import 'package:werdy/models/tafsir.dart';
import 'package:werdy/models/translation.dart';
import 'package:werdy/utils/app_theme.dart';
import 'package:werdy/widgets/surah_header_delegate.dart';
import 'package:werdy/utils/arab_numeral_converter.dart';
import 'package:werdy/screens/search_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showVerseOptions(BuildContext context, int verseNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VerseOptionsSheet(
        surahNumber: widget.surahNumber,
        verseNumber: verseNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final verseCount = quran.getVerseCount(widget.surahNumber);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SurahHeaderDelegate(
                surahNumber: widget.surahNumber,
                surahName: quran.getSurahNameArabic(widget.surahNumber),
                // surahEnglishName removed as requested for Arabic only
                verseCount: verseCount,
                revelationType: quran.getPlaceOfRevelation(widget.surahNumber),
                expandedHeight: 280,
                topPadding: MediaQuery.of(context).padding.top,
              ),
            ),

            // Search Box
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'بحث عن آية...',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.search,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Basmala (except Surah Tawbah/9 and Al-Fatiha/1)
            if (widget.surahNumber != 9 && widget.surahNumber != 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  child: Center(
                    child: Text(
                      quran.basmala,
                      style: GoogleFonts.amiri(
                        fontSize: 26,
                        color: AppTheme.primaryColor,
                        height: 2.0,
                      ),
                    ),
                  ),
                ),
              ),

            // Verses - Continuous Text (Mushaf Style)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Builder(
                    builder: (context) {
                      final List<InlineSpan> spans = [];

                      for (int i = 1; i <= verseCount; i++) {
                        final verseNumber = i;
                        String verseText = quran.getVerse(
                          widget.surahNumber,
                          verseNumber,
                        );

                        // Remove Basmala from the start of the first verse
                        // Only for verses that are not Al-Fatiha (1) or At-Tawbah (9)
                        if (verseNumber == 1 &&
                            widget.surahNumber != 1 &&
                            widget.surahNumber != 9) {
                          // 1. Check against the package's own Basmala constant
                          if (verseText.startsWith(quran.basmala)) {
                            verseText = verseText
                                .substring(quran.basmala.length)
                                .trim();
                          } else {
                            // 2. Common Uthmani variants (often found in this package or APIs)
                            final basmalaVariants = [
                              "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", // With Waslas (common in Uthmani)
                              "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ", // Alternative spacing/chars
                              "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", // Standard
                              "بسم الله الرحمن الرحيم", // Plain
                            ];

                            for (final b in basmalaVariants) {
                              if (verseText.startsWith(b)) {
                                verseText = verseText
                                    .substring(b.length)
                                    .trim();
                                break;
                              }
                            }

                            // 3. Last Line of Defense: Regex for flexible matching
                            // Matches simplified patterns too
                            if (verseText.length > 20) {
                              final basmalaRegex = RegExp(
                                r'^[\s\u200F]*بِسْمِ\s+[اٱ]للَّهِ\s+[اٱ]لرَّحْمَ[ـٰa-z]*نِ\s+[اٱ]لرَّحِيمِ\s*',
                                caseSensitive: false,
                              );
                              if (basmalaRegex.hasMatch(verseText)) {
                                verseText = verseText
                                    .replaceFirst(basmalaRegex, '')
                                    .trim();
                              }
                            }
                          }
                        }

                        // Add Verse Text
                        spans.add(
                          TextSpan(
                            text: '\u200F$verseText ',
                            style: GoogleFonts.getFont(
                              settings.fontFamily,
                              fontSize: settings.fontSize,
                              height: 2.2,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  _showVerseOptions(context, verseNumber),
                          ),
                        );

                        // Add Verse Number/End Symbol
                        spans.add(
                          TextSpan(
                            text:
                                '${quran.getVerseEndSymbol(verseNumber, arabicNumeral: true)} ', // Added space after symbol
                            style: GoogleFonts.amiri(
                              fontSize: settings.fontSize,
                              color: AppTheme.primaryColor,
                              height: 2.2,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  _showVerseOptions(context, verseNumber),
                          ),
                        );
                      }

                      return SelectableText.rich(
                        TextSpan(children: spans),
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}

class _VerseOptionsSheet extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;

  const _VerseOptionsSheet({
    required this.surahNumber,
    required this.verseNumber,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {}, // TODO: Bookmarking
                    icon: const Icon(Icons.bookmark_border),
                    tooltip: 'حفظ العلامة',
                  ),
                  IconButton(
                    onPressed: () {}, // TODO: Copy text
                    icon: const Icon(Icons.copy),
                    tooltip: 'نسخ النص',
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    TafsirService().getTafsir(surahNumber, verseNumber),
                    TranslationService().getVerseTranslation(
                      surahNumber,
                      verseNumber,
                    ),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final tafsirVerse = snapshot.data![0] as TafsirVerse;
                    final translationVerse =
                        snapshot.data![1] as TranslatedVerse;

                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppTheme.primaryColor,
                            tabs: const [
                              Tab(text: 'الترجمة'),
                              Tab(text: 'التفسير'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildTranslationView(
                                  translationVerse,
                                  scrollController,
                                ),
                                _buildTafsirView(tafsirVerse, scrollController),
                              ],
                            ),
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
    );
  }

  Widget _buildTranslationView(
    TranslatedVerse verse,
    ScrollController controller,
  ) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          verse.arabicText,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(fontSize: 24, height: 2.0),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        ...verse.translations.entries.map(
          (e) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.key,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(e.value, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTafsirView(TafsirVerse verse, ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          verse.verseText,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(fontSize: 24, height: 2.0),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        ...verse.tafsirs.entries.map(
          (e) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                e.key.arabicName,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.value,
                style: const TextStyle(fontSize: 16, height: 1.6),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
