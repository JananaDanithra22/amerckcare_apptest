import 'package:firebase_auth/firebase_auth.dart';
import '../auth_provider_interface.dart';

class EmailPasswordAuthProvider implements IAuthProvider {
  final FirebaseAuth _auth;
  final String email;
  final String password;

  EmailPasswordAuthProvider({
    required this.email,
    required this.password,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  @override
  String get providerName => 'Email';

  @override
  Future<AuthResult> signIn() async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult(
        success: credential.user != null,
        userId: credential.user?.uid,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'An unexpected error occurred');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AuthResult> signUp() async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult(
        success: credential.user != null,
        userId: credential.user?.uid,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapSignupError(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Sign up failed');
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'user-not-found';
      case 'wrong-password':
        return 'wrong-password';
      case 'invalid-credential':
        return 'invalid-credential';
      case 'user-disabled':
        return 'user-disabled';
      case 'invalid-email':
        return 'invalid-email';
      case 'too-many-requests':
        return 'too-many-requests';
      case 'network-request-failed':
        return 'network error';
      default:
        return code;
    }
  }

  String _mapSignupError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email format';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      default:
        return 'Sign up failed';
    }
  }
}
