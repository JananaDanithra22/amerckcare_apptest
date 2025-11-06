import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../auth_provider_interface.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Facebook Sign-In authentication provider
class FacebookAuthProvider implements IAuthProvider {
  final FirebaseAuth _auth;
  final FacebookAuth _facebookAuth;

  FacebookAuthProvider({FirebaseAuth? auth, FacebookAuth? facebookAuth})
    : _auth = auth ?? FirebaseAuth.instance,
      _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  @override
  String get providerName => 'Facebook';

  @override
  Future<AuthResult> signIn() async {
    try {
      // Step 1: Trigger Facebook login dialog
      final LoginResult result = await _facebookAuth.login();

      // Step 2: Check if user cancelled
      if (result.status == LoginStatus.cancelled) {
        return AuthResult(success: false, error: 'Facebook sign-in cancelled');
      }

      // Step 3: Check if login failed
      if (result.status != LoginStatus.success) {
        return AuthResult(
          success: false,
          error: result.message ?? 'Facebook sign-in failed',
        );
      }

      // Step 4: Get access token
      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        return AuthResult(
          success: false,
          error: 'Failed to get Facebook access token',
        );
      }

      // Step 5: Create Firebase credential from Facebook token
      // ✅ FIX: Use firebase_auth prefix to access Firebase's FacebookAuthProvider
      final OAuthCredential credential = firebase_auth
          .FacebookAuthProvider.credential(accessToken.token);

      // Step 6: Sign in to Firebase with Facebook credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Step 7: Return success
      return AuthResult(
        success: userCredential.user != null,
        userId: userCredential.user?.uid,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        error: e.message ?? 'Facebook sign-in failed',
      );
    } catch (e) {
      return AuthResult(success: false, error: 'Facebook sign-in failed');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _facebookAuth.logOut()]);
  }
}
