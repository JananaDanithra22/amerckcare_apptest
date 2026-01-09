// lib/features/profile/screens/change_password_screen.dart
// Complete Firebase Authentication Integration

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/ui_constants.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/custom_button.dart';

/// Change Password Screen with Firebase Integration
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for password fields
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Visibility toggles
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Error messages
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  /// Validate all fields
  bool _validateFields() {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    // Validate current password
    final currentPassValidation = Validators.validatePassword(
      _currentPasswordCtrl.text,
    );
    if (currentPassValidation != null) {
      setState(() => _currentPasswordError = currentPassValidation);
      isValid = false;
    }

    // Validate new password
    final newPassValidation = Validators.validatePassword(
      _newPasswordCtrl.text,
    );
    if (newPassValidation != null) {
      setState(() => _newPasswordError = newPassValidation);
      isValid = false;
    } else if (_newPasswordCtrl.text == _currentPasswordCtrl.text) {
      setState(
        () =>
            _newPasswordError =
                'New password must be different from current password',
      );
      isValid = false;
    }

    // Validate confirm password
    final confirmPassValidation = Validators.validateConfirmPassword(
      _newPasswordCtrl.text,
      _confirmPasswordCtrl.text,
    );
    if (confirmPassValidation != null) {
      setState(() => _confirmPasswordError = confirmPassValidation);
      isValid = false;
    }

    return isValid;
  }

  /// ✅ Re-authenticate user with current password (REQUIRED by Firebase)
  Future<bool> _reauthenticateUser(String currentPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        debugPrint('🔴 No user logged in');
        return false;
      }

      debugPrint('🔐 Re-authenticating user: ${user.email}');

      // Create credential with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(credential);
      debugPrint('✅ Re-authentication successful');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 Re-authentication failed: ${e.code}');
      debugPrint('🔴 Error message: ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'Current password is incorrect';
          break;
        case 'user-not-found':
          errorMessage = 'User account not found';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check your connection';
          break;
        default:
          errorMessage = 'Authentication failed. Please try again';
      }

      setState(() => _currentPasswordError = errorMessage);
      return false;
    } catch (e) {
      debugPrint('🔴 Unexpected error during re-authentication: $e');
      setState(() => _currentPasswordError = 'An unexpected error occurred');
      return false;
    }
  }

  /// ✅ Update password in Firebase
  Future<bool> _updatePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('🔴 No user logged in');
        return false;
      }

      debugPrint('🔐 Updating password for user: ${user.email}');

      // Update password
      await user.updatePassword(newPassword);
      debugPrint('✅ Password updated successfully in Firebase');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 Password update failed: ${e.code}');
      debugPrint('🔴 Error message: ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log out and log back in, then try again';
          break;
        default:
          errorMessage = 'Failed to update password. Please try again';
      }

      setState(() => _newPasswordError = errorMessage);
      return false;
    } catch (e) {
      debugPrint('🔴 Unexpected error updating password: $e');
      setState(() => _newPasswordError = 'An unexpected error occurred');
      return false;
    }
  }

  /// ✅ Handle password change with Firebase
  Future<void> _handleChangePassword() async {
    // Clear any existing errors
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    // Validate all fields
    if (!_validateFields()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Re-authenticate with current password
      final isAuthenticated = await _reauthenticateUser(
        _currentPasswordCtrl.text,
      );

      if (!isAuthenticated) {
        setState(() => _isLoading = false);
        return;
      }

      // Step 2: Update to new password
      final isUpdated = await _updatePassword(_newPasswordCtrl.text);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (isUpdated) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Password changed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear fields after success
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();

        // Optional: Go back to profile screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('🔴 Unexpected error in password change flow: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 0,
        backgroundColor: const Color(0xFF1C8AE5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              _buildInfoCard(),

              const SizedBox(height: 24),

              // Password Requirements Card
              _buildPasswordRequirements(),

              const SizedBox(height: 24),

              // Current Password Field
              const Text(
                'Current Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _currentPasswordCtrl,
                hintText: 'Enter your current password',
                errorText: _currentPasswordError,
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(
                    () => _obscureCurrentPassword = !_obscureCurrentPassword,
                  );
                },
                onChanged: (value) {
                  if (_currentPasswordError != null) {
                    setState(() => _currentPasswordError = null);
                  }
                },
                validator: (value) {},
              ),

              const SizedBox(height: 20),

              // New Password Field
              const Text(
                'New Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _newPasswordCtrl,
                hintText: 'Enter your new password',
                errorText: _newPasswordError,
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
                onChanged: (value) {
                  if (_newPasswordError != null) {
                    setState(() => _newPasswordError = null);
                  }
                },
                validator: (value) {},
              ),

              const SizedBox(height: 20),

              // Confirm New Password Field
              const Text(
                'Confirm New Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _confirmPasswordCtrl,
                hintText: 'Re-enter your new password',
                errorText: _confirmPasswordError,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                onChanged: (value) {
                  if (_confirmPasswordError != null) {
                    setState(() => _confirmPasswordError = null);
                  }
                },
                validator: (value) {},
              ),

              const SizedBox(height: 32),

              // Change Password Button
              Center(
                child: CustomButton(
                  text: 'Change Password',
                  onPressed: _handleChangePassword,
                  isLoading: _isLoading,
                  backgroundColor: const Color(0xFF1C8AE5),
                  width: UIConstants.buttonWidth,
                  height: UIConstants.buttonHeight,
                  borderRadius: UIConstants.buttonRadius,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Info Card explaining the process
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'For your security, you\'ll need to enter your current password before setting a new one.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Password Requirements Card
  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Password Requirements',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirement('At least 6 characters long'),
          _buildRequirement('Different from your current password'),
          _buildRequirement('Contains letters and numbers (recommended)'),
        ],
      ),
    );
  }

  /// Individual requirement item
  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
