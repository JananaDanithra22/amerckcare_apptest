// lib/config/routes.dart
import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../shared/widgets/splash_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/change_password_screen.dart';
import '../features/about/screens/about_us_screen.dart';
import '../features/help/screens/help_support_screen.dart';

/// Centralized route configuration for the application
/// Uses named routes for better navigation management
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route name constants - Single source of truth
  static const String splash = '/splash';
  static const String login = '/';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String aboutUs = '/about-us';
  static const String helpSupport = '/help-support';

  /// Returns a map of all app routes
  /// Each route is lazily instantiated when needed
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (_) => const SplashScreen(),
      login: (_) => const LoginScreen(),
      signup: (_) => const SignUpScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      home: (_) => const HomeScreen(),
      settings: (_) => const SettingsScreen(),
      profile: (_) => const ProfileScreen(),
      changePassword: (_) => const ChangePasswordScreen(),
      aboutUs: (_) => const AboutUsScreen(),
      helpSupport: (_) => const HelpSupportScreen(),
    };
  }

  /// Navigation helper methods with type safety
  /// These provide a cleaner API for navigation throughout the app

  /// Navigate to login screen (replaces current route)
  static Future<void> toLogin(BuildContext context) {
    return Navigator.pushReplacementNamed(context, login);
  }

  /// Navigate to home screen (replaces current route)
  static Future<void> toHome(BuildContext context) {
    return Navigator.pushReplacementNamed(context, home);
  }

  /// Navigate to signup screen
  static Future<void> toSignup(BuildContext context) {
    return Navigator.pushNamed(context, signup);
  }

  /// Navigate to forgot password screen
  static Future<void> toForgotPassword(BuildContext context) {
    return Navigator.pushNamed(context, forgotPassword);
  }

  /// Navigate to settings screen
  static Future<void> toSettings(BuildContext context) {
    return Navigator.pushNamed(context, settings);
  }

  /// Navigate to profile screen
  static Future<void> toProfile(BuildContext context) {
    return Navigator.pushNamed(context, profile);
  }

  /// Navigate to change password screen
  static Future<void> toChangePassword(BuildContext context) {
    return Navigator.pushNamed(context, changePassword);
  }

  /// Navigate to about us screen
  static Future<void> toAboutUs(BuildContext context) {
    return Navigator.pushNamed(context, aboutUs);
  }

  /// Navigate to help and support screen
  static Future<void> toHelpSupport(BuildContext context) {
    return Navigator.pushNamed(context, helpSupport);
  }

  /// Navigate to splash screen (replaces current route)
  static Future<void> toSplash(BuildContext context) {
    return Navigator.pushReplacementNamed(context, splash);
  }

  /// Clear navigation stack and go to login
  static Future<void> clearAndGoToLogin(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(context, login, (_) => false);
  }

  /// Clear navigation stack and go to home
  static Future<void> clearAndGoToHome(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(context, home, (_) => false);
  }
}
