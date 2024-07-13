import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Settings Tab",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
