import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/auth_error_parser.dart';
import '../../../core/constants/ui_constants.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart'; // <-- Added
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

  final BiometricService _biometricService =
      BiometricService(); // <-- Biometric

  @override
  void initState() {
    super.initState();
    // Try biometric login on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricLogin();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final canUseBiometrics = await _biometricService.isBiometricEnabled();

    if (canUseBiometrics) {
      final credentials = await _biometricService.getStoredCredentials();
      if (credentials != null) {
        final authenticated = await _biometricService.authenticate(
          reason: 'Authenticate to login',
        );
        if (authenticated) {
          await auth.login(credentials['email']!, credentials['password']!);
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    }
  }

  Future<void> _loginEmail() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate fields
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
    final authService = AuthService(auth);

    // Use service for login
    final result = await authService.loginWithOverlay(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (result.success) {
      // Prompt user to enable biometrics if supported
      final isBiometricAvailable =
          await _biometricService.isBiometricAvailable();
      if (isBiometricAvailable) {
        final enable = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Enable Biometric Login?'),
                content: const Text(
                  'You can use fingerprint/Face ID for faster login next time.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
        );

        if (enable == true) {
          try {
            await _biometricService.enableBiometric(
              _emailCtrl.text.trim(),
              _passwordCtrl.text,
            );
          } catch (e) {
            debugPrint('🔴 Error enabling biometric: $e');
          }
        }
      }

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Parse errors using utility
      final errors = AuthErrorParser.parse(result.error);
      setState(() {
        _emailError = errors['email'];
        _passwordError = errors['password'];
      });
    }
  }

  Future<void> _loginWithGoogle(AuthProvider auth) async {
    final authService = AuthService(auth);
    final result = await authService.googleSignInWithOverlay();

    if (!mounted) return;

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthErrorParser.getGenericMessage(result.error)),
        ),
      );
    }
  }

  Future<void> _loginWithFacebook(AuthProvider auth) async {
    final authService = AuthService(auth);
    final result = await authService.facebookSignInWithOverlay();

    if (!mounted) return;

    if (result.success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthErrorParser.getGenericMessage(result.error)),
        ),
      );
    }
  }

  Future<void> _loginWithApple(AuthProvider auth) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('heh heh,to be implemented ')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: BackgroundLineArtPainter()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/signlogo.png',
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                    ),
                    const SizedBox(height: 16),
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
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _loginEmail,
                      backgroundColor: UIConstants.primaryBlue,
                      width: UIConstants.buttonWidth,
                      height: UIConstants.buttonHeight,
                      borderRadius: UIConstants.buttonRadius,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Sign in with Google',
                      onPressed:
                          auth.isLoading ? null : () => _loginWithGoogle(auth),
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
                    const Text(
                      'or login with',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap:
                              auth.isLoading
                                  ? null
                                  : () => _loginWithFacebook(auth),
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
                        GestureDetector(
                          onTap:
                              auth.isLoading
                                  ? null
                                  : () => _loginWithApple(auth),
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
                    const SizedBox(height: 16),
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
