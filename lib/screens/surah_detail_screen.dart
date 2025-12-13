import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/services/audio_service.dart';
import 'package:werdy/services/tafsir_service.dart';
import 'package:werdy/services/translation_service.dart';
import 'package:werdy/models/reciter.dart';
import 'package:werdy/models/tafsir.dart';
import 'package:werdy/models/translation.dart';
import 'package:werdy/utils/app_theme.dart';
import 'package:werdy/widgets/surah_header_delegate.dart';
import 'package:werdy/utils/arab_numeral_converter.dart';
import 'package:werdy/screens/verse_image_screen.dart';
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
  bool _isPlaying = false;

  // Default Reciter (Can be moved to settings later)
  final Reciter _selectedReciter = Reciter(
    id: 'afasy',
    nameArabic: 'مشاري بن راشد العفاسي',
    nameEnglish: 'Mishari Rashid Al-Afasy',
    country: 'الكويت',
    style: 'مرتل',
    serverUrl: 'https://server8.mp3quran.net/afs/',
  );

  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _audioSubscription;
  bool _isAutoScrollEnabled = true;

  @override
  void initState() {
    super.initState();
    _setupAudioListener();
  }

  void _setupAudioListener() {
    _audioSubscription = AudioService().playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.state == PlaybackState.playing);

        if (_isAutoScrollEnabled &&
            state.state == PlaybackState.playing &&
            state.duration.inSeconds > 0 &&
            _scrollController.hasClients) {
          final double progress =
              state.position.inSeconds / state.duration.inSeconds;
          // Approximate scroll position: Progress * Total Scrollable Height
          // Logic: Verse density is roughly uniform.
          // Note: This is an approximation. Precise tracking requires timestamp data.

          final maxScroll = _scrollController.position.maxScrollExtent;
          final targetScroll = maxScroll * progress;

          // Only scroll if the difference is significant to avoid jitter
          if ((_scrollController.offset - targetScroll).abs() > 50) {
            _scrollController.animateTo(
              targetScroll,
              duration: const Duration(seconds: 1),
              curve: Curves.linear,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAutoScroll() {
    setState(() => _isAutoScrollEnabled = !_isAutoScrollEnabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAutoScrollEnabled
              ? 'تم تفعيل التمرير التلقائي'
              : 'تم إيقاف التمرير التلقائي',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleAudio() async {
    try {
      if (_isPlaying) {
        await AudioService().pause();
        // State update handled by stream listener
      } else {
        final track = RecitationTrack(
          reciterId: _selectedReciter.id,
          surahNumber: widget.surahNumber,
        );
        await AudioService().play(reciter: _selectedReciter, track: track);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
    }
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

            // Basmala (except Surah Tawbah/9)
            if (widget.surahNumber != 9)
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

            // Mushaf Style View
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5), // 0.02 * 255
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.grey.withAlpha(26), // 0.1 * 255
                    ),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: List.generate(verseCount, (index) {
                          final verseNumber = index + 1;
                          String verseText = quran.getVerse(
                            widget.surahNumber,
                            verseNumber,
                          );

                          // Logic to remove Basmala from the start of the first verse
                          if (verseNumber == 1 &&
                              widget.surahNumber != 1 &&
                              widget.surahNumber != 9) {
                            // Robust stripping using common Basmala patterns in Utmani script
                            // Matches "Bismillah..." with various diacritics and spacing
                            // The regex matches everything from start up to "Al-Rahim" and following spaces
                            final basmalaRegex = RegExp(
                              r'^[\s\S]*?الرَّحِيمِ\s*',
                              dotAll: true,
                            ); // With diacritics

                            if (verseText.startsWith('بِسْمِ')) {
                              verseText = verseText.replaceFirst(
                                basmalaRegex,
                                '',
                              );
                            } else if (_removeDiacritics(
                              verseText,
                            ).startsWith('بسم')) {
                              // Fallback if diacritics cause mismatch
                              // We use a manual substring approach or regex on cleaned text?
                              // Actually, the safest is to split by "Al-Rahim" if it starts with Bismillah.
                              final words = verseText.split(' ');
                              if (words.length > 4) {
                                // Basmala is usually 4 words: Bismi Allahi Alrahmani Alrahim
                                // We trust the visual check: if we render Basmala header, we strip the first ~4-5 words if they are Basmala
                                // Let's try matching the exact standard string from package if possible,
                                // or just use the _removeDiacritics logic which WAS working but maybe failed on specific cases.
                                // New logic:
                                if (_removeDiacritics(
                                  verseText,
                                ).startsWith('بسم الله الرحمن الرحيم')) {
                                  // Keep stripping words until we pass "Al-Rahim"
                                  // This reconstruction is safer
                                  int index = -1;
                                  for (int i = 0; i < words.length; i++) {
                                    if (_removeDiacritics(
                                      words[i],
                                    ).contains('الرحيم')) {
                                      index = i;
                                      break;
                                    }
                                  }
                                  if (index != -1 && index < words.length - 1) {
                                    verseText = words
                                        .sublist(index + 1)
                                        .join(' ');
                                  }
                                }
                              }
                            }
                          }

                          return TextSpan(
                            children: [
                              TextSpan(
                                // \u200F is Right-to-Left Mark (RLM) to ensure Strong RTL context
                                text: '\u200F$verseText ',
                                style: GoogleFonts.getFont(
                                  settings.fontFamily,
                                  fontSize: settings.fontSize,
                                  height:
                                      2.2, // Good line height for Mushaf reading
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      _showVerseOptions(context, verseNumber),
                              ),
                              TextSpan(
                                text: quran.getVerseEndSymbol(
                                  verseNumber,
                                  arabicNumeral: true,
                                ),
                                style: GoogleFonts.amiri(
                                  fontSize: settings
                                      .fontSize, // Same size or slightly smaller/larger if needed
                                  color: AppTheme.primaryColor,
                                  height: 2.2, // Match verse height
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      _showVerseOptions(context, verseNumber),
                              ),
                              const TextSpan(text: '  '), // Spacer
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "scroll_toggle",
            onPressed: _toggleAutoScroll,
            backgroundColor: _isAutoScrollEnabled
                ? AppTheme.secondaryColor
                : Colors.grey,
            child: Icon(
              _isAutoScrollEnabled ? Icons.sync : Icons.sync_disabled,
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: "play_pause",
            onPressed: _toggleAudio,
            backgroundColor: AppTheme.primaryColor,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(_isPlaying ? "إيقاف التلاوة" : "تشغيل تلاوة"),
          ),
        ],
      ),
    );
  }

  String _removeDiacritics(String text) {
    const diacritics = [
      '\u064B', // Fathatan
      '\u064C', // Dammatan
      '\u064D', // Kasratan
      '\u064E', // Fatha
      '\u064F', // Damma
      '\u0650', // Kasra
      '\u0651', // Shadda
      '\u0652', // Sukun
      '\u0670', // Dagger Alif
      '\u0671', // Wasla
    ];
    for (var diacritic in diacritics) {
      text = text.replaceAll(diacritic, '');
    }
    return text;
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
                    onPressed: () async {
                      // Fetch verse text and translation first?
                      // Actually we have them in the FutureBuilder below, but that's for display.
                      // We can fetch simpler data or pass it.
                      // For simplicity, let's fetch basic text here or pass it if possible.
                      // Ideally refactor to have data ready.
                      // Quick solution: Navigate and let the screen fetch or use what we have.
                      // But we don't have text here in the sheet widget directly, only ID.

                      final verseText = quran.getVerse(
                        surahNumber,
                        verseNumber,
                      );
                      // Translation is async, let's just pass empty for now or fetch it inside the new screen?
                      // Let's fetch it inside new screen or simple text.
                      // Actually, let's just pass Arabic for now + English basic.

                      Navigator.pop(context); // Close sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerseImageGeneratorScreen(
                            surahName: quran.getSurahNameArabic(surahNumber),
                            verseNumber: verseNumber,
                            verseText: verseText,
                            translationText: quran.getVerseTranslation(
                              surahNumber,
                              verseNumber,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.image),
                    tooltip: 'مشاركة كصورة',
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
