import 'package:flutter/material.dart';
import '../widgets/biometric_settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        children: const [
          // Only the Biometric Login section
          SizedBox(height: 16),
          BiometricSettingsTile(),
        ],
      ),
    );
  }
}
