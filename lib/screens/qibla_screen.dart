import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/services/qibla_service.dart';
import 'package:werdy/utils/app_strings.dart';
import 'package:werdy/utils/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  QiblaDirection? _qiblaDirection;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQiblaData();
  }

  Future<void> _loadQiblaData() async {
    try {
      final qiblaData = await QiblaService().calculateQiblaDirection();
      if (mounted) {
        setState(() {
          _qiblaDirection = qiblaData;
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
          AppStrings.get('qibla_direction', settings.languageCode),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error reading compass: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                double? direction = snapshot.data?.heading;

                // If direction is null, device might not support compass
                if (direction == null) {
                  return const Center(
                    child: Text('Device does not support compass'),
                  );
                }

                // Calculate rotation angles
                // We want the compass card to rotate opposite to device rotation (so North stays North)
                // The Qibla needle should point to Qibla direction relative to North

                // Normalizing direction to 0-360
                if (direction < 0) direction += 360;

                final qiblaBearing = _qiblaDirection?.qiblaDirection ?? 0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Information Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${qiblaBearing.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            settings.languageCode == 'ar'
                                ? _qiblaDirection?.directionNameArabic ?? ''
                                : _qiblaDirection?.directionNameEnglish ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.languageCode == 'ar'
                                ? 'المسافة: ${_qiblaDirection?.distanceToKaaba.toStringAsFixed(0)} كم'
                                : 'Distance: ${_qiblaDirection?.distanceToKaaba.toStringAsFixed(0)} km',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Compass Rose (Background)
                            // Rotates by -direction * (pi/180) to keep North at top (conceptually)
                            // Wait, if we want "North" on the card to point to real North, we rotate the card by -heading.
                            Transform.rotate(
                              angle: -direction * (math.pi / 180),
                              child: Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    width: 4,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Cardinal Directions
                                    _buildCompassMark(0, 'N'),
                                    _buildCompassMark(90, 'E'),
                                    _buildCompassMark(180, 'S'),
                                    _buildCompassMark(270, 'W'),
                                    // Ticks
                                    ...List.generate(72, (index) {
                                      return _buildCompassTick(index * 5.0);
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            // Qibla Needle
                            // Points to Qibla relative to North.
                            // If Compass Rose is at -heading (North is up), then Qibla is at (qibla - heading).
                            // BUT: If we rotate the compass rose so N points North, then Qibla is fixed at 'qiblaBearing' ON THE ROSE.
                            // So we attach the Qibla needle to the ROTATING compass rose layer?
                            // No, simpler:
                            // Layer 1: Compass Rose. Rotated by -heading.
                            // Layer 2: Qibla Arrow. Rotated by (-heading + qibla).
                            // Let's verify:
                            // If I face North (heading 0), Rose is 0. Qibla is at qiblaBearing. Correct.
                            // If I face East (heading 90), Rose is -90. Qibla arrow is at -90 + qibla.
                            // Visually: N is to the Left (Correct). Qibla is rotated left by 90 too. Correct.
                            Transform.rotate(
                              angle:
                                  (-direction + qiblaBearing) * (math.pi / 180),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on, // Kaaba icon/pointer
                                    size: 50,
                                    color: AppTheme.secondaryColor,
                                  ),
                                  Container(
                                    width: 4,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondaryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 50,
                                  ), // Center pivot offset
                                ],
                              ),
                            ),

                            // Device/Heading Pointer (Static, pointing up)
                            // Only if we weren't rotating the rose. But here we rotate the world.
                            // Actually, typical compass apps: Phone is fixed. "N" moves.
                            // So if I face East: "N" is to my Left (-90).
                            // The Qibla is somewhere else.

                            // Center Dot
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCompassMark(double angle, String label) {
    return Positioned.fill(
      child: Transform.rotate(
        angle: angle * (math.pi / 180),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Transform.rotate(
              angle:
                  -angle *
                  (math.pi /
                      180), // Keep text upright? No, let it rotate with card
              // Actually, if the card rotates, the text 'N' should rotate with it.
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: label == 'N' ? Colors.red : AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompassTick(double angle) {
    final bool isMajor = angle % 90 == 0;
    final bool isSemiMajor = angle % 45 == 0;
    final double height = isMajor ? 12 : (isSemiMajor ? 8 : 4);
    final double width = isMajor ? 3 : (isSemiMajor ? 2 : 1);

    return Positioned.fill(
      child: Transform.rotate(
        angle: angle * (math.pi / 180),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 35), // Inner from the text
            width: width,
            height: height,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
