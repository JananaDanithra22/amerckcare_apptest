//routes.dart
import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../shared/widgets/splash_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/change_password_screen.dart'; // Add this import

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/'; // Login screen as root
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String changePassword = '/change-password'; // Add this constant

  /// Returns a map of all app routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      signup: (context) => const SignUpScreen(),
      home: (context) => const HomeScreen(),
      settings: (context) => const SettingsScreen(),
      profile: (context) => const ProfileScreen(),
      changePassword: (context) => const ChangePasswordScreen(), // Add this route
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

  static Future<void> goToChangePassword(BuildContext context) { // Add helper method
    return Navigator.pushNamed(context, changePassword);
  }
}