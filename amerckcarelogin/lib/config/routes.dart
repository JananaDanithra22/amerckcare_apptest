import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../shared/widgets/splash_screen.dart';
import '../features/settings/screens/settings_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      home: (context) => const HomeScreen(),
      settings: (context) => const SettingsScreen(), // <-- Added this line
    };
  }
}
