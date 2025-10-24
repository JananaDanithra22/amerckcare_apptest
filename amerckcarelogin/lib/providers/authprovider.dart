import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:amerckcarelogin/screens/signupscreen.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get user => _auth.currentUser;

  /// Email/Password login
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
    } on FirebaseAuthException catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return; // user canceled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      _isAuthenticated = userCredential.user != null;
    } on FirebaseAuthException catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  localLogin(String trim, String text) {}
}
