// lib/features/auth/providers/auth_provider.dart - FIXED WITH clearError()

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../domain/auth_provider_interface.dart';
import 'package:AmerckCare/features/auth/domain/providers/email_auth_provider.dart';
import 'package:AmerckCare/features/auth/domain/providers/google_auth_provider.dart'
    as google;
import 'package:AmerckCare/features/auth/domain/providers/facebook_auth_provider.dart'
    as facebook;
import '../services/biometric_service.dart';

enum LoginType { emailPassword, google, facebook }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final BiometricService _biometricService = BiometricService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get user => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  LoginType? _loginType;
  LoginType? get loginType => _loginType;

  bool _biometricTriggered = false;
  bool get biometricTriggered => _biometricTriggered;

  /// ✅ Clear error message (for password re-verification)
  void clearError() {
    _errorMessage = null;
  }

  void setLoginType(LoginType type) {
    _loginType = type;
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

  AuthProvider() {
    _loadPersistedLoginType();

    _auth.authStateChanges().listen((User? user) {
      Future.delayed(const Duration(milliseconds: 50), () {
        debugPrint(
          '🔐 Auth state changed: ${_auth.currentUser?.email ?? "signed out"}',
        );
        debugPrint('   Current user: ${_auth.currentUser?.uid}');
        notifyListeners();
      });
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_auth.currentUser != null) {
        debugPrint('🔐 Initial auth state: ${_auth.currentUser!.email}');
        notifyListeners();
      }
    });
  }

  Future<bool> _authenticate(IAuthProvider provider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await provider.signIn();

    _errorMessage = result.error;
    _isLoading = false;

    if (result.success) {
      debugPrint('✅ ${provider.providerName} Sign-In Successful');
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      debugPrint('🔴 ${provider.providerName} Sign-In Error: ${result.error}');
    }

    notifyListeners();
    return result.success;
  }

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
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          await _biometricService.enableBiometric(
            email,
            password,
            uid,
            loginType: LoginType.emailPassword,
          );
        }
      } catch (e) {
        debugPrint('🔴 Error enabling biometric: $e');
      }
    }
  }

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

    _errorMessage = result.error;
    _isLoading = false;

    if (result.success) {
      debugPrint('✅ Email Sign-Up Successful');
      setLoginType(LoginType.emailPassword);
      await Future.delayed(const Duration(milliseconds: 100));

      if (enableBiometric) {
        try {
          final uid = _auth.currentUser?.uid;
          if (uid != null) {
            await _biometricService.enableBiometric(
              emailAddress,
              password,
              uid,
              loginType: LoginType.emailPassword,
            );
          }
        } catch (e) {
          debugPrint('🔴 Error enabling biometric: $e');
        }
      }
    } else {
      debugPrint('🔴 Email Sign-Up Error: ${result.error}');
    }

    notifyListeners();
  }

  Future<bool> triggerBiometricLogin() async {
    if (_biometricTriggered) return false;
    _biometricTriggered = true;
    return await loginWithBiometrics();
  }

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
      if (credentials == null) {
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
      final storedUid = credentials['uid'];
      final email = credentials['email'];
      final password = credentials['password'];

      debugPrint('🔐 Biometric auth successful. Login type: $loginTypeStr');

      switch (loginTypeStr) {
        case 'emailPassword':
          if (email == null || password == null) {
            _errorMessage = 'Stored credentials incomplete';
            _isLoading = false;
            notifyListeners();
            return false;
          }
          await login(email, password, enableBiometric: false);
          break;

        case 'google':
        case 'facebook':
          if (isAuthenticated && _auth.currentUser?.uid == storedUid) {
            debugPrint('✅ Valid session found. UID matches: $storedUid');
            _isLoading = false;
            notifyListeners();
            return true;
          }

          debugPrint('⚠️ Session expired for $loginTypeStr user');
          _errorMessage = 'Your session expired. Please login manually.';
          await _biometricService.disableBiometric();
          _isLoading = false;
          notifyListeners();
          return false;

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

  Future<void> signInWithGoogle() async {
    final provider = google.GoogleAuthProvider();
    final success = await _authenticate(provider);
    if (success) {
      setLoginType(LoginType.google);
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('✅ Google auth complete. User: ${_auth.currentUser?.email}');
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ Signed out from Google');
    } catch (e) {
      debugPrint('🔴 Google Sign-Out Error: $e');
    }
  }

  Future<void> signInWithFacebook() async {
    final provider = facebook.FacebookAuthProvider();
    final success = await _authenticate(provider);
    if (success) {
      setLoginType(LoginType.facebook);
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('✅ Facebook auth complete. User: ${_auth.currentUser?.email}');
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);

      _loginType = null;
      await _biometricService.clearPersistedLoginType();

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

  // FIXED - returns the user's UID string
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
