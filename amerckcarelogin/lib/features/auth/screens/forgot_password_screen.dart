// lib/features/auth/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../widgets/background_line_art.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../../core/constants/ui_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  String? _emailError;
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _emailError = null;
    });

    // Validate email
    final emailValidation = Validators.validateEmail(_emailCtrl.text.trim());
    if (emailValidation != null) {
      setState(() {
        _emailError = emailValidation;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailCtrl.text.trim();

      debugPrint('🔐 Attempting to send password reset email to: $email');

      // ✅ Configure action code settings for better control
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://amerckcare-9d72a.firebaseapp.com', // Firebase hosted page
        handleCodeInApp: false, // ✅ Let Firebase show the web page
        androidPackageName: 'com.amerckcare.app', // Your Android package name
        androidInstallApp: true, // If the app isn’t installed, prompt install
        androidMinimumVersion: '1', // Minimum version required
      );

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      debugPrint('✅ Password reset email sent successfully to: $email');

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 Firebase Auth error: ${e.code}');
      debugPrint('🔴 Error message: ${e.message}');

      String errorMessage;
      bool stillShowSuccess = false;

      switch (e.code) {
        case 'user-not-found':
          // ✅ Security best practice: Don't reveal if user exists
          // Still show success to prevent email enumeration attacks
          errorMessage =
              'If an account exists with this email, a reset link has been sent.';
          stillShowSuccess = true;
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again in a few minutes';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = 'Failed to send reset email. Please try again';
          debugPrint('🔴 Unhandled error code: ${e.code}');
      }

      if (mounted) {
        if (stillShowSuccess) {
          // Show as success to prevent enumeration
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
    } catch (e) {
      debugPrint('🔴 Unexpected error sending reset email: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');

      if (mounted) {
        setState(() {
          _emailError = 'An unexpected error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: BackgroundLineArtPainter()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C8AE5).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 50,
                        color: Color(0xFF1C8AE5),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title and description
                    if (!_emailSent) ...[
                      const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Enter your email address and we\'ll send you instructions to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email field
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _emailCtrl,
                        hintText: 'Enter your email',
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                        validator: (value) {},
                      ),
                      const SizedBox(height: 24),

                      // Send button
                      CustomButton(
                        text: 'Send Reset Link',
                        onPressed: _sendPasswordResetEmail,
                        isLoading: _isLoading,
                        backgroundColor: const Color(0xFF1C8AE5),
                        width: UIConstants.buttonWidth,
                        height: UIConstants.buttonHeight,
                        borderRadius: UIConstants.buttonRadius,
                      ),
                      const SizedBox(height: 16),

                      // Back to login
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: Color(0xFF1C8AE5),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ] else ...[
                      // Success state
                      const Icon(
                        Icons.mark_email_read,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Check Your Email',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'We’ve sent password reset instructions to:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _emailCtrl.text.trim(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C8AE5),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // User-friendly tips
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF1C8AE5),
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Next Steps:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Check your spam/junk folder if you don’t see the email\n'
                              '• After resetting your password, open the AmerckCare app and sign in with your new password',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Resend email button
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _emailSent = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          side: const BorderSide(
                            color: Color(0xFF1C8AE5),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Resend Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C8AE5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Back to login
                      CustomButton(
                        text: 'Back to Login',
                        onPressed: () => Navigator.pop(context),
                        backgroundColor: const Color(0xFF1C8AE5),
                        width: UIConstants.buttonWidth,
                        height: UIConstants.buttonHeight,
                        borderRadius: UIConstants.buttonRadius,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
