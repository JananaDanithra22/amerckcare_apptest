// File: lib/features/auth/domain/auth_provider_interface.dart

/// Base interface for all authentication providers
abstract class IAuthProvider {
  /// Attempts to sign in with this provider
  Future<AuthResult> signIn();

  /// Signs out from this provider
  Future<void> signOut();

  /// Name of the provider (e.g., "Email", "Google")
  String get providerName;
}

/// Result object returned from authentication attempts
class AuthResult {
  final bool success;
  final String? error;
  final String? userId;

  AuthResult({required this.success, this.error, this.userId});
}
