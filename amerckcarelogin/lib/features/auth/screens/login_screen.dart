import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/ui_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/background_line_art.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _loginEmail() async {
    // Clear previous errors immediately
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate fields locally first
    final emailValidation = Validators.validateEmail(_emailCtrl.text.trim());
    final passwordValidation = Validators.validatePassword(_passwordCtrl.text);

    if (emailValidation != null || passwordValidation != null) {
      setState(() {
        _emailError = emailValidation;
        _passwordError = passwordValidation;
      });
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Attempt login
    await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Handle Firebase authentication errors
      _handleLoginError(auth.errorMessage);
    }
  }

  void _handleLoginError(String? errorMsg) {
    if (errorMsg == null) {
      setState(() {
        _passwordError = 'Login failed. Please try again.';
      });
      return;
    }

    String? emailErr;
    String? passwordErr;

    final error = errorMsg.toLowerCase();

    // Parse Firebase error codes and messages
    if (error.contains('user-not-found') ||
        error.contains('no user record') ||
        error.contains('no account')) {
      emailErr = 'No account found with this email';
    } else if (error.contains('user-disabled') ||
        error.contains('account disabled')) {
      emailErr = 'This account has been disabled';
    } else if (error.contains('wrong-password') ||
        error.contains('password is invalid')) {
      passwordErr = 'Incorrect password';
    } else if (error.contains('invalid-credential') ||
        error.contains('invalid credential')) {
      passwordErr = 'Invalid email or password';
    } else if (error.contains('invalid-email') ||
        error.contains('badly formatted')) {
      emailErr = 'Invalid email format';
    } else if (error.contains('too-many-requests')) {
      passwordErr = 'Too many failed attempts. Try again later';
    } else if (error.contains('network') || error.contains('connection')) {
      passwordErr = 'Network error. Check your connection';
    } else {
      passwordErr = 'Invalid email or password';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
    });
  }

  Future<void> _loginWithFacebook(AuthProvider auth) async {
    await auth.signInWithFacebook();

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Facebook login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginWithMicrosoft(AuthProvider auth) async {
    debugPrint('🔵 LoginScreen: Microsoft button pressed');

    await auth.signInWithMicrosoft();

    if (!mounted) return;

    if (auth.isAuthenticated) {
      debugPrint('✅ LoginScreen: Navigation to home');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      debugPrint('🔴 LoginScreen: Microsoft login failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Microsoft login failed'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

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
                      onChanged: (value) {
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
                      onToggleVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      onChanged: (value) {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Sign In button
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _loginEmail,
                      isLoading: auth.isLoading,
                      backgroundColor: UIConstants.primaryBlue,
                      width: UIConstants.buttonWidth,
                      height: UIConstants.buttonHeight,
                      borderRadius: UIConstants.buttonRadius,
                    ),

                    const SizedBox(height: 16),

                    // Google Sign In button
                    CustomButton(
                      text: 'Sign in with Google',
                      onPressed: () async {
                        await auth.signOutGoogle();
                        await auth.signInWithGoogle();
                        if (auth.isAuthenticated) {
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                auth.errorMessage ?? 'Login failed',
                              ),
                            ),
                          );
                        }
                      },
                      isLoading: auth.isLoading,
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
                      'or login with',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),

                    const SizedBox(height: 16),

                    // Facebook and Microsoft login buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Facebook button
                        GestureDetector(
                          onTap:
                              auth.isLoading
                                  ? null
                                  : () => _loginWithFacebook(auth),
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

                        // Microsoft button (FREE alternative to Apple!)
                        GestureDetector(
                          onTap:
                              auth.isLoading
                                  ? null
                                  : () => _loginWithMicrosoft(auth),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A4EF), // Microsoft blue
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.window, // Microsoft Windows icon
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password screen
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    // Sign up
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New here? ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(133, 0, 0, 0),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
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
