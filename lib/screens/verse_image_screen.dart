import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:werdy/utils/app_theme.dart';

class VerseImageGeneratorScreen extends StatefulWidget {
  final String surahName;
  final int verseNumber;
  final String verseText;
  final String translationText;

  const VerseImageGeneratorScreen({
    super.key,
    required this.surahName,
    required this.verseNumber,
    required this.verseText,
    required this.translationText,
  });

  @override
  State<VerseImageGeneratorScreen> createState() =>
      _VerseImageGeneratorScreenState();
}

class _VerseImageGeneratorScreenState extends State<VerseImageGeneratorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  int _selectedStyleIndex = 0;

  final List<Map<String, dynamic>> _styles = [
    {
      'name': 'Royal Gold',
      'gradient': const LinearGradient(
        colors: [Color(0xFF1a2a6c), Color(0xFFb21f1f), Color(0xFFfdbb2d)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Colors.white,
    },
    {
      'name': 'Emerald',
      'gradient': const LinearGradient(
        colors: [Color(0xFF134E5E), Color(0xFF71B280)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Colors.white,
    },
    {
      'name': 'Midnight',
      'gradient': const LinearGradient(
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Colors.white,
    },
    {
      'name': 'Paper',
      'gradient': const LinearGradient(
        colors: [Color(0xFFFDFBF7), Color(0xFFF3E7E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Colors.black87,
    },
  ];

  bool _isSharing = false;

  Future<void> _shareImage() async {
    setState(() => _isSharing = true);
    try {
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 2.0, // High res
      );

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File(
          '${directory.path}/verse_share.png',
        ).create();
        await imagePath.writeAsBytes(image);

        // Share plugin usage
        await Share.shareXFiles([
          XFile(imagePath.path),
        ], text: 'سورة ${widget.surahName} - آية ${widget.verseNumber}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styles[_selectedStyleIndex];
    final gradient = style['gradient'] as Gradient;
    final textColor = style['textColor'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مشاركة الآية'),
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.share),
            onPressed: _isSharing ? null : _shareImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decorative Header
                        Icon(
                          Icons.format_quote_rounded,
                          color: textColor.withOpacity(0.5),
                          size: 40,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          widget.verseText,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            fontSize: 26,
                            height: 2.0,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (widget.translationText.isNotEmpty) ...[
                          Text(
                            widget.translationText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Divider(color: textColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'سورة ${widget.surahName}',
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: textColor.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              'آية ${widget.verseNumber}',
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'تطبيق وردي',
                          style: TextStyle(
                            color: textColor.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختر التصميم',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _styles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedStyleIndex = index),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: _styles[index]['gradient'] as Gradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedStyleIndex == index
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: _selectedStyleIndex == index
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
