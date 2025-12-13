// Prayer Times Service - خدمة مواقيت الصلاة

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/prayer_time.dart';
import 'notification_service.dart';

class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  PrayerTimesService._internal();

  static const String _locationKey = 'prayer_location';
  static const String _configKey = 'prayer_config';

  LocationInfo? _currentLocation;
  PrayerConfig _config = PrayerConfig();
  DailyPrayerTimes? _todayPrayerTimes;

  // Get current location
  Future<LocationInfo> getCurrentLocation() async {
    if (_currentLocation != null) {
      return _currentLocation!;
    }

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        isManual: false,
        lastUpdated: DateTime.now(),
      );

      await _saveLocation();
      return _currentLocation!;
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  // Set manual location
  Future<void> setManualLocation({
    required double latitude,
    required double longitude,
    String? cityName,
    String? countryName,
  }) async {
    _currentLocation = LocationInfo(
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
      countryName: countryName,
      isManual: true,
      lastUpdated: DateTime.now(),
    );

    await _saveLocation();
    await calculatePrayerTimes();
  }

  // Calculate prayer times for today
  Future<DailyPrayerTimes> calculatePrayerTimes({DateTime? date}) async {
    if (_currentLocation == null) {
      await getCurrentLocation();
    }

    if (_currentLocation == null) {
      throw Exception('Location not available');
    }

    _todayPrayerTimes = DailyPrayerTimes.calculate(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      date: date,
      method: _config.calculationMethod,
    );

    // Schedule notifications
    if (_config.enableNotifications) {
      await _scheduleNotifications(_todayPrayerTimes!);
    }

    return _todayPrayerTimes!;
  }

  // Get today's prayer times (cached)
  DailyPrayerTimes? getTodayPrayerTimes() {
    return _todayPrayerTimes;
  }

  // Get prayer times for a specific date
  Future<DailyPrayerTimes> getPrayerTimesForDate(DateTime date) async {
    if (_currentLocation == null) {
      await getCurrentLocation();
    }

    if (_currentLocation == null) {
      throw Exception('Location not available');
    }

    return DailyPrayerTimes.calculate(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      date: date,
      method: _config.calculationMethod,
    );
  }

  // Update prayer config
  Future<void> updateConfig(PrayerConfig config) async {
    _config = config;
    await _saveConfig();

    // Recalculate prayer times
    await calculatePrayerTimes();
  }

  PrayerConfig getConfig() {
    return _config;
  }

  // Schedule prayer notifications
  Future<void> _scheduleNotifications(DailyPrayerTimes prayerTimes) async {
    final notificationService = NotificationService();

    // Cancel existing prayer notifications
    for (int i = 10; i <= 15; i++) {
      await notificationService.cancelNotification(i);
    }

    if (!_config.enableNotifications) return;

    final prayers = [
      (prayerTimes.fajr, 10, 'Fajr Prayer', 'صلاة الفجر'),
      (prayerTimes.dhuhr, 11, 'Dhuhr Prayer', 'صلاة الظهر'),
      (prayerTimes.asr, 12, 'Asr Prayer', 'صلاة العصر'),
      (prayerTimes.maghrib, 13, 'Maghrib Prayer', 'صلاة المغرب'),
      (prayerTimes.isha, 14, 'Isha Prayer', 'صلاة العشاء'),
    ];

    for (final prayer in prayers) {
      if (prayer.$1.notificationEnabled) {
        final notificationTime = prayer.$1.time.subtract(
          Duration(minutes: _config.notificationMinutesBefore),
        );

        // Only schedule if in the future
        if (notificationTime.isAfter(DateTime.now())) {
          await notificationService.scheduleNotificationAtTime(
            prayer.$2,
            prayer.$4, // Arabic name
            'حان وقت ${prayer.$4}',
            notificationTime,
          );
        }
      }
    }
  }

  // Load saved location
  Future<void> loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationJson = prefs.getString(_locationKey);

    if (locationJson != null) {
      _currentLocation = LocationInfo.fromJson(
        json.decode(locationJson) as Map<String, dynamic>,
      );
    }
  }

  // Save location
  Future<void> _saveLocation() async {
    if (_currentLocation == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _locationKey,
      json.encode(_currentLocation!.toJson()),
    );
  }

  // Load config
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);

    if (configJson != null) {
      _config = PrayerConfig.fromJson(
        json.decode(configJson) as Map<String, dynamic>,
      );
    }
  }

  // Save config
  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, json.encode(_config.toJson()));
  }

  // Initialize service
  Future<void> initialize() async {
    await loadLocation();
    await loadConfig();

    // Calculate prayer times if location is available
    if (_currentLocation != null) {
      await calculatePrayerTimes();
    }
  }
}
