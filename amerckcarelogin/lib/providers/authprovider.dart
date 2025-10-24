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

  /// Email/Password login with improved error handling
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First check if email exists
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email.trim());
      
      if (signInMethods.isEmpty) {
        // Email doesn't exist
        _errorMessage = 'user-not-found';
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Email exists, now try to sign in
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isAuthenticated = credential.user != null;
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _isAuthenticated = false;
      // Map Firebase error codes to custom messages
      if (e.code == 'user-not-found') {
        _errorMessage = 'user-not-found';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _errorMessage = 'wrong-password';
      } else if (e.code == 'user-disabled') {
        _errorMessage = 'user-disabled';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'invalid-email';
      } else if (e.code == 'too-many-requests') {
        _errorMessage = 'too-many-requests';
      } else {
        _errorMessage = e.code;
      }
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'An error occurred';
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
    } on FirebaseAuthException catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.message ?? 'Sign up failed';
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Sign up failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Google Sign-In - Updated to force account picker every time
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
    } on FirebaseAuthException catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.message ?? 'Google sign-in failed';
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Google sign-in failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Logout - Updated to sign out from both Firebase and Google
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout failed';
    }
    notifyListeners();
  }

  signOutGoogle() {}
}