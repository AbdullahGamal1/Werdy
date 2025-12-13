import 'package:quran/quran.dart' as quran;

void main() {
  String verseText = quran.getVerse(2, 1);

  // Logic to test: Find "Al-Rahim" and cut after it.
  // "Al-Rahim" normalized is "lrhym" roughly?
  // Let's rely on standard Arabic letters.

  String removeDiacritics(String text) {
    return text.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u0671\u06D6-\u06ED\u06E5\u06E6]'),
      '',
    );
  }

  String normalized = removeDiacritics(verseText);
  print("Normalized: $normalized");

  // Basmala usually ends with "Al-Rahim" -> "الرحيم"
  String targetEnd = "الرحيم";
  int idx = normalized.indexOf(targetEnd);

  print("Index of Rahim: $idx");

  if (idx != -1 && idx < 50) {
    // Find the corresponding index in the ORIGINAL string.
    // This is hard because mapped indices don't align.

    // Alternative: Just split by spaces and check word content?
    List<String> words = verseText.split(' ');
    print("Word count: ${words.length}");
    print("First 5 words: ${words.take(5).toList()}");

    // Check if 3rd or 4th word contains "Rahim"
    int rahimIndex = -1;
    for (int i = 0; i < (words.length < 10 ? words.length : 10); i++) {
      if (removeDiacritics(words[i]).contains("الرحيم")) {
        rahimIndex = i;
        break;
      }
    }
    print("Rahim Word Index: $rahimIndex");

    if (rahimIndex != -1) {
      String newText = words.sublist(rahimIndex + 1).join(' ');
      print("Stripped Text: $newText");
    }
  }
}
