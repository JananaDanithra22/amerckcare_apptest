// lib/features/auth/providers/auth_provider.dart - COMPLETELY FIXED VERSION

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

  // ✅ REMOVED _isAuthenticated - we'll use user != null instead
  // The stream handles authentication state automatically

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get user => _auth.currentUser;

  // ✅ isAuthenticated now directly checks the current user
  bool get isAuthenticated => _auth.currentUser != null;

  LoginType? _loginType;
  LoginType? get loginType => _loginType;

  bool _biometricTriggered = false;
  bool get biometricTriggered => _biometricTriggered;

  void setLoginType(LoginType type) {
    _loginType = type;
    // Persist login type to secure storage for retrieval after app restart
    _persistLoginType(type);
    notifyListeners();
  }

  Future<void> _persistLoginType(LoginType type) async {
    try {
      await _biometricService.persistLoginType(type.toString().split('.').last);
    } catch (e) {
      debugPrint('🔴 Error persisting login type: $e');
    }
  }

  Future<void> _loadPersistedLoginType() async {
    try {
      final typeStr = await _biometricService.getPersistedLoginType();
      if (typeStr != null) {
        switch (typeStr) {
          case 'emailPassword':
            _loginType = LoginType.emailPassword;
            break;
          case 'google':
            _loginType = LoginType.google;
            break;
          case 'facebook':
            _loginType = LoginType.facebook;
            break;
        }
        debugPrint('🔐 Loaded persisted login type: $_loginType');
      }
    } catch (e) {
      debugPrint('🔴 Error loading login type: $e');
    }
  }

  /// Constructor - Listen to auth state changes
  AuthProvider() {
    // Load persisted login type first
    _loadPersistedLoginType();

    // ✅ Listen to auth state changes and notify listeners
    _auth.authStateChanges().listen((User? user) {
      // Add a small delay to ensure Firebase internal state is fully synced
      Future.delayed(const Duration(milliseconds: 50), () {
        debugPrint(
          '🔐 Auth state changed: ${_auth.currentUser?.email ?? "signed out"}',
        );
        debugPrint('   Current user: ${_auth.currentUser?.uid}');
        notifyListeners();
      });
    });

    // Also check initial auth state
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_auth.currentUser != null) {
        debugPrint('🔐 Initial auth state: ${_auth.currentUser!.email}');
        notifyListeners();
      }
    });
  }

  /// Generic authentication method
  Future<bool> _authenticate(IAuthProvider provider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await provider.signIn();

    // ✅ Don't manually set _isAuthenticated - trust the stream
    _errorMessage = result.error;
    _isLoading = false;

    if (result.success) {
      debugPrint('✅ ${provider.providerName} Sign-In Successful');
      // Wait a bit for auth state to propagate
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      debugPrint('🔴 ${provider.providerName} Sign-In Error: ${result.error}');
    }

    notifyListeners();
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

    // ✅ Don't manually set _isAuthenticated
    _errorMessage = result.error;
    _isLoading = false;

    if (result.success) {
      debugPrint('✅ Email Sign-Up Successful');
      setLoginType(LoginType.emailPassword);
      await Future.delayed(const Duration(milliseconds: 100));

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

    notifyListeners();
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

          // Verify email matches
          if (!isAuthenticated || getCurrentUserEmail() != email) {
            _errorMessage = 'Google sign-in failed or account mismatch';
            await _biometricService.disableBiometric();
            _isLoading = false;
            notifyListeners();
            return false;
          }
          break;

        case 'facebook':
          debugPrint('🔐 Attempting Facebook sign-in for biometric login...');
          await signInWithFacebook();

          // Verify email matches
          if (!isAuthenticated || getCurrentUserEmail() != email) {
            _errorMessage = 'Facebook sign-in failed or account mismatch';
            await _biometricService.disableBiometric();
            _isLoading = false;
            notifyListeners();
            return false;
          }
          break;

        default:
          _errorMessage = 'Unknown login type: $loginTypeStr';
          _isLoading = false;
          notifyListeners();
          return false;
      }

      _isLoading = false;
      notifyListeners();
      return isAuthenticated;
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
    if (success) {
      setLoginType(LoginType.google);
      // Extra wait to ensure auth state is fully propagated
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('✅ Google auth complete. User: ${_auth.currentUser?.email}');
    }
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
    if (success) {
      setLoginType(LoginType.facebook);
      // Extra wait to ensure auth state is fully propagated
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('✅ Facebook auth complete. User: ${_auth.currentUser?.email}');
    }
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

      // Clear login type
      _loginType = null;
      await _biometricService.clearPersistedLoginType();

      // ✅ Don't manually set _isAuthenticated - stream will handle it
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
