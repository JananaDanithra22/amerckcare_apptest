// lib/features/auth/screens/enable_biometric_screen.dart

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
  final _emailCtrl = TextEditingController();
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return Validators.validateEmail(_emailCtrl.text.trim()) == null &&
        Validators.validatePassword(_passwordCtrl.text) == null;
  }

  /// NEW: Secure enable flow:
  /// 1) validate fields
  /// 2) verify credentials with backend (AuthService)
  /// 3) check biometric availability
  /// 4) prompt biometric scan (authenticate)
  /// 5) if ok -> enableBiometric (store creds)
  Future<void> _enableBiometric() async {
    // 1) local validation
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    final emailErr = Validators.validateEmail(email);
    final passErr = Validators.validatePassword(password);

    if (emailErr != null || passErr != null) {
      // show inline errors
      _formKey.currentState?.validate();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2) Verify credentials with backend (reuse same AuthService flow you use on login)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authService = AuthService(authProvider);

      final loginResult = await authService.loginWithOverlay(email, password);

      if (!mounted) return;

      if (!loginResult.success) {
        // do not enable biometric if credentials invalid
        final message = AuthErrorParser.getGenericMessage(loginResult.error);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      // 3) Check biometric availability
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric not available on this device.'),
          ),
        );
        return;
      }

      // Optional: get biometric name for messages
      final bioName = await _biometricService.getBiometricTypeName();

      // 4) Prompt the biometric scanner (so user must scan)
      final didAuthenticate = await _biometricService.authenticate(
        reason: 'Scan your $bioName to enable biometric login',
      );

      if (!didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication failed or cancelled.'),
          ),
        );
        return;
      }

      // 5) Store credentials / mark biometric enabled
      await _biometricService.enableBiometric(email, password);

      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$bioName enabled successfully')),
        );
        Navigator.of(context).pop(); // return to previous screen
      }
    } catch (e, st) {
      debugPrint('🔴 Error enabling biometric: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to enable biometric. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

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
                // TOP-CENTER ANIMATION 🎞️
                SizedBox(
                  height: 160,
                  width: 160,
                  child: _buildFingerprintAnimation(),
                ),
                const SizedBox(height: 12),

                // INTRO TEXT 📝
                const Text(
                  "Enable Biometric Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Make your login easier and more secure.\n"
                  "Enable fingerprint login to access your account faster.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                // EMAIL LABEL
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
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
                    controller: _emailCtrl,
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => Validators.validateEmail(v?.trim() ?? ''),
                  ),
                ),

                const SizedBox(height: 18),

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

                // ENABLE BUTTON
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
