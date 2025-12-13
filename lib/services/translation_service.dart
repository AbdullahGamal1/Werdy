import 'package:werdy/models/translation.dart';
import 'package:quran/quran.dart' as quran;

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  TranslationSettings _settings = TranslationSettings(
    enabledTranslationIds: ['en_sahih_international'],
  );

  final Map<String, TranslatedVerse> _cache = {};

  // Initialize service
  Future<void> initialize() async {
    // Load settings from prefs if needed
  }

  TranslationSettings get settings => _settings;

  Future<void> updateSettings(TranslationSettings settings) async {
    _settings = settings;
    // save
  }

  // Get translation for a verse
  Future<TranslatedVerse> getVerseTranslation(int surah, int verse) async {
    final key = '$surah:$verse';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Use `quran` package for English translation if available?
    // The `quran` package usually has `getVerseTranslation` but it's often minimal.
    // Let's check if `quran` package has built-in translation. It typically does for English.

    String englishText = "";
    try {
      englishText = quran.getVerseTranslation(surah, verse);
    } catch (e) {
      englishText = "Translation not available.";
    }

    final translatedVerse = TranslatedVerse(
      surahNumber: surah,
      verseNumber: verse,
      arabicText: quran.getVerse(surah, verse),
      translations: {
        'en_sahih_international': englishText,
        'fr_hamidullah':
            'Traduction française simple pour verset $verse (Démo)',
        'ur_jalandhry': 'اردو ترجمہ (ڈیمو)',
      },
    );

    _cache[key] = translatedVerse;
    return translatedVerse;
  }

  List<Translation> getAvailableTranslations() {
    return Translation.availableTranslations;
  }
}
