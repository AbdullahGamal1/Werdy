import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:werdy/utils/app_theme.dart';

class MemorizationQuizScreen extends StatefulWidget {
  const MemorizationQuizScreen({super.key});

  @override
  State<MemorizationQuizScreen> createState() => _MemorizationQuizScreenState();
}

class _MemorizationQuizScreenState extends State<MemorizationQuizScreen> {
  int _score = 0;
  int _currentSurah = 1;
  int _currentVerse = 1;
  String _questionText = '';
  String _correctAnswer = '';
  List<String> _options = [];
  bool _answered = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      _answered = false;
      _selectedOption = null;

      // Randomly select Surah (let's stick to Juz Amma for simplicity or random)
      // Random surah from 78 to 114 (Juz Amma) to make it easier for average users
      _currentSurah = 78 + Random().nextInt(37);
      int verseCount = quran.getVerseCount(_currentSurah);
      _currentVerse = Random().nextInt(verseCount) + 1;

      String fullVerse = quran.getVerse(_currentSurah, _currentVerse);
      List<String> words = fullVerse.split(' ');

      if (words.length < 3) {
        // Retry if verse is too short
        _generateQuestion();
        return;
      }

      // Hide a random word
      int hiddenIndex = Random().nextInt(words.length);
      _correctAnswer = words[hiddenIndex];

      // Create question text with blank
      List<String> questionWords = List.from(words);
      questionWords[hiddenIndex] = '_____';
      _questionText = questionWords.join(' ');

      // Generate options
      _options = [_correctAnswer];
      while (_options.length < 4) {
        // Pick random words from other verses in same Surah
        int randomVerseObj = Random().nextInt(verseCount) + 1;
        String randomVerseText = quran.getVerse(_currentSurah, randomVerseObj);
        List<String> randomWords = randomVerseText.split(' ');
        String randomWord = randomWords[Random().nextInt(randomWords.length)];

        if (!_options.contains(randomWord)) {
          _options.add(randomWord);
        }
      }
      _options.shuffle();
    });
  }

  void _checkAnswer(String selected) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedOption = selected;
      if (selected == _correctAnswer) {
        _score += 10;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('إجابة صحيحة! أحسنت'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('إجابة خاطئة. الصحيح: $_correctAnswer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Next question after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار الحفظ'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'النقاط: $_score',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${quran.getSurahNameArabic(_currentSurah)} : $_currentVerse',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'أكمل الآية:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Text(
              _questionText,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 28,
                height: 1.8,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: _options.map((option) {
                Color btnColor = AppTheme.primaryColor;
                if (_answered) {
                  if (option == _correctAnswer) {
                    btnColor = Colors.green;
                  } else if (option == _selectedOption) {
                    btnColor = Colors.red;
                  } else {
                    btnColor = Colors.grey;
                  }
                }

                return ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(option, style: GoogleFonts.amiri(fontSize: 18)),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
