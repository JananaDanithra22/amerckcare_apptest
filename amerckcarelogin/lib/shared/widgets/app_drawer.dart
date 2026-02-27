// lib/shared/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../core/utils/session_manager.dart';
import '../../features/profile/providers/profile_avatar_provider.dart';
import '../../features/profile/widgets/profile_avatar.dart';
import '../../features/profile/providers/profile_provider.dart';

/// Reusable app drawer with user profile and navigation
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userEmail = auth.getCurrentUserEmail() ?? 'User';

    // Use saved profile name if available, fallback to email prefix
    final displayName =
        profileProvider.profile?.name ?? userEmail.split('@')[0];
    final firstChar =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    return Drawer(
      child: Column(
        children: [
          // ✅ User Profile Header with clickable avatar
          _buildUserHeader(context, userEmail, firstChar, displayName, auth),

          // ✅ Navigation Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.toProfile(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    AppRoutes.toSettings(context);
                  },
                ),
                const Divider(),
              ],
            ),
          ),

          // ✅ Session Status Indicator
          if (SessionManager().isSessionActive)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Session Active',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // ✅ Logout Button at Bottom
          Container(
            margin: const EdgeInsets.all(16),
            child: _LogoutButton(auth: auth),
          ),
        ],
      ),
    );
  }

  /// Build user profile header with clickable avatar
 Widget _buildUserHeader(
  BuildContext context,
  String userEmail,
  String firstChar,
  String displayName,   // ← ADD
  AuthProvider auth,
) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C8AE5), // Primary blue
            Color(0xFF0650A2), // Dark blue
          ],
        ),
      ),
      currentAccountPicture: Consumer<ProfileAvatarProvider>(
        builder: (context, avatarProvider, _) {
          return ProfileAvatar(
            photoFile: avatarProvider.photoFile,
            displayLetter: firstChar,
            size: 72,
            letterColor: const Color(0xFF1C8AE5),
            backgroundColor: Colors.white,
            onTap: () {
              Navigator.pop(context);
              AppRoutes.toProfile(context);
            },
          );
        },
      ),
      // REPLACE with:
      accountName: Text(
        displayName.isNotEmpty ? 'Dr. $displayName' : 'Welcome!',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(userEmail, style: const TextStyle(fontSize: 14)),
      otherAccountsPictures: [
        if (auth.loginType != null)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getLoginTypeIcon(auth.loginType!),
              size: 20,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  /// Build menu item
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1C8AE5)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      hoverColor: Colors.blue.shade50,
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
}

/// Logout button widget with confirmation dialog
class _LogoutButton extends StatelessWidget {
  final AuthProvider auth;

  const _LogoutButton({required this.auth});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleLogout(context),
      icon: const Icon(Icons.logout),
      label: const Text('Log Out'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final navigator = Navigator.of(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _LogoutConfirmDialog(),
    );

    if (shouldLogout == true) {
      try {
        navigator.pop();
        SessionManager().stopSession();
        await auth.logout();
        navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      } catch (e) {
        debugPrint('Error during logout: $e');
        navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }
}

/// Styled logout confirmation dialog
class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Log out of the app?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'You will be signed out and will need to log in again.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
