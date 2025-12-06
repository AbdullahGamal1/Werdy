import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/screens/home_screen.dart';
import 'package:werdy/utils/app_theme.dart';
import 'package:werdy/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
          darkTheme: AppTheme.darkTheme(settings.fontFamily),
          themeMode: settings.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
