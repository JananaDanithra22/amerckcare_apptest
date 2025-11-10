import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import '../auth_provider_interface.dart';

class MicrosoftAuthProvider implements IAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Your actual Azure AD credentials
  static const String _clientId = 'b872fd81-82b0-440c-b020-a0e0f57f3648';
  static const String _tenantId = '9486ac65-39d3-4d25-977c-76d9c31c0046';
  static const String _redirectUri =
      'msauth://com.example.amerckcarelogin/gVkGX7iHjyibIfDd1RiHqM2tYR8%3D';

  // Create a static navigator key for OAuth navigation
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  late final AadOAuth _oauth;
  bool _isInitialized = false;

  MicrosoftAuthProvider() {
    _initializeOAuth();
  }

  void _initializeOAuth() {
    try {
      final config = Config(
        tenant: _tenantId,
        clientId: _clientId,
        scope: 'openid profile email offline_access',
        redirectUri: _redirectUri,
        navigatorKey: _navigatorKey,
      );

      _oauth = AadOAuth(config);
      _isInitialized = true;
      debugPrint('✅ Microsoft OAuth initialized');
    } catch (e) {
      debugPrint('🔴 Failed to initialize Microsoft OAuth: $e');
      _isInitialized = false;
    }
  }

  // Getter for navigator key (use this in your main.dart)
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  String get providerName => 'Microsoft';

  @override
  Future<AuthResult> signIn() async {
    if (!_isInitialized) {
      debugPrint('🔴 Microsoft OAuth not initialized');
      return AuthResult(
        success: false,
        error: 'Microsoft authentication not properly configured',
      );
    }

    try {
      debugPrint('🔵 Starting Microsoft Sign-In...');

      // Step 1: Get Microsoft access token via OAuth
      await _oauth.login();
      debugPrint('🔵 Microsoft OAuth login completed');

      final accessToken = await _oauth.getAccessToken();
      debugPrint('🔵 Access token retrieved: ${accessToken != null}');

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('🔴 Microsoft: No access token received');
        return AuthResult(
          success: false,
          error: 'Microsoft authentication cancelled or failed',
        );
      }

      debugPrint('✅ Microsoft access token obtained');

      // Step 2: Create Microsoft credential for Firebase
      final OAuthCredential credential = OAuthProvider(
        'microsoft.com',
      ).credential(accessToken: accessToken);

      debugPrint('🔵 Created Microsoft credential for Firebase');

      // Step 3: Sign in to Firebase with Microsoft credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        debugPrint(
          '✅ Microsoft Sign-In Successful: ${userCredential.user!.email}',
        );
        return AuthResult(success: true, userId: userCredential.user!.uid);
      } else {
        debugPrint('🔴 Microsoft: Firebase user is null');
        return AuthResult(
          success: false,
          error: 'Failed to authenticate with Firebase',
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 Microsoft Firebase Error: ${e.code} - ${e.message}');
      return AuthResult(success: false, error: _handleFirebaseError(e));
    } catch (e) {
      debugPrint('🔴 Microsoft Sign-In Error: $e');
      return AuthResult(
        success: false,
        error: 'Microsoft sign-in failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _oauth.logout();
      debugPrint('✅ Signed out from Microsoft');
    } catch (e) {
      debugPrint('🔴 Microsoft Sign-Out Error: $e');
    }
  }

  /// Handles Firebase authentication errors
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method';
      case 'invalid-credential':
        return 'Invalid Microsoft credentials';
      case 'operation-not-allowed':
        return 'Microsoft sign-in is not enabled. Please contact support';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with these credentials';
      case 'wrong-password':
        return 'Invalid credentials';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'Microsoft sign-in failed';
    }
  }
}
