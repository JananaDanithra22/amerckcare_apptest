import 'package:amerckcarelogin/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for biometric authentication (fingerprint/face recognition)
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticating = false; // ✅ Prevent concurrent auth

  // Storage keys
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyStoredEmail = 'stored_email';
  static const String _keyStoredPassword = 'stored_password';
  static const String _keyLoginType = 'stored_login_type';
  static const String _keyBiometricPromptShown = 'biometric_prompt_shown';

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
    if (_isAuthenticating) return false; // Prevent multiple concurrent auth
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

  /// Enable biometric login and store credentials securely
  /// For SSO users, password can be empty/null
  Future<void> enableBiometric(
    String email,
    String? password, {
    required LoginType loginType,
  }) async {
    try {
      await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
      await _secureStorage.write(key: _keyStoredEmail, value: email);

      // Store login type
      await _secureStorage.write(
        key: _keyLoginType,
        value: loginType.toString().split('.').last,
      );

      // Store password only for email/password users
      if (loginType == LoginType.emailPassword && password != null) {
        await _secureStorage.write(key: _keyStoredPassword, value: password);
      } else {
        await _secureStorage.delete(key: _keyStoredPassword);
      }

      await markBiometricPromptShown();
      debugPrint('✅ Biometric login enabled for $loginType');
    } catch (e) {
      debugPrint('🔴 Error enabling biometric: $e');
      rethrow;
    }
  }

  /// Disable biometric login and clear stored credentials
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _keyBiometricEnabled);
      await _secureStorage.delete(key: _keyStoredEmail);
      await _secureStorage.delete(key: _keyStoredPassword);
      await _secureStorage.delete(key: _keyLoginType);
      debugPrint('✅ Biometric login disabled');
    } catch (e) {
      debugPrint('🔴 Error disabling biometric: $e');
      rethrow;
    }
  }

  /// Get stored credentials (after successful biometric authentication)
  Future<Map<String, String?>?> getStoredCredentials() async {
    try {
      final email = await _secureStorage.read(key: _keyStoredEmail);
      final password = await _secureStorage.read(key: _keyStoredPassword);
      final loginTypeStr = await _secureStorage.read(key: _keyLoginType);

      if (email == null || loginTypeStr == null) return null;

      return {
        'email': email,
        'password': password,
        'loginType': loginTypeStr, // 'emailPassword', 'google', 'facebook'
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
      await _secureStorage.delete(key: _keyStoredEmail);
      await _secureStorage.delete(key: _keyStoredPassword);
      await _secureStorage.delete(key: _keyLoginType);
      await _secureStorage.delete(key: _keyBiometricPromptShown);
      debugPrint('✅ All biometric data reset');
    } catch (e) {
      debugPrint('🔴 Error resetting biometric data: $e');
    }
  }
}
