// lib/features/settings/screens/enable_biometric_screen.dart - FIXED

import 'package:amerckcarelogin/features/auth/providers/auth_provider.dart';
import 'package:amerckcarelogin/features/auth/services/auth_service.dart';
import 'package:amerckcarelogin/features/auth/services/biometric_service.dart';
import 'package:amerckcarelogin/features/auth/widgets/custom_button.dart';
import 'package:amerckcarelogin/features/auth/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../core/utils/validators.dart';
import '../../../core/utils/auth_error_parser.dart';
import '../../../core/constants/ui_constants.dart';

class EnableBiometricScreen extends StatefulWidget {
  const EnableBiometricScreen({Key? key}) : super(key: key);

  @override
  State<EnableBiometricScreen> createState() => _EnableBiometricScreenState();
}

class _EnableBiometricScreenState extends State<EnableBiometricScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();

  final BiometricService _biometricService = BiometricService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.92,
      upperBound: 1.08,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.loginType == LoginType.emailPassword) {
      return Validators.validatePassword(_passwordCtrl.text) == null;
    }
    return true;
  }

  Future<void> _enableBiometric() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await Future.delayed(const Duration(milliseconds: 300));

      final loginType = authProvider.loginType;
      if (loginType == null) {
        _showError('Login type not found. Please sign in again.');
        setState(() => _isLoading = false);
        return;
      }

      final currentUser = authProvider.user;
      if (currentUser == null) {
        _showError('No logged-in user found. Please sign in again.');
        setState(() => _isLoading = false);
        return;
      }

      final uid = currentUser.uid;
      String email;
      String? password;

      if (loginType == LoginType.emailPassword) {
        // ✅ Email/Password: Need email and password
        if (currentUser.email == null || currentUser.email!.isEmpty) {
          _showError('Email is required for password-based login.');
          setState(() => _isLoading = false);
          return;
        }

        email = currentUser.email!;
        password = _passwordCtrl.text;

        final passErr = Validators.validatePassword(password);
        if (passErr != null) {
          _formKey.currentState?.validate();
          setState(() => _isLoading = false);
          return;
        }

        // Verify credentials
        final authService = AuthService(authProvider);
        final loginResult = await authService.loginWithOverlay(email, password);

        if (!mounted) return;

        if (!loginResult.success) {
          final message = AuthErrorParser.getGenericMessage(loginResult.error);
          _showError(message);
          setState(() => _isLoading = false);
          return;
        }
      } else {
        // ✅ SSO: Use email if available, otherwise 'no-email'
        email = currentUser.email ?? 'no-email';
        password = null; // SSO users don't need password stored

        debugPrint('🔐 Enabling biometric for SSO user');
        debugPrint('   UID: $uid');
        debugPrint('   Email: $email');
      }

      // Check biometric availability
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        _showError('Biometric not available on this device.');
        setState(() => _isLoading = false);
        return;
      }

      // Authenticate with biometrics
      final bioName = await _biometricService.getBiometricTypeName();
      final didAuthenticate = await _biometricService.authenticate(
        reason: 'Scan your $bioName to enable biometric login',
      );

      if (!didAuthenticate) {
        _showError('Biometric authentication failed or cancelled.');
        setState(() => _isLoading = false);
        return;
      }

      // ✅ FIXED: Call with 3 parameters (email, password, uid)
      await _biometricService.enableBiometric(
        email,
        password,
        uid,
        loginType: loginType,
      );

      if (mounted) {
        final loginTypeName =
            loginType == LoginType.emailPassword
                ? 'password'
                : (loginType == LoginType.google ? 'Google' : 'Facebook');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$bioName enabled for $loginTypeName login!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      debugPrint('🔴 Error enabling biometric: $e\n$st');
      if (mounted) {
        _showError('Failed to enable biometric. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enable Biometric'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: _buildFingerprintAnimation(),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Enable Biometric Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.loginType == LoginType.emailPassword
                      ? "Make your login easier and more secure.\n"
                          "Enable biometric login to access your account faster."
                      : "Enable biometric login for quick access.\n"
                          "Your ${authProvider.loginType == LoginType.google ? 'Google' : 'Facebook'} session will be remembered as long as you stay logged in.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 18),

                if (authProvider.loginType == LoginType.emailPassword) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: fieldWidth,
                    child: CustomTextField(
                      controller: _passwordCtrl,
                      hintText: 'Enter your password',
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onChanged: (_) => setState(() {}),
                      validator: (v) => Validators.validatePassword(v ?? ''),
                    ),
                  ),
                  const SizedBox(height: 30),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your ${authProvider.loginType == LoginType.google ? 'Google' : 'Facebook'} session will be saved. Next time, just use biometric to login instantly!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                CustomButton(
                  text: "Enable",
                  onPressed:
                      _isFormValid && !_isLoading ? _enableBiometric : null,
                  isLoading: _isLoading,
                  width: fieldWidth,
                  height: UIConstants.buttonHeight,
                  backgroundColor: UIConstants.primaryBlue,
                  borderRadius: UIConstants.buttonRadius,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintAnimation() {
    try {
      return Lottie.asset(
        'assets/Fingerprint Success.json',
        repeat: true,
        fit: BoxFit.contain,
      );
    } catch (_) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: _pulseController,
          curve: Curves.easeInOut,
        ),
        child: const Icon(Icons.fingerprint, size: 100),
      );
    }
  }
}
