// lib/features/home/screens/home_screen.dart - AMERCKCARE HEALTHCARE EMR HOME

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../config/routes.dart';
import '../../../core/utils/session_manager.dart';
import '../../../shared/widgets/app_drawer.dart';

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

    // ✅ Start session monitoring when user enters home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionManager().startSession();
      debugPrint('✅ Home screen loaded - session monitoring active');
    });
  }

  @override
  void dispose() {
    super.dispose();
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
            // Custom Header Bar
            _buildCustomHeader(context, userName, auth),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Welcome Section
                    _buildHeroSection(userName),

                    const SizedBox(height: 32),

                    // Main Features Grid
                    _buildFeaturesSection(context),

                    const SizedBox(height: 32),

                    // Documents Quick Access (from image)
                    _buildDocumentsSection(context),

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

  /// Custom Header Bar
  Widget _buildCustomHeader(
    BuildContext context,
    String userName,
    AuthProvider auth,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF3B5998)),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Menu',
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/signlogo.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.local_hospital,
                size: 32,
                color: Color(0xFF3B5998),
              );
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'AmerckCare',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B5998),
            ),
          ),
          const Spacer(),
          if (SessionManager().isSessionActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Hero Section - Welcome Banner
  Widget _buildHeroSection(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C8AE5), // Primary blue
            Color(0xFF0650A2), // Dark blue
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Everything You Need',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'in One Platform',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Our EMR system provides all the tools healthcare professionals need to deliver exceptional care.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Main Features Section
  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Core Features',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            _FeatureCard(
              icon: Icons.medical_information,
              title: 'Care View',
              description: 'Complete patient history and visit records',
              color: const Color(0xFF4CAF50),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Care View coming soon')),
                );
              },
            ),
            _FeatureCard(
              icon: Icons.medication,
              title: 'Drug Cabinet',
              description: 'Smart prescription management system',
              color: const Color(0xFFFF9800),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Drug Cabinet coming soon')),
                );
              },
            ),
            _FeatureCard(
              icon: Icons.science,
              title: 'Investigations',
              description: 'Lab results and diagnostic reports',
              color: const Color(0xFF2196F3),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Investigations coming soon')),
                );
              },
            ),
            _FeatureCard(
              icon: Icons.description,
              title: 'Documents',
              description: 'Medical letters and certificates',
              color: const Color(0xFF9C27B0),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Documents coming soon')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Documents Section (inspired by the image)
  Widget _buildDocumentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quick Document Templates',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all documents')),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DocumentTemplateCard(
          icon: Icons.psychology,
          iconColor: const Color(0xFF7C4DFF),
          title: 'AI Writer',
          description: 'Generate professional medical letters using AI',
          features: const [
            'Generate professional letters in seconds',
            'Multiple templates available',
            'Includes patient data automatically',
          ],
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI Writer coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CompactDocumentCard(
                icon: Icons.send,
                iconColor: const Color(0xFF4CAF50),
                title: 'Referral Letter',
                subtitle: 'Create referral for specialists',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Referral Letter coming soon'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompactDocumentCard(
                icon: Icons.event_note,
                iconColor: const Color(0xFFFF5252),
                title: 'Medical Leave',
                subtitle: 'Issue leave certificate',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medical Leave coming soon')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CompactDocumentCard(
                icon: Icons.assignment,
                iconColor: const Color(0xFFFF6D00),
                title: 'Death Certificate',
                subtitle: 'Confirmation letter',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Death Certificate coming soon'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompactDocumentCard(
                icon: Icons.edit_document,
                iconColor: const Color(0xFF7C4DFF),
                title: 'Custom Letter',
                subtitle: 'Create from scratch',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Custom Letter coming soon')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Feature Card Widget
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Document Template Card
class _DocumentTemplateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String> features;
  final VoidCallback onTap;

  const _DocumentTemplateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  ...features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: iconColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact Document Card
class _CompactDocumentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CompactDocumentCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
