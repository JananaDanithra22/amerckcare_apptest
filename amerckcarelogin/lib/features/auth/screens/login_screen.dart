// lib/features/auth/screens/login_screen.dart - UID-BASED VERSION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/auth_error_parser.dart';
import '../../../core/constants/ui_constants.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
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

  final BiometricService _biometricService = BiometricService();
  bool _isBiometricLoading = false;
  bool _showBiometricButton = false;
  String _biometricButtonText = 'Login with Biometric';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricAvailability();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Check if we should show the biometric login button
  Future<void> _checkBiometricAvailability() async {
    final isBiometricEnabled = await _biometricService.isBiometricEnabled();
    if (!isBiometricEnabled) return;

    final isBiometricAvailable = await _biometricService.isBiometricAvailable();
    if (!isBiometricAvailable) return;

    final credentials = await _biometricService.getStoredCredentials();
    if (credentials == null) return;

    final biometricName = await _biometricService.getBiometricTypeName();

    if (mounted) {
      setState(() {
        _showBiometricButton = true;
        _biometricButtonText = 'Login with $biometricName';
      });
    }
  }

  /// ✅ UPDATED: Handle biometric login with UID-based verification
  Future<void> _handleBiometricLogin() async {
    setState(() => _isBiometricLoading = true);

    try {
      final credentials = await _biometricService.getStoredCredentials();
      if (credentials == null) {
        _showError('No stored credentials found');
        return;
      }

      final biometricName = await _biometricService.getBiometricTypeName();
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate with $biometricName to login',
      );

      if (!authenticated) {
        setState(() => _isBiometricLoading = false);
        return;
      }

      final loginTypeStr = credentials['loginType'] ?? 'emailPassword';
      final identifier = credentials['identifier']!; // Email or UID
      final credential = credentials['credential']; // Password or UID

      final auth = Provider.of<AuthProvider>(context, listen: false);

      debugPrint('🔐 Biometric login attempt:');
      debugPrint('   Login type: $loginTypeStr');
      debugPrint('   Identifier: $identifier');

      switch (loginTypeStr) {
        case 'emailPassword':
          // ✅ For email/password: identifier = email, credential = password
          if (credential == null) {
            _showError('Stored credentials incomplete');
            return;
          }
          await auth.login(identifier, credential);
          break;

        case 'google':
        case 'facebook':
          // ✅ For SSO: identifier = UID, credential = UID
          debugPrint(
            '🔐 Re-authenticating ${loginTypeStr.toUpperCase()} user...',
          );

          if (loginTypeStr == 'google') {
            await auth.signInWithGoogle();
          } else {
            await auth.signInWithFacebook();
          }

          // Wait for auth state to sync
          await Future.delayed(const Duration(milliseconds: 300));

          // Verify the sign-in succeeded
          if (!auth.isAuthenticated) {
            _showError('Sign-in failed. Please try again.');
            await _biometricService.disableBiometric();
            setState(() => _showBiometricButton = false);
            return;
          }

          // ✅ SIMPLIFIED: Just verify UID matches (no email comparison)
          final currentUid = auth.user?.uid;

          if (currentUid != identifier) {
            debugPrint('🔴 UID mismatch:');
            debugPrint('   Stored UID: $identifier');
            debugPrint('   Current UID: $currentUid');

            _showError('Account mismatch. Please login manually.');
            await _biometricService.disableBiometric();
            setState(() => _showBiometricButton = false);
            return;
          }

          debugPrint('✅ UID verified: $currentUid');
          break;

        default:
          _showError('Unknown login type');
          return;
      }

      if (!mounted) return;

      if (auth.isAuthenticated) {
        debugPrint('✅ Biometric login successful');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        await _biometricService.disableBiometric();
        _showError('Biometric login failed. Please login manually.');
        setState(() => _showBiometricButton = false);
      }
    } catch (e) {
      debugPrint('🔴 Error in biometric login: $e');
      _showError('Biometric authentication error. Please login manually.');
    } finally {
      if (mounted) {
        setState(() => _isBiometricLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Manual login with email and password
  Future<void> _loginEmail() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

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

    final result = await authService.loginWithOverlay(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (result.success) {
      await _promptBiometricEnrollment();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final errors = AuthErrorParser.parse(result.error);
      setState(() {
        _emailError = errors['email'];
        _passwordError = errors['password'];
      });
    }
  }

  /// Prompt user to enable biometric login after successful manual login
  Future<void> _promptBiometricEnrollment() async {
    final hasBeenShown = await _biometricService.hasBiometricPromptBeenShown();
    if (hasBeenShown) return;

    final isEnabled = await _biometricService.isBiometricEnabled();
    if (isEnabled) return;

    final isBiometricAvailable = await _biometricService.isBiometricAvailable();
    if (!isBiometricAvailable) {
      await _biometricService.markBiometricPromptShown();
      return;
    }

    if (!mounted) return;

    final biometricName = await _biometricService.getBiometricTypeName();

    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Enable $biometricName Login?'),
            content: Text(
              'Use $biometricName for faster login next time. You can change this in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enable'),
              ),
            ],
          ),
    );

    if (enable == true) {
      try {
        await _biometricService.enableBiometric(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          loginType: LoginType.emailPassword,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$biometricName login enabled successfully!'),
            ),
          );
        }
      } catch (e) {
        debugPrint('🔴 Error enabling biometric: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to enable biometric login.')),
          );
        }
      }
    } else {
      await _biometricService.markBiometricPromptShown();
    }
  }

  Future<void> _loginWithGoogle(AuthProvider auth) async {
    final authService = AuthService(auth);
    final result = await authService.googleSignInWithOverlay();

    if (!mounted) return;

    if (result.success) {
      await _promptBiometricEnrollmentForSSO(LoginType.google);
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
      await _promptBiometricEnrollmentForSSO(LoginType.facebook);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthErrorParser.getGenericMessage(result.error)),
        ),
      );
    }
  }

  /// ✅ UPDATED: Prompt biometric enrollment for SSO logins (uses UID)
  Future<void> _promptBiometricEnrollmentForSSO(LoginType loginType) async {
    final hasBeenShown = await _biometricService.hasBiometricPromptBeenShown();
    if (hasBeenShown) return;

    final isEnabled = await _biometricService.isBiometricEnabled();
    if (isEnabled) return;

    final isBiometricAvailable = await _biometricService.isBiometricAvailable();
    if (!isBiometricAvailable) {
      await _biometricService.markBiometricPromptShown();
      return;
    }

    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // ✅ Get UID (always available for SSO users)
    final user = auth.user;
    if (user == null) return;

    final uid = user.uid;

    final biometricName = await _biometricService.getBiometricTypeName();
    final providerName = loginType == LoginType.google ? 'Google' : 'Facebook';

    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Enable $biometricName Login?'),
            content: Text(
              'Use $biometricName to quickly access your $providerName account next time. Your session will be remembered securely.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enable'),
              ),
            ],
          ),
    );

    if (enable == true) {
      try {
        // ✅ For SSO: Store UID as both identifier and credential
        await _biometricService.enableBiometric(
          uid, // identifier
          uid, // credential
          loginType: loginType,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$biometricName login enabled successfully!'),
            ),
          );
        }
      } catch (e) {
        debugPrint('🔴 Error enabling biometric: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to enable biometric login.')),
          );
        }
      }
    } else {
      await _biometricService.markBiometricPromptShown();
    }
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

                    // Show loading indicator during biometric authentication
                    if (_isBiometricLoading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        'Authenticating with biometrics...',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 40),
                    ] else ...[
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
                        validator: (value) {},
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Sign In',
                        onPressed: _loginEmail,
                        isLoading: auth.isLoading,
                        backgroundColor: const Color.fromRGBO(28, 138, 229, 1),
                        width: UIConstants.buttonWidth,
                        height: UIConstants.buttonHeight,
                        borderRadius: UIConstants.buttonRadius,
                      ),
                      const SizedBox(height: 16),

                      // Biometric Login Button (only visible when enabled)
                      if (_showBiometricButton) ...[
                        CustomButton(
                          text: _biometricButtonText,
                          onPressed: _handleBiometricLogin,
                          backgroundColor: Color.fromRGBO(0, 80, 149, 1),
                          width: UIConstants.buttonWidth,
                          height: UIConstants.buttonHeight,
                          borderRadius: UIConstants.buttonRadius,
                          icon: const Icon(
                            Icons.fingerprint,
                            color: Color.fromRGBO(255, 255, 255, 1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 8),
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
                                    : () => _loginWithGoogle(auth),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/Glogo.png',
                                  height: 27,
                                  width: 27,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
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
