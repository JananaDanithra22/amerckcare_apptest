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
  // Use 'common' for multi-tenant (personal + work/school accounts)
  static const String _tenantId = 'common';
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

      String? rawAccessToken = await _oauth.getAccessToken();
      debugPrint('🔵 Raw access token retrieved: ${rawAccessToken != null}');

      if (rawAccessToken == null || rawAccessToken.isEmpty) {
        debugPrint('🔴 Microsoft: No access token received');
        return AuthResult(
          success: false,
          error: 'Microsoft authentication cancelled or failed',
        );
      }

      // Extract the actual token from the URL if needed
      String? accessToken = _extractTokenFromUrl(rawAccessToken);

      // If extraction returned a URL, try to get access_token from it
      if (accessToken != null && accessToken.startsWith('http')) {
        final uri = Uri.parse(accessToken);
        accessToken =
            uri.queryParameters['access_token'] ??
            Uri.splitQueryString(uri.fragment)['access_token'];
      }

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('🔴 Microsoft: Failed to extract access token');
        return AuthResult(
          success: false,
          error:
              'Microsoft authentication failed - invalid access token format',
        );
      }

      debugPrint(
        '✅ Microsoft access token extracted: ${accessToken.substring(0, 20)}...',
      );

      // CRITICAL FIX: Get the ID token (not just access token)
      String? rawIdToken = await _oauth.getIdToken();
      debugPrint('🔵 Raw ID token retrieved: ${rawIdToken != null}');

      if (rawIdToken == null || rawIdToken.isEmpty) {
        debugPrint('🔴 Microsoft: No ID token received');
        return AuthResult(
          success: false,
          error: 'Microsoft authentication failed - no ID token',
        );
      }

      // Extract the actual token from the URL if it's a redirect URL
      String? idToken = _extractTokenFromUrl(rawIdToken);

      // If extraction returned a URL, try to get id_token from it
      if (idToken != null && idToken.startsWith('http')) {
        final uri = Uri.parse(idToken);
        idToken =
            uri.queryParameters['id_token'] ??
            Uri.splitQueryString(uri.fragment)['id_token'];
      }

      if (idToken == null || idToken.isEmpty) {
        debugPrint('🔴 Microsoft: Failed to extract ID token from response');
        return AuthResult(
          success: false,
          error: 'Microsoft authentication failed - invalid ID token format',
        );
      }

      debugPrint(
        '✅ Microsoft ID token extracted: ${idToken.substring(0, 20)}...',
      );

      // Step 2: Create Microsoft credential for Firebase with BOTH tokens
      final OAuthCredential credential = OAuthProvider(
        'microsoft.com',
      ).credential(
        accessToken: accessToken,
        idToken: idToken, // THIS IS THE KEY FIX!
      );

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

  /// Extracts the token from a URL string if present
  /// Handles cases where aad_oauth returns a full redirect URL instead of just the token
  String? _extractTokenFromUrl(String tokenOrUrl) {
    // If it doesn't look like a URL, return as-is
    if (!tokenOrUrl.startsWith('http')) {
      return tokenOrUrl;
    }

    // If it's a URL, return it for further processing
    // The caller will extract the specific token they need
    return tokenOrUrl;
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
