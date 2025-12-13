import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/screens/home_screen.dart';
import 'package:werdy/utils/app_theme.dart';
import 'package:werdy/services/notification_service.dart';
import 'package:werdy/services/home_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize critical services synchronously
  await NotificationService().init();

  // Launch app immediately
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SettingsProvider())],
      child: const MyApp(),
    ),
  );

  // Schedule non-critical tasks in background after app starts
  Future.microtask(() async {
    await NotificationService().scheduleSmartReminders();
    await HomeWidgetService.updateWidget();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Quran & Adhkar',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(settings.fontFamily),
          darkTheme: AppTheme.darkTheme(
            settings.fontFamily,
            isTrueBlack: settings.isTrueBlack,
          ),
          themeMode: settings.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
