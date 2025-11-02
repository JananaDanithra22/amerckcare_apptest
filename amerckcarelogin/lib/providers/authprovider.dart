import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  /// Email/Password login with proper error handling
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isAuthenticated = credential.user != null;
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _isAuthenticated = false;

      // Map Firebase error codes to user-friendly messages
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'user-not-found';
          break;
        case 'wrong-password':
          _errorMessage = 'wrong-password';
          break;
        case 'invalid-credential':
          _errorMessage = 'invalid-credential';
          break;
        case 'user-disabled':
          _errorMessage = 'user-disabled';
          break;
        case 'invalid-email':
          _errorMessage = 'invalid-email';
          break;
        case 'too-many-requests':
          _errorMessage = 'too-many-requests';
          break;
        case 'network-request-failed':
          _errorMessage = 'network error';
          break;
        default:
          _errorMessage = e.code;
      }

      // Debug: Print the actual error
      debugPrint('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'An unexpected error occurred';
      debugPrint('🔴 Login Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Email/Password signup
  Future<void> signup(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isAuthenticated = credential.user != null;
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _isAuthenticated = false;

      // Map signup errors
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'This email is already registered';
          break;
        case 'weak-password':
          _errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          _errorMessage = 'Invalid email format';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          _errorMessage = e.message ?? 'Sign up failed';
      }

      debugPrint('🔴 Signup Error: ${e.code} - ${e.message}');
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Sign up failed';
      debugPrint('🔴 Signup Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Google Sign-In - Force account picker every time
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign out first to force account picker
      await _googleSignIn.signOut();

      // Now sign in - this will show the account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        _errorMessage = 'Google sign-in cancelled';
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _isAuthenticated = userCredential.user != null;
      _errorMessage = null;

      debugPrint('✅ Google Sign-In Successful: ${userCredential.user?.email}');
    } on FirebaseAuthException catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.message ?? 'Google sign-in failed';
      debugPrint('🔴 Google Sign-In Error: ${e.code} - ${e.message}');
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Google sign-in failed';
      debugPrint('🔴 Google Sign-In Error: $e');
    }

    _isLoading = false;
    notifyListeners();
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
