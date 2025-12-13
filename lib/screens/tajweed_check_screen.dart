import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:werdy/utils/app_theme.dart';

class TajweedCheckScreen extends StatefulWidget {
  const TajweedCheckScreen({super.key});

  @override
  State<TajweedCheckScreen> createState() => _TajweedCheckScreenState();
}

class _TajweedCheckScreenState extends State<TajweedCheckScreen> {
  bool _isRecording = false;
  bool _isAnalyzing = false;
  int _recordingDuration = 0;
  Timer? _timer;

  Map<String, dynamic>? _result;

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _result = null;
      _recordingDuration = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    // Simulate analysis delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _generateMockResult();
      }
    });
  }

  void _generateMockResult() {
    final random = Random();
    final score = 70 + random.nextInt(30); // 70-99

    List<String> feedbacks = [
      'أحسنت في المد المتصل',
      'انتبه للقلقلة في حرف الدال',
      'حاول تحسين الغنة',
      'مخارج الحروف ممتازة',
      'التلاوة هادئة وجميلة',
    ];

    String feedback = feedbacks[random.nextInt(feedbacks.length)];
    if (score > 90) feedback = 'تلاوة رائعة! ما شاء الله';

    setState(() {
      _isAnalyzing = false;
      _result = {'score': score, 'feedback': feedback};
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحح الآلي (تجرييي)'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_result == null && !_isAnalyzing) ...[
              const Icon(Icons.mic_none, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'اضغط للتسجيل واقرأ أي آية\nوسيقوم الذكاء الاصطناعي بتقييم تلاوتك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],

            if (_isRecording) ...[
              const Icon(Icons.mic, size: 100, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                _formatDuration(_recordingDuration),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('جاري الاستماع...', style: TextStyle(fontSize: 18)),
            ],

            if (_isAnalyzing) ...[
              const CircularProgressIndicator(strokeWidth: 6),
              const SizedBox(height: 32),
              const Text(
                'جاري تحليل التجويد...',
                style: TextStyle(fontSize: 18),
              ),
            ],

            if (_result != null) ...[
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getScoreColor(_result!['score']),
                    width: 8,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_result!['score']}%',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(_result!['score']),
                      ),
                    ),
                    const Text(
                      'النتيجة',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: _getScoreColor(_result!['score']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _result!['feedback'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],

            const Spacer(),

            if (!_isAnalyzing)
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: FloatingActionButton.large(
                  onPressed: _toggleRecording,
                  backgroundColor: _isRecording
                      ? Colors.red
                      : AppTheme.primaryColor,
                  child: Icon(_isRecording ? Icons.stop : Icons.mic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
