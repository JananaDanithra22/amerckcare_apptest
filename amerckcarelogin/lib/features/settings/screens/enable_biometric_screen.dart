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
      final authService = AuthService(authProvider);

      final loginType = authProvider.loginType;
      if (loginType == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login type not found.')));
        setState(() => _isLoading = false);
        return;
      }

      String email = authProvider.getCurrentUserEmail() ?? '';
      String? password;

      if (loginType == LoginType.emailPassword) {
        password = _passwordCtrl.text;

        final passErr = Validators.validatePassword(password);
        if (passErr != null) {
          _formKey.currentState?.validate();
          setState(() => _isLoading = false);
          return;
        }

        if (email.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No logged-in user found.')),
          );
          setState(() => _isLoading = false);
          return;
        }

        final loginResult = await authService.loginWithOverlay(email, password);
        if (!mounted) return;

        if (!loginResult.success) {
          final message = AuthErrorParser.getGenericMessage(loginResult.error);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          setState(() => _isLoading = false);
          return;
        }
      } else {
        // SSO / Google user
        password ??= '';
        email = email.isEmpty ? '' : email;
      }

      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric not available on this device.'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final bioName = await _biometricService.getBiometricTypeName();
      final didAuthenticate = await _biometricService.authenticate(
        reason: 'Scan your $bioName to enable biometric login',
      );

      if (!didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication failed or cancelled.'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      await _biometricService.enableBiometric(
        email,
        password,
        loginType: loginType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$bioName enabled successfully')),
        );
        Navigator.of(context).pop();
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
                const Text(
                  "Make your login easier and more secure.\n"
                  "Enable fingerprint login to access your account faster.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
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
