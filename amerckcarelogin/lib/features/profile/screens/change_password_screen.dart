// lib/features/profile/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/custom_button.dart';

/// Screen for changing user password
/// Follows clean code principles with separated concerns
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validate all password fields
  bool _validateFields() {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    // Validate current password
    final currentError = Validators.validatePassword(
      _currentPasswordController.text,
    );
    if (currentError != null) {
      setState(() => _currentPasswordError = currentError);
      isValid = false;
    }

    // Validate new password
    final newError = Validators.validatePassword(_newPasswordController.text);
    if (newError != null) {
      setState(() => _newPasswordError = newError);
      isValid = false;
    } else if (_newPasswordController.text == _currentPasswordController.text) {
      setState(() {
        _newPasswordError =
            'New password must be different from current password';
      });
      isValid = false;
    }

    // Validate confirm password
    final confirmError = Validators.validateConfirmPassword(
      _newPasswordController.text,
      _confirmPasswordController.text,
    );
    if (confirmError != null) {
      setState(() => _confirmPasswordError = confirmError);
      isValid = false;
    }

    return isValid;
  }

  /// Re-authenticate user with current password
  Future<bool> _reauthenticateUser(String currentPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        debugPrint('No user logged in');
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleReauthenticationError(e);
      return false;
    } catch (e) {
      setState(() {
        _currentPasswordError = 'An unexpected error occurred';
      });
      return false;
    }
  }

  /// Handle re-authentication errors
  void _handleReauthenticationError(FirebaseAuthException e) {
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
  }

  /// Update password in Firebase
  Future<bool> _updatePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleUpdatePasswordError(e);
      return false;
    } catch (e) {
      setState(() {
        _newPasswordError = 'An unexpected error occurred';
      });
      return false;
    }
  }

  /// Handle password update errors
  void _handleUpdatePasswordError(FirebaseAuthException e) {
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
  }

  /// Handle password change process
  Future<void> _handleChangePassword() async {
    // Clear errors and validate
    if (!_validateFields()) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: Re-authenticate
      final isAuthenticated = await _reauthenticateUser(
        _currentPasswordController.text,
      );

      if (!isAuthenticated) {
        setState(() => _isLoading = false);
        return;
      }

      // Step 2: Update password
      final isUpdated = await _updatePassword(_newPasswordController.text);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (isUpdated) {
        _showSuccessAndNavigateBack();
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        _showErrorSnackbar('An unexpected error occurred');
      }
    }
  }

  /// Show success message and navigate back
  void _showSuccessAndNavigateBack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Password changed successfully!'),
        backgroundColor: UIConstants.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );

    // Clear fields
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    // Navigate back
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: UIConstants.errorRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.lightGrey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: UIConstants.spacingL),
              _buildPasswordRequirements(),
              const SizedBox(height: UIConstants.spacingL),
              _buildPasswordFields(),
              const SizedBox(height: UIConstants.spacingXl),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Change Password'),
      elevation: 0,
      backgroundColor: UIConstants.primaryBlue,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      decoration: BoxDecoration(
        color: UIConstants.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(color: UIConstants.infoBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: UIConstants.infoBlue.withOpacity(0.8),
            size: 24,
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Text(
              'For your security, you\'ll need to enter your current password before setting a new one.',
              style: AppTextStyles.bodySmall.copyWith(
                color: UIConstants.infoBlue.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: UIConstants.spacingS),
              Text('Password Requirements', style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildRequirement('At least 6 characters long'),
          _buildRequirement('Different from your current password'),
          _buildRequirement('Contains letters and numbers (recommended)'),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: UIConstants.successGreen.withOpacity(0.8),
          ),
          const SizedBox(width: UIConstants.spacingS),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildPasswordField(
          label: 'Current Password',
          controller: _currentPasswordController,
          errorText: _currentPasswordError,
          obscureText: _obscureCurrentPassword,
          onToggle: () {
            setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
          },
          onChanged: () {
            if (_currentPasswordError != null) {
              setState(() => _currentPasswordError = null);
            }
          },
        ),
        const SizedBox(height: UIConstants.spacingL),
        _buildPasswordField(
          label: 'New Password',
          controller: _newPasswordController,
          errorText: _newPasswordError,
          obscureText: _obscureNewPassword,
          onToggle: () {
            setState(() => _obscureNewPassword = !_obscureNewPassword);
          },
          onChanged: () {
            if (_newPasswordError != null) {
              setState(() => _newPasswordError = null);
            }
          },
        ),
        const SizedBox(height: UIConstants.spacingL),
        _buildPasswordField(
          label: 'Confirm New Password',
          controller: _confirmPasswordController,
          errorText: _confirmPasswordError,
          obscureText: _obscureConfirmPassword,
          onToggle: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
          onChanged: () {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String? errorText,
    required bool obscureText,
    required VoidCallback onToggle,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.headingSmall),
        const SizedBox(height: UIConstants.spacingS),
        CustomTextField(
          controller: controller,
          hintText: 'Enter $label',
          errorText: errorText,
          obscureText: obscureText,
          onToggleVisibility: onToggle,
          onChanged: (_) => onChanged(),
          validator: Validators.validatePassword,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: CustomButton(
        text: 'Change Password',
        onPressed: _handleChangePassword,
        isLoading: _isLoading,
        backgroundColor: UIConstants.primaryBlue,
        width: UIConstants.buttonWidth,
        height: UIConstants.buttonHeight,
        borderRadius: UIConstants.buttonRadius,
      ),
    );
  }
}
