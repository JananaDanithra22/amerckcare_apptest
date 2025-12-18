// lib/shared/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../core/utils/session_manager.dart';

/// Reusable app drawer with user profile and navigation
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userEmail = auth.getCurrentUserEmail() ?? 'User';
    final firstChar = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U';

    return Drawer(
      child: Column(
        children: [
          // ✅ User Profile Header with clickable avatar
          _buildUserHeader(context, userEmail, firstChar, auth),

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
                    // Already on home, no navigation needed
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help coming soon')),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          // ✅ Session Status Indicator (Optional)
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
      currentAccountPicture: GestureDetector(
        onTap: () {
          // Navigate to profile when avatar is tapped
          Navigator.pop(context); // Close drawer first
          Navigator.pushNamed(context, AppRoutes.profile);
        },
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            firstChar,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C8AE5),
            ),
          ),
        ),
      ),
      accountName: const Text(
        'Welcome!',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About AmerckCare'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version 1.0.0'),
                SizedBox(height: 8),
                Text('© 2024 AmerckCare'),
                SizedBox(height: 16),
                Text(
                  'Your trusted healthcare companion',
                  style: TextStyle(color: Colors.grey),
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
    // Close drawer first
    Navigator.pop(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _LogoutConfirmDialog(),
    );

    if (shouldLogout == true && context.mounted) {
      // Stop session monitoring
      SessionManager().stopSession();

      // Perform logout
      await auth.logout();

      // ✅ FIX: Use pushNamedAndRemoveUntil to completely clear navigation stack
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false, // Remove all previous routes
        );
      }
    }
  }
}

/// Styled logout confirmation dialog
class _LogoutConfirmDialog extends StatelessWidget {
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
                  child: _DialogButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(false),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: 'Log Out',
                    onPressed: () => Navigator.of(context).pop(true),
                    isPrimary: true,
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

/// Styled dialog button with hover effect
class _DialogButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _DialogButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue : Colors.transparent,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isHovered ? Colors.white : Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
