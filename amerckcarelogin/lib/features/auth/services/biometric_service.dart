import 'package:amerckcarelogin/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for biometric authentication (fingerprint/face recognition)
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticating = false;

  // ✅ UPDATED: Changed storage keys to be more semantic
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyStoredIdentifier =
      'stored_identifier'; // Email or UID
  static const String _keyStoredCredential =
      'stored_credential'; // Password or UID
  static const String _keyLoginType = 'stored_login_type';
  static const String _keyBiometricPromptShown = 'biometric_prompt_shown';
  static const String _keyPersistedLoginType = 'persisted_login_type';

  /// Persist login type (separate from biometric storage)
  Future<void> persistLoginType(String loginType) async {
    try {
      await _secureStorage.write(key: _keyPersistedLoginType, value: loginType);
      debugPrint('✅ Persisted login type: $loginType');
    } catch (e) {
      debugPrint('🔴 Error persisting login type: $e');
    }
  }

  /// Get persisted login type
  Future<String?> getPersistedLoginType() async {
    try {
      return await _secureStorage.read(key: _keyPersistedLoginType);
    } catch (e) {
      debugPrint('🔴 Error reading persisted login type: $e');
      return null;
    }
  }

  /// Clear persisted login type (call on logout)
  Future<void> clearPersistedLoginType() async {
    try {
      await _secureStorage.delete(key: _keyPersistedLoginType);
    } catch (e) {
      debugPrint('🔴 Error clearing persisted login type: $e');
    }
  }

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('🔴 Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;

      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('🔴 Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('🔴 Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({String? reason}) async {
    if (_isAuthenticating) return false;
    _isAuthenticating = true;

    try {
      final biometricName = await getBiometricTypeName();
      final localizedReason =
          reason ?? 'Authenticate with $biometricName to login';

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('🔴 Biometric authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('🔴 Unexpected biometric error: $e');
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _keyBiometricEnabled);
      return enabled == 'true';
    } catch (e) {
      debugPrint('🔴 Error checking biometric enabled: $e');
      return false;
    }
  }

  /// Check if we've already shown the biometric prompt
  Future<bool> hasBiometricPromptBeenShown() async {
    try {
      final shown = await _secureStorage.read(key: _keyBiometricPromptShown);
      return shown == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Mark that we've shown the biometric prompt
  Future<void> markBiometricPromptShown() async {
    try {
      await _secureStorage.write(key: _keyBiometricPromptShown, value: 'true');
    } catch (e) {
      debugPrint('🔴 Error marking prompt shown: $e');
    }
  }

  /// ✅ UPDATED: Enable biometric login
  /// For emailPassword: identifier = email, credential = password
  /// For SSO (Google/Facebook): identifier = uid, credential = uid
  Future<void> enableBiometric(
    String identifier,
    String? credential, {
    required LoginType loginType,
  }) async {
    try {
      await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
      await _secureStorage.write(key: _keyStoredIdentifier, value: identifier);

      // Store login type
      await _secureStorage.write(
        key: _keyLoginType,
        value: loginType.toString().split('.').last,
      );

      // Store credential based on login type
      if (loginType == LoginType.emailPassword && credential != null) {
        // For email/password: store the password
        await _secureStorage.write(
          key: _keyStoredCredential,
          value: credential,
        );
      } else if (loginType == LoginType.google ||
          loginType == LoginType.facebook) {
        // ✅ For SSO: store UID as credential for verification
        await _secureStorage.write(
          key: _keyStoredCredential,
          value: credential ?? identifier,
        );
      }

      await markBiometricPromptShown();
      debugPrint('✅ Biometric enabled: $loginType | Identifier: $identifier');
    } catch (e) {
      debugPrint('🔴 Error enabling biometric: $e');
      rethrow;
    }
  }

  /// Disable biometric login and clear stored credentials
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _keyBiometricEnabled);
      await _secureStorage.delete(key: _keyStoredIdentifier);
      await _secureStorage.delete(key: _keyStoredCredential);
      await _secureStorage.delete(key: _keyLoginType);
      debugPrint('✅ Biometric login disabled');
    } catch (e) {
      debugPrint('🔴 Error disabling biometric: $e');
      rethrow;
    }
  }

  /// ✅ UPDATED: Get stored credentials
  /// Returns: identifier (email or UID), credential (password or UID), loginType
  Future<Map<String, String?>?> getStoredCredentials() async {
    try {
      final identifier = await _secureStorage.read(key: _keyStoredIdentifier);
      final credential = await _secureStorage.read(key: _keyStoredCredential);
      final loginTypeStr = await _secureStorage.read(key: _keyLoginType);

      if (identifier == null || loginTypeStr == null) return null;

      return {
        'identifier': identifier,
        'credential': credential,
        'loginType': loginTypeStr,
      };
    } catch (e) {
      debugPrint('🔴 Error reading stored credentials: $e');
      return null;
    }
  }

  /// Get biometric type name for display
  Future<String> getBiometricTypeName() async {
    try {
      final biometrics = await getAvailableBiometrics();

      if (biometrics.contains(BiometricType.face)) return 'Face ID';
      if (biometrics.contains(BiometricType.fingerprint)) return 'Fingerprint';
      if (biometrics.contains(BiometricType.iris)) return 'Iris';
      if (biometrics.contains(BiometricType.strong) ||
          biometrics.contains(BiometricType.weak))
        return 'Biometric';
      return 'Biometric';
    } catch (e) {
      return 'Biometric';
    }
  }

  /// Clear all stored data (on logout)
  Future<void> clearAll() async {
    await disableBiometric();
  }

  /// Reset everything including prompt flag
  Future<void> resetAll() async {
    try {
      await _secureStorage.delete(key: _keyBiometricEnabled);
      await _secureStorage.delete(key: _keyStoredIdentifier);
      await _secureStorage.delete(key: _keyStoredCredential);
      await _secureStorage.delete(key: _keyLoginType);
      await _secureStorage.delete(key: _keyBiometricPromptShown);
      debugPrint('✅ All biometric data reset');
    } catch (e) {
      debugPrint('🔴 Error resetting biometric data: $e');
    }
  }
}
