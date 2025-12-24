// lib/features/profile/screens/change_password_screen.dart
// DAY 1: UI Layout + Client-Side Validation (No Firebase yet)

import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/ui_constants.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/custom_button.dart';

/// Change Password Screen - Day 1: UI + Validation Only
/// TODO Day 2: Add Firebase authentication
/// TODO Day 3: Add re-authentication for security
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

  /// Handle password change (Day 1: Just validation)
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

    // TODO Day 2: Add Firebase re-authentication
    // TODO Day 2: Update password in Firebase

    // Day 1: Show success message (mock)
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✅ Password validation successful! (Firebase integration coming in Day 2)',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Clear fields after success
    _currentPasswordCtrl.clear();
    _newPasswordCtrl.clear();
    _confirmPasswordCtrl.clear();
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
