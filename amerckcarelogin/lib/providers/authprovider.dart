import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Simulated email/password login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // simulate delay

    if (email.trim() == 'user@amerck.com' && password == 'password123') {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
      _errorMessage = 'Invalid username or password';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Dummy local Google-style login (no Firebase)
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // simulate delay

    // Fake success response
    _isAuthenticated = true;

    _isLoading = false;
    notifyListeners();
  }

  /// Logout (local)
  Future<void> logout() async {
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  localLogin(String trim, String text) {}
}
