import 'package:quran/quran.dart' as quran;

void main() {
  // Surah 2 (Baqarah), Verse 1
  String verseText = quran.getVerse(2, 1);
  print('Original Verse 1 (Baqarah): "$verseText"');

  const List<String> basmalaVariants = [
    quran.basmala,
    "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", // Uthmani with Wasla
    "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", // Simple
    "بسم الله الرحمن الرحيم", // Plain
  ];

  String processedText = verseText;
  bool stripped = false;
  for (final variant in basmalaVariants) {
    if (verseText.startsWith(variant)) {
      print('Found variant: "$variant"');
      processedText = verseText.substring(variant.length).trim();
      stripped = true;
      break;
    }
  }

  print('Processed Verse 1: "$processedText"');
  print('Stripped: $stripped');

  // Verify expected start
  if (processedText.startsWith("الم")) {
    print("SUCCESS: Starts with Alif Lam Mim");
  } else {
    print("FAILURE: Does not start with Alif Lam Mim");
  }
}
