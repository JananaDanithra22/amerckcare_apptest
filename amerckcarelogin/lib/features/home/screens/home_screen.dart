import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/biometric_service.dart';
import '../../auth/widgets/auth_guard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _biometricEnabled = false;
  String _biometricType = 'Biometric';
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initBiometricSettings();
  }

  Future<void> _initBiometricSettings() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();
    final type = await _biometricService.getBiometricTypeName();

    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _biometricType = type;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = auth.getCurrentUserEmail();

    if (!value) {
      // Disable biometric
      await _biometricService.disableBiometric();
      if (mounted) setState(() => _biometricEnabled = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Biometric login disabled')));
    } else {
      if (email == null) return;
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to enable $_biometricType login',
      );

      if (authenticated) {
        await _biometricService.enableBiometric(email, '');
        if (mounted) setState(() => _biometricEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_biometricType login enabled'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AmerckCare Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to AmerckCare',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  'Email: ${auth.getCurrentUserEmail() ?? "N/A"}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),

                if (_biometricAvailable)
                  Card(
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(
                        _biometricType == 'Face ID'
                            ? Icons.face
                            : Icons.fingerprint,
                        color: Colors.blue,
                      ),
                      title: Text('$_biometricType Login'),
                      subtitle: Text(
                        _biometricEnabled ? 'Enabled' : 'Disabled',
                      ),
                      trailing: Switch(
                        value: _biometricEnabled,
                        onChanged: _toggleBiometric,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
