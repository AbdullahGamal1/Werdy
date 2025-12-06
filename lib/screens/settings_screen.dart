import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/utils/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings', settings.languageCode)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(
            context,
            AppStrings.get('appearance', settings.languageCode),
          ),
          SwitchListTile(
            title: Text(AppStrings.get('dark_mode', settings.languageCode)),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              settings.toggleTheme(value);
            },
          ),
          const Divider(),
          _buildSectionHeader(
            context,
            AppStrings.get('quran_text', settings.languageCode),
          ),
          Text(AppStrings.get('font_size', settings.languageCode)),
          Slider(
            value: settings.fontSize,
            min: 14.0,
            max: 40.0,
            divisions: 13,
            label: settings.fontSize.round().toString(),
            onChanged: (value) {
              settings.setFontSize(value);
            },
          ),
          Text(
            'بسم الله الرحمن الرحيم',
            style: GoogleFonts.getFont(
              settings.fontFamily,
              fontSize: settings.fontSize,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(AppStrings.get('font_family', settings.languageCode)),
          DropdownButton<String>(
            value: settings.fontFamily,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Amiri', child: Text('Amiri (Default)')),
              DropdownMenuItem(
                value: 'Noto Naskh Arabic',
                child: Text('خط النسخ العربي'),
              ),
              DropdownMenuItem(
                value: 'Aref Ruqaa',
                child: Text('خط الرقعة العربي'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                settings.setFontFamily(value);
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(
            context,
            AppStrings.get('reminders', settings.languageCode),
          ),
          _buildReminderTile(
            context,
            AppStrings.get('morning_adhkar', settings.languageCode),
            settings.morningReminderEnabled,
            settings.morningReminderTime,
            (enabled) => settings.setMorningReminder(enabled),
            (time) => settings.setMorningReminder(true, time: time),
            settings.languageCode,
          ),
          _buildReminderTile(
            context,
            AppStrings.get('evening_adhkar', settings.languageCode),
            settings.eveningReminderEnabled,
            settings.eveningReminderTime,
            (enabled) => settings.setEveningReminder(enabled),
            (time) => settings.setEveningReminder(true, time: time),
            settings.languageCode,
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    String title,
    bool value,
    TimeOfDay time,
    Function(bool) onChanged,
    Function(TimeOfDay) onTimeChanged,
    String languageCode,
  ) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title),
          subtitle: value
              ? Text(
                  '${AppStrings.get('scheduled_at', languageCode)} ${time.format(context)}',
                )
              : null,
          value: value,
          onChanged: onChanged,
        ),
        if (value)
          ListTile(
            title: Text(AppStrings.get('change_time', languageCode)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) {
                onTimeChanged(picked);
              }
            },
          ),
      ],
    );
  }
}
