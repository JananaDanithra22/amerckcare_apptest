import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'shared/widgets/loading_overlay.dart'; // <- your overlay (singleton)
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Keep other providers here if you need them
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmerckCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(),

      // Wrap every route with your GlobalLoadingOverlay using builder
      builder: (context, child) {
        return GlobalLoadingOverlay(
          backgroundColor: Colors.white,
          progressColor: const Color(0xFF2196F3),
          // you can override the logo path if needed; default already inside widget
          logoAssetPath: 'assets/images/signlogo.png',
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
