// lib/features/settings/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../config/routes.dart';
import '../widgets/biometric_settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: UIConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: UIConstants.spacingM),

            // Account Settings Section
            _buildAccountSettings(),

            const SizedBox(height: UIConstants.spacingM),

            // Security Settings Section
            _buildSecuritySettings(),

            const SizedBox(height: UIConstants.spacingM),

            // App Preferences Section
            _buildAppPreferences(),

            const SizedBox(height: UIConstants.spacingM),

            // About & Legal Section
            _buildAboutLegal(),

            const SizedBox(height: UIConstants.spacingXl),
          ],
        ),
      ),
    );
  }

  /// Account Settings Section
  Widget _buildAccountSettings() {
    return _SectionCard(
      title: 'Account Settings',
      icon: Icons.manage_accounts,
      children: [
        _SettingsTile(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit Profile coming soon')),
            );
          },
        ),
        _SettingsTile(
          icon: Icons.lock,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () {
            AppRoutes.toChangePassword(context);
          },
        ),
      ],
    );
  }

  /// Security Settings Section
  Widget _buildSecuritySettings() {
    return _SectionCard(
      title: 'Security & Privacy',
      icon: Icons.security,
      children: [
        // Biometric Login Tile
        const BiometricSettingsTile(),

        _SettingsTile(
          icon: Icons.shield,
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('2FA coming soon')));
          },
        ),
        _SettingsTile(
          icon: Icons.devices,
          title: 'Active Sessions',
          subtitle: 'Manage your active devices',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session management coming soon')),
            );
          },
        ),
        _SettingsTile(
          icon: Icons.privacy_tip,
          title: 'Privacy Settings',
          subtitle: 'Control your data and privacy',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy settings coming soon')),
            );
          },
        ),
      ],
    );
  }

  /// App Preferences Section
  Widget _buildAppPreferences() {
    return _SectionCard(
      title: 'App Preferences',
      icon: Icons.settings,
      children: [
        _SettingsTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle:
              _notificationsEnabled
                  ? 'All notifications enabled'
                  : 'Notifications disabled',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Notifications enabled' : 'Notifications disabled',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            activeColor: UIConstants.primaryBlue,
          ),
        ),
        _SettingsTile(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'English (US)',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Language settings coming soon')),
            );
          },
        ),
        _SettingsTile(
          icon: Icons.palette,
          title: 'Theme',
          subtitle: 'Light mode',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Theme settings coming soon')),
            );
          },
        ),
        _SettingsTile(
          icon: Icons.storage,
          title: 'Storage & Cache',
          subtitle: 'Manage app data and cache',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage settings coming soon')),
            );
          },
        ),
      ],
    );
  }

  /// About & Legal Section
  Widget _buildAboutLegal() {
    return _SectionCard(
      title: 'About & Legal',
      icon: Icons.info_outline,
      children: [
        _SettingsTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQs and contact support',
          onTap: () {
            AppRoutes.toHelpSupport(context);
          },
        ),
        _SettingsTile(
          icon: Icons.business,
          title: 'About AmerckCare',
          subtitle: 'Learn more about us',
          onTap: () {
            AppRoutes.toAboutUs(context);
          },
        ),
        _SettingsTile(
          icon: Icons.description,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of Service coming soon')),
            );
          },
        ),
        _SettingsTile(
          icon: Icons.policy,
          title: 'Privacy Policy',
          subtitle: 'How we handle your data',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy Policy coming soon')),
            );
          },
        ),
        _SettingsTile(
          icon: Icons.info,
          title: 'App Version',
          subtitle: 'Version 1.0.0 (Build 2024.12.18)',
          onTap: () {
            _showAboutDialog();
          },
        ),
      ],
    );
  }

  /// Show about dialog
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusL),
            ),
            title: Row(
              children: [
                Image.asset(
                  'assets/images/signlogo.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.local_hospital,
                      size: 40,
                      color: UIConstants.primaryBlue,
                    );
                  },
                ),
                const SizedBox(width: UIConstants.spacingM),
                const Text('About AmerckCare'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version: 1.0.0'),
                SizedBox(height: UIConstants.spacingS),
                Text('Build: 2024.12.18'),
                SizedBox(height: UIConstants.spacingM),
                Text('© 2024 AmerckCare'),
                SizedBox(height: UIConstants.spacingS),
                Text(
                  'Your trusted healthcare companion for modern medical practice.',
                  style: TextStyle(color: UIConstants.textMedium, fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
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
                Container(
                  padding: const EdgeInsets.all(UIConstants.spacingS),
                  decoration: BoxDecoration(
                    color: UIConstants.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusS),
                  ),
                  child: Icon(icon, color: UIConstants.primaryBlue, size: 20),
                ),
                const SizedBox(width: UIConstants.spacingM),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: UIConstants.textDark,
                  ),
                ),
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

/// Settings Tile Widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingM,
          vertical: UIConstants.spacingM,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingS),
              decoration: BoxDecoration(
                color: UIConstants.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: Icon(icon, color: UIConstants.primaryBlue, size: 20),
            ),
            const SizedBox(width: UIConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: UIConstants.textDark,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: UIConstants.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: UIConstants.textLight,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
