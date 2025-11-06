import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/ui_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/background_line_art.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

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

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signupEmail() async {
    // Validate and set errors
    final emailErr = Validators.validateEmail(_emailCtrl.text);
    final passErr = Validators.validatePassword(_passwordCtrl.text);
    final confErr = Validators.validateConfirmPassword(
      _passwordCtrl.text,
      _confirmCtrl.text,
    );

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmError = confErr;
    });

    if (_emailError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.signup(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Handle signup errors
      if (auth.errorMessage != null) {
        if (auth.errorMessage!.toLowerCase().contains('email')) {
          setState(() => _emailError = auth.errorMessage);
        } else {
          setState(() => _passwordError = auth.errorMessage);
        }
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _signupWithGoogle(AuthProvider authProvider) async {
    await authProvider.signInWithGoogle();

    if (authProvider.isAuthenticated) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google sign-up failed'),
        ),
      );
    }
  }

  Future<void> _signupWithFacebook(AuthProvider authProvider) async {
    await authProvider.signInWithFacebook();

    if (authProvider.isAuthenticated) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Facebook sign-up failed'),
        ),
      );
    }
  }

  Future<void> _signupWithApple(AuthProvider authProvider) async {
    // TODO: Implement Apple sign-up
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Apple sign-up coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                  const SizedBox(height: 8),
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
                    isLoading: _isLoading,
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
                        authProvider.isLoading
                            ? null
                            : () => _signupWithGoogle(authProvider),
                    isLoading: authProvider.isLoading,
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

                  // "Or login with" text
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
                            authProvider.isLoading
                                ? null
                                : () => _signupWithFacebook(authProvider),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1877F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.facebook,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Apple button
                      GestureDetector(
                        onTap:
                            authProvider.isLoading
                                ? null
                                : () => _signupWithApple(authProvider),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.apple,
                            color: Colors.white,
                            size: 32,
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
