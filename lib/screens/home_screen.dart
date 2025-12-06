import 'package:flutter/material.dart';
import 'package:werdy/screens/adhkar_list_screen.dart';
import 'package:werdy/screens/dashboard_screen.dart';
import 'package:werdy/screens/quran_list_screen.dart';
import 'package:werdy/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/utils/app_strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const QuranListScreen(),
    const AdhkarListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: AppStrings.get('home_tab', settings.languageCode),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_rounded),
            selectedIcon: const Icon(Icons.menu_book),
            label: AppStrings.get('quran_tab', settings.languageCode),
          ),
          NavigationDestination(
            icon: const Icon(Icons.wb_twilight_rounded),
            selectedIcon: const Icon(Icons.wb_twilight),
            label: AppStrings.get('adhkar_title', settings.languageCode),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: AppStrings.get('settings', settings.languageCode),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _screens[_currentIndex],
      ),
    );
  }
}
