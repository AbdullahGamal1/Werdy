import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:werdy/models/prayer_time.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/services/prayer_times_service.dart';
import 'package:werdy/utils/app_strings.dart';
import 'package:werdy/utils/app_theme.dart';
import 'package:werdy/screens/qibla_screen.dart'; // Direct link if needed

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  DailyPrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final times = await PrayerTimesService().calculatePrayerTimes();
      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('prayer_times', settings.languageCode),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.explore), // Qibla Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QiblaScreen()),
              );
            },
            tooltip: AppStrings.get('qibla_direction', settings.languageCode),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadPrayerTimes();
                    },
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPrayerTimes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Date Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, Color(0xFF067D73)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                settings.languageCode == 'ar'
                                    ? 'موقعك الحالي'
                                    : 'Current Location',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat(
                              'EEEE, d MMMM yyyy',
                            ).format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Next Prayer Highlight
                          _buildNextPrayerHighlight(settings),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Prayer List
                    _buildPrayerItem(
                      'Fajr',
                      'الفجر',
                      _prayerTimes!.fajr.time,
                      settings,
                      isDark,
                      Icons.wb_twilight,
                    ),
                    _buildPrayerItem(
                      'Sunrise',
                      'الشروق',
                      _prayerTimes!.sunrise.time,
                      settings,
                      isDark,
                      Icons.wb_sunny_outlined,
                      isPrayer: false,
                    ),
                    _buildPrayerItem(
                      'Dhuhr',
                      'الظهر',
                      _prayerTimes!.dhuhr.time,
                      settings,
                      isDark,
                      Icons.wb_sunny,
                    ),
                    _buildPrayerItem(
                      'Asr',
                      'العصر',
                      _prayerTimes!.asr.time,
                      settings,
                      isDark,
                      Icons.sunny_snowing,
                    ),
                    _buildPrayerItem(
                      'Maghrib',
                      'المغرب',
                      _prayerTimes!.maghrib.time,
                      settings,
                      isDark,
                      Icons.nights_stay_outlined,
                    ),
                    _buildPrayerItem(
                      'Isha',
                      'العشاء',
                      _prayerTimes!.isha.time,
                      settings,
                      isDark,
                      Icons.nights_stay,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNextPrayerHighlight(SettingsProvider settings) {
    if (_prayerTimes == null) return const SizedBox.shrink();

    // Logic to find next prayer is simple comparison
    // This is just a UI highlight, actual logic might be in service

    // Placeholder for now
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Next: Asr', // Placeholder
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '03:45 PM', // Placeholder
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerItem(
    String engName,
    String arName,
    DateTime time,
    SettingsProvider settings,
    bool isDark,
    IconData icon, {
    bool isPrayer = true,
  }) {
    final timeStr = DateFormat('hh:mm a').format(time);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            settings.languageCode == 'ar' ? arName : engName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontFamily:
                  'Lato', // Enforce English font for numbers/time usually?
            ),
          ),
          if (isPrayer) ...[
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.notifications_active_outlined, size: 20),
              onPressed: () {
                // Toggle notification
              },
              color: Colors.grey,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
