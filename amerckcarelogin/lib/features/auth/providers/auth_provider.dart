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
import '../services/biometric_service.dart'; // <-- Import

/// AuthProvider - Only handles state management
/// Business logic moved to AuthService
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BiometricService _biometricService =
      BiometricService(); // <-- Biometric

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get user => _auth.currentUser;

  /// Constructor - Check if user is already logged in
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _isAuthenticated = user != null;
      notifyListeners();
    });
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

    // Enable biometric login if user opts in
    if (success && enableBiometric) {
      try {
        await _biometricService.enableBiometric(email, password);
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
      // Enable biometric login after signup if user opts in
      if (enableBiometric) {
        try {
          await _biometricService.enableBiometric(emailAddress, password);
        } catch (e) {
          debugPrint('🔴 Error enabling biometric: $e');
        }
      }
    } else {
      debugPrint('🔴 Email Sign-Up Error: ${result.error}');
    }
  }

  /// Biometric login (email/password stored securely)
  Future<bool> loginWithBiometrics() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (!isEnabled) return false;

    final credentials = await _biometricService.getStoredCredentials();
    if (credentials == null) return false;

    // Authenticate via biometrics
    final authenticated = await _biometricService.authenticate();
    if (!authenticated) return false;

    final email = credentials['email']!;
    final password = credentials['password']!;

    await login(
      email,
      password,
    ); // Reuse login method (without re-enabling biometric)
    return _isAuthenticated;
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    final provider = google.GoogleAuthProvider();
    await _authenticate(provider);
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
    await _authenticate(provider);
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
        _biometricService.clearAll(), // <-- Clear biometric on logout
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

  /// Check if user is currently signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  /// Get current user's email
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }
}
