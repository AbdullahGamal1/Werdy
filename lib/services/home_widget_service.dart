import 'dart:math';
import 'package:home_widget/home_widget.dart';
import 'package:quran/quran.dart' as quran;

class HomeWidgetService {
  static const String appGroupId =
      'group.com.example.werdy'; // For iOS/Android sharing if needed
  static const String androidWidgetName = 'HomeWidgetProvider';

  static Future<void> updateWidget() async {
    try {
      // Get a random verse
      final int surahNumber = Random().nextInt(114) + 1;
      final int verseCount = quran.getVerseCount(surahNumber);
      final int verseNumber = Random().nextInt(verseCount) + 1;

      final String verseText = quran.getVerse(surahNumber, verseNumber);
      final String surahName = quran.getSurahNameArabic(surahNumber);

      final String widgetText = '$surahName - آية $verseNumber\n\n$verseText';

      // Save data
      await HomeWidget.saveWidgetData<String>('verse_text', widgetText);

      // Update widget
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: 'HomeWidget', // If iOS is supported later
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
}
