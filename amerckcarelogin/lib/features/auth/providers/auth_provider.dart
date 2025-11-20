// lib/features/auth/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../domain/auth_provider_interface.dart';
import 'package:amerckcarelogin/features/auth/domain/providers/email_auth_provider.dart';
import 'package:amerckcarelogin/features/auth/domain/providers/google_auth_provider.dart'
    as google;
import 'package:amerckcarelogin/features/auth/domain/providers/facebook_auth_provider.dart'
    as facebook;
import '../services/biometric_service.dart';

enum LoginType { emailPassword, google, facebook }

/// AuthProvider - Only handles state management
/// Business logic moved to AuthService
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BiometricService _biometricService = BiometricService();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get user => _auth.currentUser;

  LoginType? _loginType;
  LoginType? get loginType => _loginType;

  bool _biometricTriggered = false; // Prevent multiple popups
  bool get biometricTriggered => _biometricTriggered;

  void setLoginType(LoginType type) {
    _loginType = type;
    notifyListeners();
  }

  /// Constructor - Check if user is already logged in
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _isAuthenticated = user != null;
      notifyListeners();
    });
    // ⚠️ Do NOT call biometric login here
  }

  /// Generic authentication method
  Future<bool> _authenticate(IAuthProvider provider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await provider.signIn();

    _isAuthenticated = result.success;
    _errorMessage = result.error;
    _isLoading = false;
    notifyListeners();

    if (result.success) {
      debugPrint('✅ ${provider.providerName} Sign-In Successful');
    } else {
      debugPrint('🔴 ${provider.providerName} Sign-In Error: ${result.error}');
    }

    return result.success;
  }

  /// Email/Password login
  Future<void> login(
    String email,
    String password, {
    bool enableBiometric = false,
  }) async {
    final provider = EmailPasswordAuthProvider(
      email: email,
      password: password,
    );
    final success = await _authenticate(provider);

    if (success) setLoginType(LoginType.emailPassword);

    if (success && enableBiometric) {
      try {
        await _biometricService.enableBiometric(
          email,
          password,
          loginType: LoginType.emailPassword,
        );
      } catch (e) {
        debugPrint('🔴 Error enabling biometric: $e');
      }
    }
  }

  /// Email/Password signup
  Future<void> signup(
    String emailAddress,
    String password, {
    bool enableBiometric = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final provider = EmailPasswordAuthProvider(
      email: emailAddress,
      password: password,
    );

    final result = await provider.signUp();

    _isAuthenticated = result.success;
    _errorMessage = result.error;
    _isLoading = false;
    notifyListeners();

    if (result.success) {
      debugPrint('✅ Email Sign-Up Successful');
      setLoginType(LoginType.emailPassword);

      if (enableBiometric) {
        try {
          await _biometricService.enableBiometric(
            emailAddress,
            password,
            loginType: LoginType.emailPassword,
          );
        } catch (e) {
          debugPrint('🔴 Error enabling biometric: $e');
        }
      }
    } else {
      debugPrint('🔴 Email Sign-Up Error: ${result.error}');
    }
  }

  /// Explicit biometric login trigger
  Future<bool> triggerBiometricLogin() async {
    if (_biometricTriggered) return false;
    _biometricTriggered = true;
    return await loginWithBiometrics();
  }

  /// Login with biometrics
  Future<bool> loginWithBiometrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isEnabled = await _biometricService.isBiometricEnabled();
      if (!isEnabled) {
        _errorMessage = 'Biometric login not enabled';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final credentials = await _biometricService.getStoredCredentials();
      if (credentials == null || credentials['email'] == null) {
        _errorMessage = 'No stored credentials found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to login to AmerckCare',
      );

      if (!authenticated) {
        _errorMessage = 'Biometric authentication failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final loginTypeStr = credentials['loginType'] ?? 'emailPassword';
      final email = credentials['email']!;
      final password = credentials['password'];

      debugPrint('🔐 Biometric auth successful. Login type: $loginTypeStr');

      switch (loginTypeStr) {
        case 'emailPassword':
          if (password == null) {
            _errorMessage = 'Stored credentials incomplete';
            _isLoading = false;
            notifyListeners();
            return false;
          }
          await login(email, password, enableBiometric: false);
          break;

        case 'google':
          debugPrint('🔐 Attempting Google sign-in for biometric login...');
          await signInWithGoogle();
          break;

        case 'facebook':
          debugPrint('🔐 Attempting Facebook sign-in for biometric login...');
          await signInWithFacebook();
          break;

        default:
          _errorMessage = 'Unknown login type: $loginTypeStr';
          _isLoading = false;
          notifyListeners();
          return false;
      }

      _isLoading = false;
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      debugPrint('🔴 Biometric login error: $e');
      _errorMessage = 'Biometric login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    final provider = google.GoogleAuthProvider();
    final success = await _authenticate(provider);
    if (success) setLoginType(LoginType.google);
  }

  /// Sign out from Google only
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ Signed out from Google');
    } catch (e) {
      debugPrint('🔴 Google Sign-Out Error: $e');
    }
  }

  /// Facebook Sign-In
  Future<void> signInWithFacebook() async {
    final provider = facebook.FacebookAuthProvider();
    final success = await _authenticate(provider);
    if (success) setLoginType(LoginType.facebook);
  }

  /// Full logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);

      _isAuthenticated = false;
      _errorMessage = null;
      debugPrint('✅ Logout Successful');
    } catch (e) {
      _errorMessage = 'Logout failed';
      debugPrint('🔴 Logout Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  Future<Map<String, String?>?> getStoredCredentials() async {
    return await _biometricService.getStoredCredentials();
  }
}
