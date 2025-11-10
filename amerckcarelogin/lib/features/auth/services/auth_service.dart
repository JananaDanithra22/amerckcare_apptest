// lib/features/auth/services/auth_service.dart

import '../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

/// Simple result class for auth operations
class AuthResult {
  final bool success;
  final String? error;

  AuthResult({required this.success, this.error});
}

/// Auth Service - Handles all authentication operations with overlay
/// This separates business logic from state management
class AuthService {
  final AuthProvider _authProvider;

  AuthService(this._authProvider);

  /// Login with email/password WITH automatic overlay
  Future<AuthResult> loginWithOverlay(String email, String password) async {
    try {
      await GlobalOverlayController().withOverlay(
        () async {
          await _authProvider.login(email.trim(), password);
        },
        message: 'Signing in...',
      );

      return AuthResult(
        success: _authProvider.isAuthenticated,
        error: _authProvider.errorMessage,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Signup with email/password WITH automatic overlay
  Future<AuthResult> signupWithOverlay(String email, String password) async {
    try {
      await GlobalOverlayController().withOverlay(
        () async {
          await _authProvider.signup(email.trim(), password);
        },
        message: 'Creating your account...',
      );

      return AuthResult(
        success: _authProvider.isAuthenticated,
        error: _authProvider.errorMessage,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Google sign-in WITH automatic overlay
  Future<AuthResult> googleSignInWithOverlay() async {
    try {
      await GlobalOverlayController().withOverlay(
        () async {
          await _authProvider.signOutGoogle();
          await _authProvider.signInWithGoogle();
        },
        message: 'Signing in with Google...',
      );

      return AuthResult(
        success: _authProvider.isAuthenticated,
        error: _authProvider.errorMessage,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Facebook sign-in WITH automatic overlay
  Future<AuthResult> facebookSignInWithOverlay() async {
    try {
      await GlobalOverlayController().withOverlay(
        () async {
          await _authProvider.signInWithFacebook();
        },
        message: 'Signing in with Facebook...',
      );

      return AuthResult(
        success: _authProvider.isAuthenticated,
        error: _authProvider.errorMessage,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}