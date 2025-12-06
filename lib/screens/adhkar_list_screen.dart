import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werdy/data/adhkar_data.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/screens/adhkar_detail_screen.dart';
import 'package:werdy/utils/app_strings.dart';

class AdhkarListScreen extends StatelessWidget {
  const AdhkarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('adhkar_title', settings.languageCode)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdhkarCard(
            context,
            AppStrings.get('morning_adhkar', settings.languageCode),
            'أذكار الصباح',
            Icons.wb_sunny_rounded,
            const Color(0xFFD4AF37), // Gold
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdhkarDetailScreen(
                  title: AppStrings.get(
                    'morning_adhkar',
                    settings.languageCode,
                  ),
                  adhkarList: AdhkarData.morningAdhkar,
                ),
              ),
            ),
          ),
          _buildAdhkarCard(
            context,
            AppStrings.get('evening_adhkar', settings.languageCode),
            'أذكار المساء',
            Icons.nights_stay_rounded,
            const Color(0xFF2C3E50), // Deep shade
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdhkarDetailScreen(
                  title: AppStrings.get(
                    'evening_adhkar',
                    settings.languageCode,
                  ),
                  adhkarList: AdhkarData.eveningAdhkar,
                ),
              ),
            ),
          ),
          // Add more adhkar types here if needed
        ],
      ),
    );
  }

  Widget _buildAdhkarCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
