import 'package:amerckcarelogin/core/constants/ui_constants.dart';
import 'package:amerckcarelogin/features/auth/services/biometric_service.dart';
import 'package:flutter/material.dart';
import '../screens/enable_biometric_screen.dart';

class BiometricSettingsTile extends StatefulWidget {
  const BiometricSettingsTile({Key? key}) : super(key: key);

  @override
  State<BiometricSettingsTile> createState() => _BiometricSettingsTileState();
}

class _BiometricSettingsTileState extends State<BiometricSettingsTile> {
  final BiometricService _biometricService = BiometricService();
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _biometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isEnabled = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    if (value == true) {
      // Navigate to enable screen
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EnableBiometricScreen()),
      );

      // reload status after returning
      _loadStatus();
    } else {
      // disable biometric
      await _biometricService.disableBiometric();
      setState(() => _isEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ListTile(
        title: Text("Biometric Login"),
        subtitle: Text("Checking status..."),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.fingerprint, color: Colors.blue),
      title: const Text('Biometric Login'),
      subtitle: const Text(
        'Set up and manage biometric login for faster authentication',
      ),
      trailing: Transform.scale(
        scale: 0.8, // reduce size of switch
        child: Switch(
          value: _isEnabled,
          onChanged: _toggle,
          activeColor: UIConstants.darkBlue, // toggle ON color
        ),
      ),
    );
  }
}
