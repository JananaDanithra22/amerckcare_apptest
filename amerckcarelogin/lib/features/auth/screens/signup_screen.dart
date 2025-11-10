import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/ui_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/background_line_art.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../../shared/widgets/loading_overlay.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signupEmail() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });

    // Validate and set errors
    final emailErr = Validators.validateEmail(_emailCtrl.text.trim());
    final passErr = Validators.validatePassword(_passwordCtrl.text);
    final confErr = Validators.validateConfirmPassword(
      _passwordCtrl.text,
      _confirmCtrl.text,
    );

    if (emailErr != null || passErr != null || confErr != null) {
      setState(() {
        _emailError = emailErr;
        _passwordError = passErr;
        _confirmError = confErr;
      });
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      await GlobalOverlayController().withOverlay(() async {
        await auth.signup(_emailCtrl.text.trim(), _passwordCtrl.text);
      }, message: 'Creating your account...');

      if (!mounted) return;

      if (auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle signup errors
        _handleSignupError(auth.errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    }
  }

  void _handleSignupError(String? errorMsg) {
    if (errorMsg == null) {
      setState(() {
        _passwordError = 'Sign up failed. Please try again.';
      });
      return;
    }

    String? emailErr;
    String? passwordErr;

    final error = errorMsg.toLowerCase();

    if (error.contains('email-already-in-use') ||
        error.contains('already in use')) {
      emailErr = 'This email is already registered';
    } else if (error.contains('invalid-email') ||
        error.contains('badly formatted')) {
      emailErr = 'Invalid email format';
    } else if (error.contains('weak-password')) {
      passwordErr = 'Password is too weak';
    } else if (error.contains('network') || error.contains('connection')) {
      passwordErr = 'Network error. Check your connection';
    } else if (error.contains('email')) {
      emailErr = errorMsg;
    } else {
      passwordErr = errorMsg;
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
    });
  }

  Future<void> _signupWithGoogle(AuthProvider auth) async {
    try {
      await GlobalOverlayController().withOverlay(() async {
        await auth.signOutGoogle();
        await auth.signInWithGoogle();
      }, message: 'Signing up with Google...');

      if (!mounted) return;

      if (auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Google sign-up failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-up error: ${e.toString()}')),
      );
    }
  }

  Future<void> _signupWithFacebook(AuthProvider auth) async {
    try {
      await GlobalOverlayController().withOverlay(() async {
        await auth.signInWithFacebook();
      }, message: 'Signing up with Facebook...');

      if (!mounted) return;

      if (auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Facebook sign-up failed'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook sign-up error: ${e.toString()}')),
      );
    }
  }

  Future<void> _signupWithApple(AuthProvider auth) async {
    // TODO: Implement Apple sign-up
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Apple sign-up coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background with decorative line art
          CustomPaint(size: Size.infinite, painter: BackgroundLineArtPainter()),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Logo on top center
                  Image.asset(
                    'assets/images/signlogo.png',
                    height: 70,
                    width: 70,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Create account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 24),

                  // Email label
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

                  // Email input
                  CustomTextField(
                    controller: _emailCtrl,
                    hintText: 'Enter your email',
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    borderRadius: UIConstants.fieldRadius,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password label
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Password input
                  CustomTextField(
                    controller: _passwordCtrl,
                    hintText: 'Enter your password',
                    errorText: _passwordError,
                    obscureText: _obscurePassword,
                    borderRadius: UIConstants.fieldRadius,
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm label
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Confirm Password',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Confirm input
                  CustomTextField(
                    controller: _confirmCtrl,
                    hintText: 'Re-enter your password',
                    errorText: _confirmError,
                    obscureText: _obscureConfirm,
                    borderRadius: UIConstants.fieldRadius,
                    onToggleVisibility: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                    onChanged: (_) {
                      if (_confirmError != null) {
                        setState(() => _confirmError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Sign Up button
                  CustomButton(
                    text: 'Sign Up',
                    onPressed: _signupEmail,
                    backgroundColor: UIConstants.primaryBlue,
                    width: UIConstants.buttonWidth,
                    height: UIConstants.buttonHeight,
                    borderRadius: UIConstants.buttonRadius,
                  ),

                  const SizedBox(height: 16),

                  // Sign Up with Google button
                  CustomButton(
                    text: 'Sign up with Google',
                    onPressed:
                        auth.isLoading ? null : () => _signupWithGoogle(auth),
                    backgroundColor: UIConstants.darkBlue,
                    width: UIConstants.buttonWidth,
                    height: UIConstants.buttonHeight,
                    borderRadius: UIConstants.buttonRadius,
                    icon: Image.asset(
                      'assets/images/Glogo.png',
                      height: 24,
                      width: 24,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // "Or sign up with" text
                  const Text(
                    'or sign up with',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),

                  const SizedBox(height: 16),

                  // Facebook and Apple login buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Facebook button
                      GestureDetector(
                        onTap:
                            auth.isLoading
                                ? null
                                : () => _signupWithFacebook(auth),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1877F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.facebook,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Apple button
                      GestureDetector(
                        onTap:
                            auth.isLoading
                                ? null
                                : () => _signupWithApple(auth),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.apple,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Small link back to login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
