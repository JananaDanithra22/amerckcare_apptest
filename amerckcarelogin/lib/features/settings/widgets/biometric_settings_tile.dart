import 'package:amerckcarelogin/features/auth/providers/auth_provider.dart';
import 'package:amerckcarelogin/features/auth/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/services/biometric_service.dart';

class BiometricSettingsTile extends StatefulWidget {
  const BiometricSettingsTile({Key? key}) : super(key: key);

  @override
  State<BiometricSettingsTile> createState() => _BiometricSettingsTileState();
}

class _BiometricSettingsTileState extends State<BiometricSettingsTile> {
  final BiometricService _biometricService = BiometricService();

  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  String _biometricName = 'Biometric';

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    setState(() => _isLoading = true);

    try {
      final available = await _biometricService.isBiometricAvailable();
      final enabled = await _biometricService.isBiometricEnabled();
      final name = await _biometricService.getBiometricTypeName();

      if (mounted) {
        setState(() {
          _isBiometricAvailable = available;
          _isBiometricEnabled = enabled;
          _biometricName = name;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🔴 Error loading biometric status: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_isBiometricAvailable) {
      _showSnackBar('$_biometricName is not available on this device.');
      return;
    }

    if (value) {
      await _enableBiometric();
    } else {
      await _disableBiometric();
    }
  }

  Future<void> _enableBiometric() async {
    try {
      // Authenticate using fingerprint/face
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to enable $_biometricName login',
      );

      if (!authenticated) {
        _showSnackBar('Authentication failed. Please try again.');
        return;
      }

      // Get current user from AuthProvider
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final email = auth.getCurrentUserEmail()!;

      // Show password dialog if password not stored yet
      final credentials = await _biometricService.getStoredCredentials();
      String password;

      if (credentials == null || credentials['password'] == null) {
        // Ask user to enter password if not stored
        final entered = await _showCredentialsDialog();
        if (entered == null) {
          _showSnackBar('Biometric login requires a password to store.');
          return;
        }
        password = entered['password']!;
        await _biometricService.saveCredentials(email, password);
      } else {
        password = credentials['password']!;
      }

      // Enable biometric login with stored credentials
      await _biometricService.enableBiometric(email, password);

      setState(() => _isBiometricEnabled = true);
      _showSnackBar(
        '$_biometricName login enabled successfully!',
        isError: false,
      );
    } catch (e) {
      debugPrint('🔴 Error enabling biometric: $e');
      _showSnackBar('Failed to enable $_biometricName login.');
    }
  }

  Future<void> _disableBiometric() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Disable $_biometricName Login?'),
            content: const Text(
              'You will need to enter your email and password to login next time.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Disable'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _biometricService.disableBiometric();
      setState(() => _isBiometricEnabled = false);
      _showSnackBar('$_biometricName login disabled.');
    } catch (e) {
      debugPrint('🔴 Error disabling biometric: $e');
      _showSnackBar('Failed to disable $_biometricName login.');
    }
  }

  Future<Map<String, String>?> _showCredentialsDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Enter Your Credentials'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          controller: emailController,
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          controller: passwordController,
                          hintText: 'Enter your password',
                          obscureText: obscurePassword,
                          onToggleVisibility: () {
                            setState(() => obscurePassword = !obscurePassword);
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context, {
                          'email': emailController.text.trim(),
                          'password': passwordController.text,
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListTile(
        leading: const Icon(Icons.fingerprint),
        title: const Text('Biometric Login'),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return ListTile(
      leading: Icon(
        _biometricName == 'Face ID' ? Icons.face : Icons.fingerprint,
        color: _isBiometricAvailable ? Colors.blue : Colors.grey,
      ),
      title: Text('$_biometricName Login'),
      subtitle: Text(
        _isBiometricAvailable
            ? _isBiometricEnabled
                ? 'Enabled'
                : 'Disabled'
            : 'Not available on this device',
        style: TextStyle(
          fontSize: 12,
          color: _isBiometricEnabled ? Colors.green : Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: _isBiometricEnabled,
        onChanged: _isBiometricAvailable ? _toggleBiometric : null,
      ),
    );
  }
}
