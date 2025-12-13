import 'package:quran/quran.dart' as quran;

void main() {
  String verseText = quran.getVerse(2, 1);
  print('Original Verse 1 length: ${verseText.length}');
  print('Code units: ${verseText.codeUnits}');

  String basmala = quran.basmala;
  print('Basmala length: ${basmala.length}');
  print('Basmala Code units: ${basmala.codeUnits}');

  print('Starts with Basmala: ${verseText.startsWith(basmala)}');
}
