import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/auth_guard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AmerckCare Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
        body: const Center(
          child: Text(
            'Welcome — this is a protected home page.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
