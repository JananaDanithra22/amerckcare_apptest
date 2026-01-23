// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userEmail = auth.getCurrentUserEmail() ?? 'doctor@amerckcare.com';
    final userName = userEmail.split('@')[0];
    final firstChar = userName.isNotEmpty ? userName[0].toUpperCase() : 'D';

    // TODO: Replace with real data from backend
    final doctorData = {
      'name': 'Dr. $userName',
      'specialization': 'General Physician',
      'licenseNumber': 'MED-2024-${userName.hashCode % 10000}',
      'email': userEmail,
      'phone': '+1 (555) 123-4567',
      'experience': '8 years',
      'patientsToday': '12',
      'totalPatients': '450+',
      'rating': '4.8',
      'consultations': '1,234',
    };

    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: UIConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            _buildProfileHeader(context, firstChar, doctorData, auth),

            const SizedBox(height: UIConstants.spacingM),

            // Quick Stats
            _buildQuickStats(doctorData),

            const SizedBox(height: UIConstants.spacingM),

            // Professional Information
            _buildProfessionalInfo(doctorData),

            const SizedBox(height: UIConstants.spacingM),

            // Contact Information
            _buildContactInfo(doctorData),

            const SizedBox(height: UIConstants.spacingXl),
          ],
        ),
      ),
    );
  }

  /// Profile Header with Photo and Basic Info
  Widget _buildProfileHeader(
    BuildContext context,
    String firstChar,
    Map<String, String> data,
    AuthProvider auth,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: UIConstants.primaryGradient),
      child: Column(
        children: [
          const SizedBox(height: UIConstants.spacingL),
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: UIConstants.shadowMedium,
                ),
                child: Center(
                  child: Text(
                    firstChar,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: UIConstants.primaryBlue,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(UIConstants.spacingS),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: UIConstants.shadowLight,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),
          // Name
          Text(
            data['name']!,
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: UIConstants.spacingXs),
          // Specialization
          Text(
            data['specialization']!,
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: UIConstants.spacingS),
          // License Number Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingM,
              vertical: UIConstants.spacingXs + 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(UIConstants.radiusXl),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 16, color: Colors.white),
                const SizedBox(width: UIConstants.spacingXs + 2),
                Text(
                  'License: ${data['licenseNumber']}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          // Login Type Badge
          if (auth.loginType != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingM,
                vertical: UIConstants.spacingXs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getLoginTypeIcon(auth.loginType!),
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: UIConstants.spacingXs + 2),
                  Text(
                    'Signed in with ${_getLoginTypeText(auth.loginType!)}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: UIConstants.spacingL),
        ],
      ),
    );
  }

  /// Quick Stats Cards
  Widget _buildQuickStats(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.people,
              value: data['patientsToday']!,
              label: 'Today',
              color: UIConstants.infoBlue,
            ),
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: _StatCard(
              icon: Icons.star,
              value: data['rating']!,
              label: 'Rating',
              color: UIConstants.warningOrange,
            ),
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: _StatCard(
              icon: Icons.medical_services,
              value: data['consultations']!,
              label: 'Total',
              color: UIConstants.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  /// Professional Information Section
  Widget _buildProfessionalInfo(Map<String, String> data) {
    return _SectionCard(
      title: 'Professional Information',
      icon: Icons.work,
      children: [
        _InfoRow(
          icon: Icons.school,
          label: 'Specialization',
          value: data['specialization']!,
        ),
        _InfoRow(
          icon: Icons.badge,
          label: 'License Number',
          value: data['licenseNumber']!,
        ),
        _InfoRow(
          icon: Icons.trending_up,
          label: 'Experience',
          value: data['experience']!,
        ),
        _InfoRow(
          icon: Icons.groups,
          label: 'Total Patients',
          value: data['totalPatients']!,
        ),
      ],
    );
  }

  /// Contact Information Section
  Widget _buildContactInfo(Map<String, String> data) {
    return _SectionCard(
      title: 'Contact Information',
      icon: Icons.contact_mail,
      children: [
        _InfoRow(
          icon: Icons.email,
          label: 'Email',
          value: data['email']!,
          isClickable: true,
        ),
        _InfoRow(
          icon: Icons.phone,
          label: 'Phone',
          value: data['phone']!,
          isClickable: true,
        ),
      ],
    );
  }

  IconData _getLoginTypeIcon(LoginType type) {
    switch (type) {
      case LoginType.google:
        return Icons.g_mobiledata;
      case LoginType.facebook:
        return Icons.facebook;
      case LoginType.emailPassword:
        return Icons.email;
    }
  }

  String _getLoginTypeText(LoginType type) {
    switch (type) {
      case LoginType.google:
        return 'Google';
      case LoginType.facebook:
        return 'Facebook';
      case LoginType.emailPassword:
        return 'Email';
    }
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: UIConstants.shadowLight,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingS),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.radiusS),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(value, style: AppTextStyles.statValue),
          const SizedBox(height: UIConstants.spacingXs),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}

/// Section Card Widget
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: UIConstants.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            child: Row(
              children: [
                Icon(icon, color: UIConstants.primaryBlue, size: 20),
                const SizedBox(width: UIConstants.spacingS),
                Text(title, style: AppTextStyles.headingSmall),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isClickable;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingM,
        vertical: UIConstants.spacingM,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingS),
            decoration: BoxDecoration(
              color: UIConstants.mediumGrey,
              borderRadius: BorderRadius.circular(UIConstants.radiusS),
            ),
            child: Icon(icon, color: UIConstants.textMedium, size: 20),
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.infoRowLabel),
                const SizedBox(height: UIConstants.spacingXs),
                Text(value, style: AppTextStyles.infoRowValue),
              ],
            ),
          ),
          if (isClickable)
            Icon(Icons.open_in_new, size: 16, color: UIConstants.textLight),
        ],
      ),
    );
  }
}
