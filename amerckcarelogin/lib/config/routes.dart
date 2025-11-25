import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../shared/widgets/splash_screen.dart';
import '../features/settings/screens/settings_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/'; // Login screen as root
  static const String signup = '/signup';
  static const String home = '/home';
  static const String settings = '/settings';

  /// Returns a map of all app routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      home: (context) => const HomeScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }

  /// Helper methods for navigation using route constants
  static Future<void> goToLogin(BuildContext context) {
    return Navigator.pushReplacementNamed(context, login);
  }

  static Future<void> goToHome(BuildContext context) {
    return Navigator.pushReplacementNamed(context, home);
  }

  static Future<void> goToSettings(BuildContext context) {
    return Navigator.pushNamed(context, settings);
  }

  static Future<void> goToSignup(BuildContext context) {
    return Navigator.pushNamed(context, signup);
  }

  static Future<void> goToSplash(BuildContext context) {
    return Navigator.pushReplacementNamed(context, splash);
  }
}
