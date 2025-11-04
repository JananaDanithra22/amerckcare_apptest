import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth_provider_interface.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Google Sign-In authentication provider
class GoogleAuthProvider implements IAuthProvider {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  GoogleAuthProvider({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  String get providerName => 'Google';

  @override
  Future<AuthResult> signIn() async {
    try {
      // Sign out first to force account picker
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult(success: false, error: 'Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return AuthResult(
        success: userCredential.user != null,
        userId: userCredential.user?.uid,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        error: e.message ?? 'Google sign-in failed',
      );
    } catch (e) {
      return AuthResult(success: false, error: 'Google sign-in failed');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }
}
