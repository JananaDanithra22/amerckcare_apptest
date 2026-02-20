// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile_model.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/text_styles.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final uid = auth.getCurrentUserId(); // We'll add this method below
      if (uid != null) {
        Provider.of<ProfileProvider>(context, listen: false).loadProfile(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    // Use Firestore data if loaded, otherwise fallback to email
    final email = auth.getCurrentUserEmail() ?? '';
    final profile = profileProvider.profile;
    final displayName = profile?.name ?? email.split('@')[0];
    final firstChar =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'D';

    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: UIConstants.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          // Edit button in top right
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed:
                profileProvider.isLoading
                    ? null
                    : () => _openEditProfile(context, profile, email),
          ),
        ],
      ),
      body:
          profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(
                      context,
                      firstChar,
                      profile,
                      email,
                      auth,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    _buildQuickStats(profile),
                    const SizedBox(height: UIConstants.spacingM),
                    _buildProfessionalInfo(profile),
                    const SizedBox(height: UIConstants.spacingM),
                    _buildContactInfo(profile, email),
                    const SizedBox(height: UIConstants.spacingXl),
                  ],
                ),
              ),
    );
  }

  void _openEditProfile(
    BuildContext context,
    UserProfile? profile,
    String email,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditProfileScreen(currentProfile: profile, email: email),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String firstChar,
    UserProfile? profile,
    String email,
    AuthProvider auth,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: UIConstants.primaryGradient),
      child: Column(
        children: [
          const SizedBox(height: UIConstants.spacingL),
          // Profile Picture Circle
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
          const SizedBox(height: UIConstants.spacingM),
          Text(
            profile?.name ?? email.split('@')[0],
            style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: UIConstants.spacingXs),
          Text(
            profile?.specialization ?? 'Doctor',
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: UIConstants.spacingL),
        ],
      ),
    );
  }

  Widget _buildQuickStats(UserProfile? profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.people,
              value: '12',
              label: 'Today',
              color: UIConstants.infoBlue,
            ),
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: _StatCard(
              icon: Icons.star,
              value: '4.8',
              label: 'Rating',
              color: UIConstants.warningOrange,
            ),
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: _StatCard(
              icon: Icons.medical_services,
              value: '1,234',
              label: 'Total',
              color: UIConstants.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfo(UserProfile? profile) {
    return _SectionCard(
      title: 'Professional Information',
      icon: Icons.work,
      children: [
        _InfoRow(
          icon: Icons.school,
          label: 'Specialization',
          value: profile?.specialization ?? 'Not set',
        ),
        _InfoRow(
          icon: Icons.badge,
          label: 'License Number',
          value: profile?.licenseNumber ?? 'Not set',
        ),
        _InfoRow(
          icon: Icons.trending_up,
          label: 'Experience',
          value: profile?.experience ?? 'Not set',
        ),
      ],
    );
  }

  Widget _buildContactInfo(UserProfile? profile, String fallbackEmail) {
    return _SectionCard(
      title: 'Contact Information',
      icon: Icons.contact_mail,
      children: [
        _InfoRow(
          icon: Icons.email,
          label: 'Email',
          value: profile?.email ?? fallbackEmail,
        ),
        _InfoRow(
          icon: Icons.phone,
          label: 'Phone',
          value: profile?.phone ?? 'Not set',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// EDIT PROFILE SCREEN
// ─────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  final UserProfile? currentProfile;
  final String email;

  const EditProfileScreen({Key? key, this.currentProfile, required this.email})
    : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late TextEditingController _licenseController;
  late TextEditingController _experienceController;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with existing data
    _nameController = TextEditingController(
      text: widget.currentProfile?.name ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.currentProfile?.phone ?? '',
    );
    _specializationController = TextEditingController(
      text: widget.currentProfile?.specialization ?? '',
    );
    _licenseController = TextEditingController(
      text: widget.currentProfile?.licenseNumber ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.currentProfile?.experience ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final uid = auth.getCurrentUserId();

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }

    final updatedProfile = UserProfile(
      uid: uid,
      name: _nameController.text.trim(),
      email: widget.currentProfile?.email ?? widget.email,
      phone: _phoneController.text.trim(),
      specialization: _specializationController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      experience: _experienceController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final success = await profileProvider.updateProfile(updatedProfile);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: UIConstants.successGreen,
          ),
        );
        Navigator.pop(context); // Go back to profile screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.errorMessage ?? 'Update failed'),
            backgroundColor: UIConstants.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: UIConstants.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Lottie animation at top center
              Center(
                child: Lottie.asset(
                  'assets/update.json',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.edit,
                      size: 80,
                      color: UIConstants.primaryBlue,
                    );
                  },
                ),
              ),
              const SizedBox(height: UIConstants.spacingM),

              _buildField(
                'Full Name',
                _nameController,
                Icons.person,
                validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: UIConstants.spacingM),
              _buildField(
                'Phone Number',
                _phoneController,
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: UIConstants.spacingM),
              _buildField(
                'Specialization',
                _specializationController,
                Icons.school,
              ),
              const SizedBox(height: UIConstants.spacingM),
              _buildField('License Number', _licenseController, Icons.badge),
              const SizedBox(height: UIConstants.spacingM),
              _buildField(
                'Experience (e.g. 5 years)',
                _experienceController,
                Icons.trending_up,
              ),
              const SizedBox(height: UIConstants.spacingXl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: UIConstants.buttonHeight,
                child: ElevatedButton(
                  onPressed: profileProvider.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIConstants.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    ),
                  ),
                  child:
                      profileProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Save Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: UIConstants.shadowLight,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: UIConstants.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// ─── Reusable widgets (same as before) ───

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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
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
        ],
      ),
    );
  }
}
