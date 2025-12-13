// Prayer Times Model - نموذج مواقيت الصلاة

import 'package:adhan/adhan.dart';

enum PrayerName {
  fajr('الفجر', 'Fajr'),
  sunrise('الشروق', 'Sunrise'),
  dhuhr('الظهر', 'Dhuhr'),
  asr('العصر', 'Asr'),
  maghrib('المغرب', 'Maghrib'),
  isha('العشاء', 'Isha');

  final String arabicName;
  final String englishName;

  const PrayerName(this.arabicName, this.englishName);
}

class PrayerTime {
  final PrayerName name;
  final DateTime time;
  final bool notificationEnabled;

  PrayerTime({
    required this.name,
    required this.time,
    this.notificationEnabled = true,
  });

  PrayerTime copyWith({
    PrayerName? name,
    DateTime? time,
    bool? notificationEnabled,
  }) {
    return PrayerTime(
      name: name ?? this.name,
      time: time ?? this.time,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }

  // Check if this prayer time is in the past
  bool get isPast => time.isBefore(DateTime.now());

  // Check if this prayer time is next
  bool isNext(List<PrayerTime> allPrayers) {
    final now = DateTime.now();
    final futurePrayers = allPrayers.where((p) => p.time.isAfter(now)).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return futurePrayers.isNotEmpty && futurePrayers.first.name == name;
  }

  // Time remaining until prayer
  Duration get timeRemaining {
    final now = DateTime.now();
    if (time.isBefore(now)) {
      return Duration.zero;
    }
    return time.difference(now);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.name,
      'time': time.toIso8601String(),
      'notificationEnabled': notificationEnabled,
    };
  }

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      name: PrayerName.values.firstWhere(
        (e) => e.name == json['name'],
        orElse: () => PrayerName.fajr,
      ),
      time: DateTime.parse(json['time'] as String),
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
    );
  }
}

class DailyPrayerTimes {
  final DateTime date;
  final PrayerTime fajr;
  final PrayerTime sunrise;
  final PrayerTime dhuhr;
  final PrayerTime asr;
  final PrayerTime maghrib;
  final PrayerTime isha;

  DailyPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<PrayerTime> get allPrayers => [fajr, sunrise, dhuhr, asr, maghrib, isha];

  // Get next prayer
  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    final futurePrayers = allPrayers.where((p) => p.time.isAfter(now)).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return futurePrayers.isNotEmpty ? futurePrayers.first : null;
  }

  // Get current prayer (the one that just passed)
  PrayerTime? get currentPrayer {
    final now = DateTime.now();
    final pastPrayers = allPrayers.where((p) => p.time.isBefore(now)).toList()
      ..sort((a, b) => b.time.compareTo(a.time));
    return pastPrayers.isNotEmpty ? pastPrayers.first : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'fajr': fajr.toJson(),
      'sunrise': sunrise.toJson(),
      'dhuhr': dhuhr.toJson(),
      'asr': asr.toJson(),
      'maghrib': maghrib.toJson(),
      'isha': isha.toJson(),
    };
  }

  factory DailyPrayerTimes.fromJson(Map<String, dynamic> json) {
    return DailyPrayerTimes(
      date: DateTime.parse(json['date'] as String),
      fajr: PrayerTime.fromJson(json['fajr'] as Map<String, dynamic>),
      sunrise: PrayerTime.fromJson(json['sunrise'] as Map<String, dynamic>),
      dhuhr: PrayerTime.fromJson(json['dhuhr'] as Map<String, dynamic>),
      asr: PrayerTime.fromJson(json['asr'] as Map<String, dynamic>),
      maghrib: PrayerTime.fromJson(json['maghrib'] as Map<String, dynamic>),
      isha: PrayerTime.fromJson(json['isha'] as Map<String, dynamic>),
    );
  }

  // Calculate prayer times using Adhan package
  static DailyPrayerTimes calculate({
    required double latitude,
    required double longitude,
    DateTime? date,
    CalculationMethod? method,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final calculationDate = DateComponents.from(date ?? DateTime.now());
    final params =
        method?.getParameters() ??
        CalculationMethod.muslim_world_league.getParameters();

    final prayerTimes = PrayerTimes(coordinates, calculationDate, params);

    return DailyPrayerTimes(
      date: date ?? DateTime.now(),
      fajr: PrayerTime(name: PrayerName.fajr, time: prayerTimes.fajr),
      sunrise: PrayerTime(name: PrayerName.sunrise, time: prayerTimes.sunrise),
      dhuhr: PrayerTime(name: PrayerName.dhuhr, time: prayerTimes.dhuhr),
      asr: PrayerTime(name: PrayerName.asr, time: prayerTimes.asr),
      maghrib: PrayerTime(name: PrayerName.maghrib, time: prayerTimes.maghrib),
      isha: PrayerTime(name: PrayerName.isha, time: prayerTimes.isha),
    );
  }
}

class PrayerConfig {
  final CalculationMethod calculationMethod;
  final Madhab madhab; // Hanafi or Shafi
  final int adjustmentMinutes; // Global time adjustment
  final Map<PrayerName, int> individualAdjustments;
  final bool enableNotifications;
  final int notificationMinutesBefore;

  PrayerConfig({
    this.calculationMethod = CalculationMethod.muslim_world_league,
    this.madhab = Madhab.shafi,
    this.adjustmentMinutes = 0,
    this.individualAdjustments = const {},
    this.enableNotifications = true,
    this.notificationMinutesBefore = 15,
  });

  PrayerConfig copyWith({
    CalculationMethod? calculationMethod,
    Madhab? madhab,
    int? adjustmentMinutes,
    Map<PrayerName, int>? individualAdjustments,
    bool? enableNotifications,
    int? notificationMinutesBefore,
  }) {
    return PrayerConfig(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      adjustmentMinutes: adjustmentMinutes ?? this.adjustmentMinutes,
      individualAdjustments:
          individualAdjustments ?? this.individualAdjustments,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      notificationMinutesBefore:
          notificationMinutesBefore ?? this.notificationMinutesBefore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calculationMethod': calculationMethod.name,
      'madhab': madhab.name,
      'adjustmentMinutes': adjustmentMinutes,
      'individualAdjustments': individualAdjustments.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'enableNotifications': enableNotifications,
      'notificationMinutesBefore': notificationMinutesBefore,
    };
  }

  factory PrayerConfig.fromJson(Map<String, dynamic> json) {
    return PrayerConfig(
      calculationMethod: CalculationMethod.values.firstWhere(
        (e) => e.name == json['calculationMethod'],
        orElse: () => CalculationMethod.muslim_world_league,
      ),
      madhab: Madhab.values.firstWhere(
        (e) => e.name == json['madhab'],
        orElse: () => Madhab.shafi,
      ),
      adjustmentMinutes: json['adjustmentMinutes'] as int? ?? 0,
      individualAdjustments:
          (json['individualAdjustments'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              PrayerName.values.firstWhere((e) => e.name == k),
              v as int,
            ),
          ) ??
          {},
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      notificationMinutesBefore:
          json['notificationMinutesBefore'] as int? ?? 15,
    );
  }
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? countryName;
  final String? timezone;
  final bool isManual;
  final DateTime lastUpdated;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.countryName,
    this.timezone,
    this.isManual = false,
    required this.lastUpdated,
  });

  LocationInfo copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    String? countryName,
    String? timezone,
    bool? isManual,
    DateTime? lastUpdated,
  }) {
    return LocationInfo(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      timezone: timezone ?? this.timezone,
      isManual: isManual ?? this.isManual,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String get displayName {
    if (cityName != null && countryName != null) {
      return '$cityName, $countryName';
    } else if (cityName != null) {
      return cityName!;
    } else {
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'countryName': countryName,
      'timezone': timezone,
      'isManual': isManual,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['cityName'] as String?,
      countryName: json['countryName'] as String?,
      timezone: json['timezone'] as String?,
      isManual: json['isManual'] as bool? ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
