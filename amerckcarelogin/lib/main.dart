import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'shared/widgets/loading_overlay.dart';
import 'core/utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
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
  final SessionManager _sessionManager = SessionManager();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _sessionManager.onSessionExpired = _handleSessionExpired;
    _sessionManager.resetInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Only track session if user is authenticated
    if (!auth.isAuthenticated) return;

    if (state == AppLifecycleState.paused) {
      _sessionManager.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _sessionManager.onAppResumed();
    }
  }

  void _handleSessionExpired() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Only logout if user is still authenticated
    if (!auth.isAuthenticated) return;

    debugPrint('🔒 Session expired - logging out user');

    // Logout user
    await auth.logout();

    // Navigate to login screen
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.isAuthenticated) {
          _sessionManager.resetInactivityTimer();
        }
      },
      onPanDown: (_) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.isAuthenticated) {
          _sessionManager.resetInactivityTimer();
        }
      },
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'AmerckCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(),
        builder: (context, child) {
          return GlobalLoadingOverlay(
            backgroundColor: Colors.white,
            progressColor: const Color(0xFF2196F3),
            logoAssetPath: 'assets/images/signlogo.png',
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
