import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  void _navigateAfterSplash() async {
    await Future.delayed(Duration(seconds: AppConstants.splashDuration));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // ✅ Trigger biometric login explicitly AFTER splash
    final biometricSuccess = await authProvider.triggerBiometricLogin();

    if (!mounted) return;

    if (biometricSuccess || authProvider.isUserSignedIn()) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/amerckcarelogo.png',
          width: 360,
          height: 360,
        ),
      ),
    );
  }
}
