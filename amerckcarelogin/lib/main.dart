// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'shared/widgets/loading_overlay.dart';
import 'core/widgets/activity_detector.dart';
import 'core/utils/session_manager.dart';
import 'core/widgets/session_warning.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/voice_notes/providers/voice_notes_provider.dart';
import 'features/profile/providers/profile_avatar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => VoiceNotesProvider()),
        ChangeNotifierProvider(create: (_) => ProfileAvatarProvider()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // ✅ Listen to app lifecycle changes (background/foreground)
    WidgetsBinding.instance.addObserver(this);

    // ✅ Initialize session manager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionManager().initialize(
        context: _navigatorKey.currentContext!,
        onWarningShow: _showSessionWarning,
        onLogout: _performAutoLogout,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SessionManager().dispose();
    super.dispose();
  }

  /// ✅ Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // App went to background
        debugPrint('📱 App paused (backgrounded)');
        SessionManager().onAppPaused();
        break;

      case AppLifecycleState.resumed:
        // App came to foreground
        debugPrint('📱 App resumed (foreground)');
        SessionManager().onAppResumed();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// ✅ Show session timeout warning
  void _showSessionWarning() {
    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SessionWarningDialog(
            onContinue: () {
              debugPrint('✅ User confirmed: Still active');
            },
            onLogout: () {
              Navigator.of(context).pop();
              _performAutoLogout();
            },
          ),
    );
  }

  /// ✅ Perform auto-logout
  void _performAutoLogout() async {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Stop session monitoring
    SessionManager().stopSession();
    Provider.of<ProfileAvatarProvider>(context, listen: false).clearPhoto();

    // Perform logout
    await authProvider.logout();

    // Show message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been logged out due to inactivity'),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.orange,
        ),
      );

      // Navigate to login
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'AmerckCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(),

      // ✅ Wrap with ActivityDetector to track user interactions
      builder: (context, child) {
        return GlobalLoadingOverlay(
          backgroundColor: Colors.white,
          progressColor: const Color(0xFF2196F3),
          logoAssetPath: 'assets/images/signlogo.png',
          lottieAssetPath: 'assets/loading.json',
          lottieSize: 80,
          child: ActivityDetector(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
