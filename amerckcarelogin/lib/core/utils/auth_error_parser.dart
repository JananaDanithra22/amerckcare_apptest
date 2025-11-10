// lib/core/utils/auth_error_parser.dart

/// Utility class for parsing Firebase authentication errors
/// into user-friendly, field-specific error messages
class AuthErrorParser {
  /// Parse Firebase errors into field-specific error messages
  /// Returns a map with 'email' and 'password' keys
  static Map<String, String?> parse(String? errorMsg) {
    if (errorMsg == null) {
      return {'password': 'Operation failed. Please try again.'};
    }

    String? emailErr;
    String? passwordErr;
    final error = errorMsg.toLowerCase();

    // Email-related errors
    if (error.contains('user-not-found') ||
        error.contains('no user record') ||
        error.contains('no account')) {
      emailErr = 'No account found with this email';
    } else if (error.contains('email-already-in-use') ||
        error.contains('already in use')) {
      emailErr = 'This email is already registered';
    } else if (error.contains('user-disabled') ||
        error.contains('account disabled')) {
      emailErr = 'This account has been disabled';
    } else if (error.contains('invalid-email') ||
        error.contains('badly formatted')) {
      emailErr = 'Invalid email format';
    }
    // Password-related errors
    else if (error.contains('wrong-password') ||
        error.contains('password is invalid')) {
      passwordErr = 'Incorrect password';
    } else if (error.contains('invalid-credential') ||
        error.contains('invalid credential')) {
      passwordErr = 'Invalid email or password';
    } else if (error.contains('weak-password')) {
      passwordErr = 'Password is too weak';
    } else if (error.contains('too-many-requests')) {
      passwordErr = 'Too many failed attempts. Try again later';
    } else if (error.contains('network') || error.contains('connection')) {
      passwordErr = 'Network error. Check your connection';
    } else {
      // Default: assume it's a password error
      passwordErr = 'Invalid email or password';
    }

    return {'email': emailErr, 'password': passwordErr};
  }

  /// Get a generic error message for display in snackbars
  static String getGenericMessage(String? errorMsg) {
    if (errorMsg == null) return 'An error occurred. Please try again.';

    final error = errorMsg.toLowerCase();

    if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Check your connection';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled';
    } else {
      return 'Authentication failed. Please try again';
    }
  }
}