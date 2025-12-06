import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/utils/app_theme.dart';

class SurahDetailScreen extends StatelessWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Hero(
          tag: 'surah_name_$surahNumber',
          child: Text(
            surahName,
            style: GoogleFonts.getFont(
              settings.fontFamily,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.secondaryColor
                  : AppTheme.primaryColor,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            if (surahNumber != 9) ...[
              Center(
                child: Text(
                  quran.basmala,
                  style: GoogleFonts.getFont(
                    settings.fontFamily,
                    fontSize: 24,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: [
                  for (int i = 1;
                      i <= quran.getVerseCount(surahNumber);
                      i++) ...[
                    (() {
                      String verseText = quran.getVerse(surahNumber, i);
                      if (i == 1 && surahNumber != 1 && surahNumber != 9) {
                        // Check for standard Basmala (from package)
                        if (verseText.startsWith(quran.basmala)) {
                          verseText =
                              verseText.substring(quran.basmala.length).trim();
                        }
                        // Check for Simple Alef variant (common in some text versions)
                        else {
                          // Construct the variant with standard Alef (0x0627) instead of Alef Wasla (0x0671)
                          // Or just matching the prefix blindly if it starts with 'Bismi'
                          const String basmalaSimple =
                              "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ";
                          if (verseText.startsWith(basmalaSimple)) {
                            verseText = verseText
                                .substring(basmalaSimple.length)
                                .trim();
                          }
                        }
                      }
                      return TextSpan(
                        text: ' $verseText ',
                        style: GoogleFonts.getFont(
                          settings.fontFamily,
                          fontSize: settings.fontSize,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          height: 2.2,
                        ),
                      );
                    }()),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.secondaryColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$i',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
