import 'package:quran/quran.dart' as quran;

void main() {
  String verseText = quran.getVerse(2, 1);
  String basmala = quran.basmala;

  print(
    "Verse Text (First 100 chars): ${verseText.substring(0, verseText.length > 100 ? 100 : verseText.length)}",
  );
  print("Basmala: $basmala");

  // Normalize both by removing ALL non-letter characters (diacritics, symbols)
  // Keep only Arabic Letters matches [\u0600-\u06FF] but exclude diacritics.
  // Actually simpler: just compare pure code units of the start.

  print("\n--- COMPARISON ---");
  int minLen = verseText.length < basmala.length
      ? verseText.length
      : basmala.length;
  for (int i = 0; i < minLen; i++) {
    int vCode = verseText.codeUnitAt(i);
    int bCode = basmala.codeUnitAt(i);
    if (vCode != bCode) {
      print(
        "Mismatch at index $i: Verse='$vCode' (${String.fromCharCode(vCode)}), Basmala='$bCode' (${String.fromCharCode(bCode)})",
      );
      break;
    }
  }

  print("\n--- REMOVE DIACRITICS TEST ---");
  // Try a simple regex approach first
  String clean(String s) {
    return s.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u0671\u06D6-\u06ED]'),
      '',
    );
  }

  String cleanVerse = clean(verseText);
  String cleanBas = clean(basmala);

  print(
    "Clean Verse Start: ${cleanVerse.substring(0, cleanVerse.length > 50 ? 50 : cleanVerse.length)}",
  );
  print("Clean Basmala: $cleanBas");
  print("Clean StartsWith: ${cleanVerse.startsWith(cleanBas)}");
}
