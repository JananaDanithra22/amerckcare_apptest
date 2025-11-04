import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Check authentication
    if (!auth.isAuthenticated) {
      // Delay redirect until after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });

      // Show loading or placeholder while redirecting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If authenticated → show protected widget
    return child;
  }
}
