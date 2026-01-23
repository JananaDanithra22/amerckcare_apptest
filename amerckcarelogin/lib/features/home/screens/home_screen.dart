// lib/features/home/screens/home_screen.dart - DOCTOR'S DASHBOARD (CONSOLIDATED)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/session_manager.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionManager().startSession();
      debugPrint('✅ Home screen loaded - session monitoring active');
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userEmail = auth.getCurrentUserEmail() ?? 'User';
    final userName = userEmail.split('@')[0];

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(scaffoldKey: _scaffoldKey),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MorningBriefingCard(userName: userName),
                    const SizedBox(height: 20),
                    const QuickSearchBar(),
                    const SizedBox(height: 24),
                    const QueueStatusSection(),
                    const SizedBox(height: 24),
                    const CoreFeaturesGrid(),
                    const SizedBox(height: 24),
                    const QuickDocumentsGrid(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}