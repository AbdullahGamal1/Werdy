import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:werdy/utils/app_theme.dart';

class QuranRadioScreen extends StatefulWidget {
  const QuranRadioScreen({super.key});

  @override
  State<QuranRadioScreen> createState() => _QuranRadioScreenState();
}

class _QuranRadioScreenState extends State<QuranRadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentStationUrl;
  bool _isPlaying = false;
  bool _isLoading = false;

  final List<Map<String, String>> stations = [
    {
      'name': 'إذاعة القرآن الكريم - القاهرة',
      'url':
          'https://stream.radiojar.com/8s5u5tpdtwzuv', // Generic example or find real URL
      'image': 'assets/images/radio_cairo.png', // Placeholder
    },
    {
      'name': 'إذاعة القرآن الكريم - مكة المكرمة',
      'url': 'https://stream.radiojar.com/4wqre23f48zuv', // Placeholder URL
      'image': 'assets/images/radio_makkah.png',
    },
    {
      'name': 'مشاري العفاسي - بث مباشر',
      'url': 'https://qurango.net/radio/mishary_alafasi',
    },
    {
      'name': 'عبدالباسط عبد الصمد - بث مباشر',
      'url': 'https://qurango.net/radio/abdulbasit_abdulsamad_warsh',
    },
    {
      'name': 'ماهر المعيقلي - بث مباشر',
      'url': 'https://qurango.net/radio/maher_al_muaiqly',
    },
  ];

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playStation(String url) async {
    try {
      if (_currentStationUrl == url && _isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
      } else {
        setState(() {
          _isLoading = true;
          _currentStationUrl = url;
        });
        await _player.setUrl(url);
        await _player.play();
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تشغيل الإذاعة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('راديو القرآن'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: stations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final station = stations[index];
          final isSelected = _currentStationUrl == station['url'];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.radio, color: AppTheme.primaryColor),
              ),
              title: Text(
                station['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                onPressed: () => _playStation(station['url']!),
                icon: _isLoading && isSelected
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isSelected && _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
