import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:werdy/services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 18.0;
  String _fontFamily = 'Amiri';

  bool _morningReminderEnabled = false;
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 6, minute: 0);

  bool _eveningReminderEnabled = false;
  TimeOfDay _eveningReminderTime = const TimeOfDay(hour: 18, minute: 0);

  String _languageCode = 'en';

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  String get languageCode => _languageCode;

  bool get morningReminderEnabled => _morningReminderEnabled;
  TimeOfDay get morningReminderTime => _morningReminderTime;

  bool get eveningReminderEnabled => _eveningReminderEnabled;
  TimeOfDay get eveningReminderTime => _eveningReminderTime;

  SettingsProvider() {
    _loadSettings();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveSettings();
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    _saveSettings();
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    _saveSettings();
    notifyListeners();
  }

  void setLanguage(String code) {
    _languageCode = code;
    _saveSettings();
    notifyListeners();
  }

  Future<void> setMorningReminder(bool enabled, {TimeOfDay? time}) async {
    _morningReminderEnabled = enabled;
    if (time != null) {
      _morningReminderTime = time;
    }

    if (_morningReminderEnabled) {
      await NotificationService().scheduleDailyNotification(
        1,
        'Morning Adhkar',
        'It\'s time for your morning Adhkar.',
        _morningReminderTime,
      );
    } else {
      await NotificationService().cancelNotification(1);
    }

    _saveSettings();
    notifyListeners();
  }

  Future<void> setEveningReminder(bool enabled, {TimeOfDay? time}) async {
    _eveningReminderEnabled = enabled;
    if (time != null) {
      _eveningReminderTime = time;
    }

    if (_eveningReminderEnabled) {
      await NotificationService().scheduleDailyNotification(
        2,
        'Evening Adhkar',
        'It\'s time for your evening Adhkar.',
        _eveningReminderTime,
      );
    } else {
      await NotificationService().cancelNotification(2);
    }

    _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _fontSize = prefs.getDouble('fontSize') ?? 18.0;
    _fontFamily = prefs.getString('fontFamily') ?? 'Amiri';
    _languageCode = prefs.getString('languageCode') ?? 'en';

    _morningReminderEnabled = prefs.getBool('morningReminderEnabled') ?? false;
    final mHour = prefs.getInt('morningReminderHour') ?? 6;
    final mMinute = prefs.getInt('morningReminderMinute') ?? 0;
    _morningReminderTime = TimeOfDay(hour: mHour, minute: mMinute);

    _eveningReminderEnabled = prefs.getBool('eveningReminderEnabled') ?? false;
    final eHour = prefs.getInt('eveningReminderHour') ?? 18;
    final eMinute = prefs.getInt('eveningReminderMinute') ?? 0;
    _eveningReminderTime = TimeOfDay(hour: eHour, minute: eMinute);

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setString('fontFamily', _fontFamily);
    await prefs.setString('languageCode', _languageCode);

    await prefs.setBool('morningReminderEnabled', _morningReminderEnabled);
    await prefs.setInt('morningReminderHour', _morningReminderTime.hour);
    await prefs.setInt('morningReminderMinute', _morningReminderTime.minute);

    await prefs.setBool('eveningReminderEnabled', _eveningReminderEnabled);
    await prefs.setInt('eveningReminderHour', _eveningReminderTime.hour);
    await prefs.setInt('eveningReminderMinute', _eveningReminderTime.minute);
  }
}
