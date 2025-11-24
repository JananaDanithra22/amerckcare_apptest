// lib/features/settings/screens/enable_biometric_screen.dart - UID-BASED VERSION

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

  /// ✅ Separate method for SSO re-authentication
  Future<bool> _reauthenticateSSO(LoginType loginType) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = AuthService(authProvider);

    try {
      // Show explanation to user
      final proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Verify ${loginType == LoginType.google ? 'Google' : 'Facebook'} Account',
              ),
              content: Text(
                'To enable biometric login, we need to verify your ${loginType == LoginType.google ? 'Google' : 'Facebook'} account one more time.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue'),
                ),
              ],
            ),
      );

      if (proceed != true) return false;

      // Re-authenticate with the provider
      final result =
          loginType == LoginType.google
              ? await authService.googleSignInWithOverlay()
              : await authService.facebookSignInWithOverlay();

      if (!result.success) {
        _showError('Re-authentication failed. Please try again.');
        return false;
      }

      // Wait for auth state to fully sync
      await Future.delayed(const Duration(milliseconds: 500));

      return authProvider.isAuthenticated;
    } catch (e) {
      debugPrint('🔴 SSO re-authentication error: $e');
      return false;
    }
  }

  /// ✅ UPDATED: Enable biometric using UID for SSO users
  Future<void> _enableBiometric() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Add delay for auth state sync
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('🔍 Enable Biometric Check:');
      debugPrint('  - isAuthenticated: ${authProvider.isAuthenticated}');
      debugPrint('  - user: ${authProvider.user}');
      debugPrint('  - user uid: ${authProvider.user?.uid}');
      debugPrint('  - loginType: ${authProvider.loginType}');

      final loginType = authProvider.loginType;

      if (loginType == null) {
        _showError('Login type not found. Please sign in again.');
        setState(() => _isLoading = false);
        return;
      }

      // Get current user info
      final currentUser = authProvider.user;
      if (currentUser == null) {
        debugPrint('🔴 currentUser is null!');
        _showError('No logged-in user found. Please sign in again.');
        setState(() => _isLoading = false);
        return;
      }

      final uid = currentUser.uid;
      String identifier;
      String? credentialToStore;

      if (loginType == LoginType.emailPassword) {
        // ✅ Email/Password: Use email as identifier, password as credential
        if (currentUser.email == null || currentUser.email!.isEmpty) {
          _showError('Email is required for password-based login.');
          setState(() => _isLoading = false);
          return;
        }

        identifier = currentUser.email!;
        final password = _passwordCtrl.text;
        final passErr = Validators.validatePassword(password);

        if (passErr != null) {
          _formKey.currentState?.validate();
          setState(() => _isLoading = false);
          return;
        }

        // Verify credentials by attempting login
        final authService = AuthService(authProvider);
        final loginResult = await authService.loginWithOverlay(
          identifier,
          password,
        );

        if (!mounted) return;

        if (!loginResult.success) {
          final message = AuthErrorParser.getGenericMessage(loginResult.error);
          _showError(message);
          setState(() => _isLoading = false);
          return;
        }

        credentialToStore = password;
      } else {
        // ✅ SSO: Use UID as both identifier and credential
        identifier = uid;

        debugPrint(
          '🔐 Re-authenticating SSO user before enabling biometric...',
        );
        debugPrint('   UID: $uid');

        final reauthSuccess = await _reauthenticateSSO(loginType);

        if (!reauthSuccess) {
          _showError(
            'Re-authentication failed. Please try enabling biometric again.',
          );
          setState(() => _isLoading = false);
          return;
        }

        // After successful re-auth, get fresh user data
        final freshUser = authProvider.user;
        if (freshUser == null) {
          _showError('Authentication failed. Please try again.');
          setState(() => _isLoading = false);
          return;
        }

        // ✅ Store UID as credential for SSO users
        credentialToStore = freshUser.uid;
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

      // ✅ Enable biometric with proper identifier and credential
      debugPrint('💾 Storing biometric credentials:');
      debugPrint('   Identifier: $identifier');
      debugPrint(
        '   Credential: ${credentialToStore != null ? '[SET]' : '[NULL]'}',
      );
      debugPrint('   LoginType: $loginType');

      await _biometricService.enableBiometric(
        identifier,
        credentialToStore,
        loginType: loginType,
      );

      if (mounted) {
        final loginTypeName =
            loginType == LoginType.emailPassword
                ? 'password'
                : (loginType == LoginType.google ? 'Google' : 'Facebook');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$bioName enabled for $loginTypeName login successfully!',
            ),
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
                          "Your ${authProvider.loginType == LoginType.google ? 'Google' : 'Facebook'} account will be remembered securely.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 18),

                // Only show password field for email/password users
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
                  // For SSO users
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You\'ll be asked to verify your ${authProvider.loginType == LoginType.google ? 'Google' : 'Facebook'} account one more time to ensure secure biometric setup.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
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
