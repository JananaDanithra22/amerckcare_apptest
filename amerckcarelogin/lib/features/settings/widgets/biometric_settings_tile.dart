// lib/features/auth/widgets/biometric_settings_tile.dart - IMPROVED VERSION

import 'package:amerckcarelogin/core/constants/ui_constants.dart';
import 'package:amerckcarelogin/features/auth/providers/auth_provider.dart';
import 'package:amerckcarelogin/features/auth/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (value == true) {
      // Only allow enabling biometric if user is logged in
      if (!authProvider.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You need to be logged in to enable biometric login.',
            ),
          ),
        );
        return;
      }

      // ✅ For SSO users, add a small delay to ensure auth state is fully synced
      if (authProvider.loginType == LoginType.google ||
          authProvider.loginType == LoginType.facebook) {
        await Future.delayed(const Duration(milliseconds: 300));

        // Double-check authentication
        if (!authProvider.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication not complete. Please try again.'),
            ),
          );
          return;
        }
      }

      // Navigate to enable screen
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EnableBiometricScreen()),
      );

      // Reload status after returning
      _loadStatus();
    } else {
      // Show confirmation dialog before disabling
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Disable Biometric Login?'),
              content: const Text(
                'You will need to sign in manually next time. You can re-enable this feature anytime in settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Disable',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      if (confirmed == true) {
        // Disable biometric
        await _biometricService.disableBiometric();
        setState(() => _isEnabled = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric login disabled')),
          );
        }
      }
    }
  }

  String _getSubtitleText(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return 'Sign in to enable biometric authentication';
    }

    switch (authProvider.loginType) {
      case LoginType.emailPassword:
        return 'Set up and manage biometric login for faster authentication';
      case LoginType.google:
        return 'Enable biometric login for quicker Google sign-in';
      case LoginType.facebook:
        return 'Enable biometric login for quicker Facebook sign-in';
      default:
        return 'Enable biometric login for quicker access';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ListTile(
        leading: Icon(Icons.fingerprint, color: Colors.blue),
        title: Text("Biometric Login"),
        subtitle: Text("Checking status..."),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return ListTile(
          leading: const Icon(Icons.fingerprint, color: Colors.blue),
          title: const Text('Biometric Login'),
          subtitle: Text(_getSubtitleText(authProvider)),
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isEnabled,
              onChanged: authProvider.isAuthenticated ? _toggle : null,
              activeColor: UIConstants.darkBlue,
            ),
          ),
          onTap:
              authProvider.isAuthenticated && !_isEnabled
                  ? () => _toggle(true)
                  : null,
        );
      },
    );
  }
}
