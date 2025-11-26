// lib/shared/widgets/splash_screen.dart - FIXED VERSION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/services/biometric_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _showBiometricPrompt = false;

  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Show splash logo for 2 seconds
    await Future.delayed(Duration(seconds: AppConstants.splashDuration));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // ✅ Check 1: Is user already logged in?
    if (authProvider.isAuthenticated) {
      debugPrint('✅ User already logged in. Navigating to home...');
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // ✅ Check 2: Is biometric enabled?
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();
    if (!isBiometricEnabled) {
      debugPrint('⚠️ Biometric not enabled. Going to login...');
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    // ✅ Check 3: Is biometric available on device?
    final isBiometricAvailable = await _biometricService.isBiometricAvailable();
    if (!isBiometricAvailable) {
      debugPrint('⚠️ Biometric not available. Going to login...');
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    // ✅ Show biometric prompt
    debugPrint('🔐 Showing biometric prompt on splash...');
    setState(() => _showBiometricPrompt = true);

    // Trigger biometric authentication
    await _handleBiometricLogin();
  }

  /// ✅ NEW: Handle biometric login directly from splash
  /// This uses the SAME logic as login_screen.dart
  Future<void> _handleBiometricLogin() async {
    try {
      final credentials = await _biometricService.getStoredCredentials();
      if (credentials == null) {
        debugPrint('⚠️ No stored credentials. Going to login...');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
        return;
      }

      final biometricName = await _biometricService.getBiometricTypeName();
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate with $biometricName to login',
      );

      if (!authenticated) {
        debugPrint('⚠️ Biometric authentication cancelled/failed');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
        return;
      }

      final loginTypeStr = credentials['loginType'] ?? 'emailPassword';
      final storedUid = credentials['uid']!;
      final storedEmail = credentials['email'];
      final storedPassword = credentials['password'];

      final auth = Provider.of<AuthProvider>(context, listen: false);

      debugPrint('🔐 Splash biometric login attempt:');
      debugPrint('   Login type: $loginTypeStr');
      debugPrint('   Stored UID: $storedUid');

      switch (loginTypeStr) {
        case 'emailPassword':
          // Email/Password: Use stored credentials
          if (storedEmail == null || storedPassword == null) {
            debugPrint('⚠️ Stored credentials incomplete');
            if (mounted) Navigator.pushReplacementNamed(context, '/');
            return;
          }

          await auth.login(storedEmail, storedPassword);

          if (!auth.isAuthenticated) {
            debugPrint('❌ Login failed');
            if (mounted) Navigator.pushReplacementNamed(context, '/');
            return;
          }
          break;

        case 'google':
          // ✅ KEY FIX: Always trigger fresh Google Sign-In
          debugPrint('🔐 Triggering Google Sign-In from splash...');

          await auth.signInWithGoogle();
          await Future.delayed(const Duration(milliseconds: 500));

          if (!auth.isAuthenticated) {
            debugPrint('⚠️ Google sign-in cancelled');
            if (mounted) Navigator.pushReplacementNamed(context, '/');
            return;
          }

          final currentUid = auth.user?.uid;
          if (currentUid != storedUid) {
            debugPrint('❌ UID mismatch. Disabling biometric.');
            await _biometricService.disableBiometric();
            if (mounted) Navigator.pushReplacementNamed(context, '/');
            return;
          }

          debugPrint('✅ Google UID verified: $currentUid');
          break;

        case 'facebook':
          // ✅ KEY FIX: Always trigger fresh Facebook Sign-In
          debugPrint('🔐 Triggering Facebook Sign-In from splash...');

          await auth.signInWithFacebook();
          await Future.delayed(const Duration(milliseconds: 500));

          if (!auth.isAuthenticated) {
            debugPrint('⚠️ Facebook sign-in cancelled');
            if (mounted) Navigator.pushReplacementNamed(context, '/');
            return;
          }

          final currentUid = auth.user?.uid;
          if (currentUid != storedUid) {
            debugPrint('❌ UID mismatch. Disabling biometric.');
            await _biometricService.disableBiometric();
            if (mounted) Navigator.pushReplacementNamed(context, '/');
            return;
          }

          debugPrint('✅ Facebook UID verified: $currentUid');
          break;

        default:
          debugPrint('❌ Unknown login type');
          if (mounted) Navigator.pushReplacementNamed(context, '/');
          return;
      }

      // Success! Navigate to home
      if (mounted && auth.isAuthenticated) {
        debugPrint('✅ Splash biometric login successful');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      debugPrint('🔴 Splash biometric error: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/amerckcarelogo.png',
              width: 360,
              height: 360,
            ),

            // ✅ Show biometric prompt indicator
            if (_showBiometricPrompt) ...[
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Authenticating...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
