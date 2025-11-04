import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_provider_interface.dart';
import 'package:amerckcarelogin/features/auth/domain/providers/email_auth_provider.dart';
import 'package:amerckcarelogin/features/auth/domain/providers/google_auth_provider.dart'
    as google;

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  /// Generic authentication method (can be used for any provider in future)
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

  /// Email/Password login with proper error handling
  Future<void> login(String email, String password) async {
    final provider = EmailPasswordAuthProvider(
      email: email,
      password: password,
    );
    await _authenticate(provider);
  }

  /// Email/Password signup
  Future<void> signup(String emailAddress, String password) async {
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
    } else {
      debugPrint('🔴 Email Sign-Up Error: ${result.error}');
    }
  }

  /// Google Sign-In - Force account picker every time
  Future<void> signInWithGoogle() async {
    final provider = google.GoogleAuthProvider();
    await _authenticate(provider);
  }

  /// Sign out from Google only (used before signing in again)
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ Signed out from Google');
    } catch (e) {
      debugPrint('🔴 Google Sign-Out Error: $e');
    }
  }

  /// Full logout - Sign out from both Firebase and Google
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
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
