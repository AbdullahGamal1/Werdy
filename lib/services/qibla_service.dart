// Qibla Service - خدمة اتجاه القبلة

import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class QiblaService {
  static final QiblaService _instance = QiblaService._internal();
  factory QiblaService() => _instance;
  QiblaService._internal();

  // Kaaba coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  // Calculate Qibla direction from current location
  Future<QiblaDirection> calculateQiblaDirection() async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final direction = _calculateQibla(position.latitude, position.longitude);

      return QiblaDirection(
        qiblaDirection: direction,
        userLatitude: position.latitude,
        userLongitude: position.longitude,
      );
    } catch (e) {
      print('Error calculating Qibla direction: $e');
      rethrow;
    }
  }

  // Calculate Qibla direction from specific coordinates
  QiblaDirection calculateQiblaFromCoordinates(
    double latitude,
    double longitude,
  ) {
    final direction = _calculateQibla(latitude, longitude);

    return QiblaDirection(
      qiblaDirection: direction,
      userLatitude: latitude,
      userLongitude: longitude,
    );
  }

  // Internal calculation method
  double _calculateQibla(double latitude, double longitude) {
    // Convert to radians
    final lat1 = _toRadians(latitude);
    final lon1 = _toRadians(longitude);
    final lat2 = _toRadians(kaabaLatitude);
    final lon2 = _toRadians(kaabaLongitude);

    // Calculate bearing
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x);

    // Convert to degrees
    final degrees = _toDegrees(bearing);

    // Normalize to 0-360
    return (degrees + 360) % 360;
  }

  // Calculate distance to Kaaba in kilometers
  double calculateDistanceToKaaba(double latitude, double longitude) {
    const earthRadius = 6371.0; // km

    final lat1 = _toRadians(latitude);
    final lon1 = _toRadians(longitude);
    final lat2 = _toRadians(kaabaLatitude);
    final lon2 = _toRadians(kaabaLongitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // Helper methods
  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  double _toDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  // Get direction name in Arabic
  String getDirectionName(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'شمال';
    if (degrees >= 22.5 && degrees < 67.5) return 'شمال شرق';
    if (degrees >= 67.5 && degrees < 112.5) return 'شرق';
    if (degrees >= 112.5 && degrees < 157.5) return 'جنوب شرق';
    if (degrees >= 157.5 && degrees < 202.5) return 'جنوب';
    if (degrees >= 202.5 && degrees < 247.5) return 'جنوب غرب';
    if (degrees >= 247.5 && degrees < 292.5) return 'غرب';
    return 'شمال غرب';
  }

  String getDirectionNameEnglish(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'North';
    if (degrees >= 22.5 && degrees < 67.5) return 'Northeast';
    if (degrees >= 67.5 && degrees < 112.5) return 'East';
    if (degrees >= 112.5 && degrees < 157.5) return 'Southeast';
    if (degrees >= 157.5 && degrees < 202.5) return 'South';
    if (degrees >= 202.5 && degrees < 247.5) return 'Southwest';
    if (degrees >= 247.5 && degrees < 292.5) return 'West';
    return 'Northwest';
  }
}

class QiblaDirection {
  final double qiblaDirection; // Direction in degrees (0-360)
  final double userLatitude;
  final double userLongitude;

  QiblaDirection({
    required this.qiblaDirection,
    required this.userLatitude,
    required this.userLongitude,
  });

  // Get distance to Kaaba
  double get distanceToKaaba {
    return QiblaService().calculateDistanceToKaaba(userLatitude, userLongitude);
  }

  // Get direction name
  String get directionNameArabic {
    return QiblaService().getDirectionName(qiblaDirection);
  }

  String get directionNameEnglish {
    return QiblaService().getDirectionNameEnglish(qiblaDirection);
  }

  Map<String, dynamic> toJson() {
    return {
      'qiblaDirection': qiblaDirection,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
    };
  }

  factory QiblaDirection.fromJson(Map<String, dynamic> json) {
    return QiblaDirection(
      qiblaDirection: (json['qiblaDirection'] as num).toDouble(),
      userLatitude: (json['userLatitude'] as num).toDouble(),
      userLongitude: (json['userLongitude'] as num).toDouble(),
    );
  }
}
