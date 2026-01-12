// lib/features/auth/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/ui_constants.dart';
import '../widgets/background_line_art.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Screen for password recovery
/// Follows single responsibility principle - only handles password reset
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  String? _emailError;
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Send password reset email
  Future<void> _sendPasswordResetEmail() async {
    // Clear previous errors
    setState(() => _emailError = null);

    // Validate email
    final emailValidation = Validators.validateEmail(_emailController.text.trim());
    if (emailValidation != null) {
      setState(() => _emailError = emailValidation);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      // Configure action code settings
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://amerckcare-9d72a.firebaseapp.com',
        handleCodeInApp: false,
        androidPackageName: 'com.amerckcare.app',
        androidInstallApp: true,
        androidMinimumVersion: '1',
      );

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });

        _showSuccessSnackbar(email);
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _handleGenericError(e);
    }
  }

  /// Handle Firebase authentication errors
  void _handleFirebaseError(FirebaseAuthException e) {
    String errorMessage;
    bool showAsSuccess = false;

    switch (e.code) {
      case 'user-not-found':
        // Security best practice: don't reveal if user exists
        errorMessage = 'If an account exists with this email, a reset link has been sent.';
        showAsSuccess = true;
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address format';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many requests. Please try again later';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your connection';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled';
        break;
      default:
        errorMessage = 'Failed to send reset email. Please try again';
    }

    if (mounted) {
      if (showAsSuccess) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _emailError = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  /// Handle generic errors
  void _handleGenericError(Object e) {
    if (mounted) {
      setState(() {
        _emailError = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Show success message
  void _showSuccessSnackbar(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset email sent to $email'),
        backgroundColor: UIConstants.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: BackgroundLineArtPainter(),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingL),
              child: Form(
                key: _formKey,
                child: _emailSent ? _buildSuccessView() : _buildFormView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Build form view (initial state)
  Widget _buildFormView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(),
        const SizedBox(height: UIConstants.spacingL),
        _buildTitle(),
        const SizedBox(height: UIConstants.spacingM),
        _buildDescription(),
        const SizedBox(height: UIConstants.spacingXl),
        _buildEmailField(),
        const SizedBox(height: UIConstants.spacingL),
        _buildSendButton(),
        const SizedBox(height: UIConstants.spacingM),
        _buildBackToLoginButton(),
      ],
    );
  }

  /// Build success view (after email sent)
  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSuccessIcon(),
        const SizedBox(height: UIConstants.spacingL),
        _buildSuccessTitle(),
        const SizedBox(height: UIConstants.spacingM),
        _buildSuccessMessage(),
        const SizedBox(height: UIConstants.spacingS),
        _buildEmailDisplay(),
        const SizedBox(height: UIConstants.spacingL),
        _buildInstructionCard(),
        const SizedBox(height: UIConstants.spacingL),
        _buildResendButton(),
        const SizedBox(height: UIConstants.spacingM),
        _buildReturnToLoginButton(),
      ],
    );
  }

  // UI Components
  Widget _buildIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: UIConstants.primaryBlue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_reset,
        size: 50,
        color: UIConstants.primaryBlue,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Forgot Password?',
      style: Theme.of(context).textTheme.displayMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      'Enter your email address and we\'ll send you instructions to reset your password.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: UIConstants.spacingS),
        CustomTextField(
          controller: _emailController,
          hintText: 'Enter your email',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          validator: Validators.validateEmail,
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return CustomButton(
      text: 'Send Reset Link',
      onPressed: _sendPasswordResetEmail,
      isLoading: _isLoading,
      backgroundColor: UIConstants.primaryBlue,
      width: UIConstants.buttonWidth,
      height: UIConstants.buttonHeight,
      borderRadius: UIConstants.buttonRadius,
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        'Back to Login',
        style: TextStyle(
          color: UIConstants.primaryBlue,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return const Icon(
      Icons.mark_email_read,
      size: 80,
      color: UIConstants.successGreen,
    );
  }

  Widget _buildSuccessTitle() {
    return Text(
      'Check Your Email',
      style: Theme.of(context).textTheme.displayMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSuccessMessage() {
    return Text(
      'We have sent password reset instructions to:',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildEmailDisplay() {
    return Text(
      _emailController.text.trim(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: UIConstants.primaryBlue,
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      decoration: BoxDecoration(
        color: UIConstants.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(
          color: UIConstants.infoBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            color: UIConstants.infoBlue,
            size: 24,
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Next Steps:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            '• Check your spam/junk folder if you do not see the email\n'
            '• After resetting your password, open the AmerckCare app and sign in with your new password',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendButton() {
    return OutlinedButton(
      onPressed: () {
        setState(() => _emailSent = false);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 14,
        ),
        side: const BorderSide(
          color: UIConstants.primaryBlue,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
      ),
      child: const Text(
        'Resend Email',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: UIConstants.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildReturnToLoginButton() {
    return CustomButton(
      text: 'Back to Login',
      onPressed: () => Navigator.pop(context),
      backgroundColor: UIConstants.primaryBlue,
      width: UIConstants.buttonWidth,
      height: UIConstants.buttonHeight,
      borderRadius: UIConstants.buttonRadius,
    );
  }
}