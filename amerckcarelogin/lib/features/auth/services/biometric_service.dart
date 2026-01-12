// lib/features/auth/services/biometric_service.dart

import 'package:AmerckCare/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for biometric authentication
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticating = false;

  // Storage keys
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyStoredEmail =
      'stored_email'; // For email/password only
  static const String _keyStoredPassword =
      'stored_password'; // For email/password only
  static const String _keyStoredUid =
      'stored_uid'; // ALWAYS stored for verification
  static const String _keyLoginType = 'stored_login_type';
  static const String _keyBiometricPromptShown = 'biometric_prompt_shown';
  static const String _keyPersistedLoginType = 'persisted_login_type';

  Future<void> persistLoginType(String loginType) async {
    try {
      await _secureStorage.write(key: _keyPersistedLoginType, value: loginType);
      debugPrint('✅ Persisted login type: $loginType');
    } catch (e) {
      debugPrint('🔴 Error persisting login type: $e');
    }
  }

  Future<String?> getPersistedLoginType() async {
    try {
      return await _secureStorage.read(key: _keyPersistedLoginType);
    } catch (e) {
      debugPrint('🔴 Error reading persisted login type: $e');
      return null;
    }
  }

  Future<void> clearPersistedLoginType() async {
    try {
      await _secureStorage.delete(key: _keyPersistedLoginType);
    } catch (e) {
      debugPrint('🔴 Error clearing persisted login type: $e');
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('🔴 Error checking device support: $e');
      return false;
    }
  }

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

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('🔴 Error getting available biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticate({String? reason}) async {
    if (_isAuthenticating) return false;
    _isAuthenticating = true;

    try {
      final biometricName = await getBiometricTypeName();
      final localizedReason = reason ?? 'Authenticate with $biometricName';

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('🔴 Biometric error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('🔴 Unexpected biometric error: $e');
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _keyBiometricEnabled);
      return enabled == 'true';
    } catch (e) {
      debugPrint('🔴 Error checking biometric enabled: $e');
      return false;
    }
  }

  Future<bool> hasBiometricPromptBeenShown() async {
    try {
      final shown = await _secureStorage.read(key: _keyBiometricPromptShown);
      return shown == 'true';
    } catch (e) {
      return false;
    }
  }

  Future<void> markBiometricPromptShown() async {
    try {
      await _secureStorage.write(key: _keyBiometricPromptShown, value: 'true');
    } catch (e) {
      debugPrint('🔴 Error marking prompt shown: $e');
    }
  }

  /// ✅ SIMPLIFIED: Enable biometric login
  /// Always stores UID for verification
  /// For email/password: also stores email and password
  /// For SSO: only stores UID (session must remain valid)
  Future<void> enableBiometric(
    String email, // Can be 'no-email' for SSO users without email
    String? password, // Only for email/password users
    String uid, { // ALWAYS required
    required LoginType loginType,
  }) async {
    try {
      await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
      await _secureStorage.write(key: _keyStoredUid, value: uid);
      await _secureStorage.write(
        key: _keyLoginType,
        value: loginType.toString().split('.').last,
      );

      if (loginType == LoginType.emailPassword) {
        // For email/password: store both email and password
        if (password == null) {
          throw Exception('Password required for email/password login type');
        }
        await _secureStorage.write(key: _keyStoredEmail, value: email);
        await _secureStorage.write(key: _keyStoredPassword, value: password);
      } else {
        // For SSO: just email (optional) and UID
        await _secureStorage.write(key: _keyStoredEmail, value: email);
        await _secureStorage.delete(key: _keyStoredPassword);
      }

      await markBiometricPromptShown();

      debugPrint('✅ Biometric enabled:');
      debugPrint('   Type: $loginType');
      debugPrint('   UID: $uid');
      debugPrint('   Email: $email');
      debugPrint('   Password stored: ${password != null}');
    } catch (e) {
      debugPrint('🔴 Error enabling biometric: $e');
      rethrow;
    }
  }

  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _keyBiometricEnabled);
      await _secureStorage.delete(key: _keyStoredEmail);
      await _secureStorage.delete(key: _keyStoredPassword);
      await _secureStorage.delete(key: _keyStoredUid);
      await _secureStorage.delete(key: _keyLoginType);
      debugPrint('✅ Biometric login disabled');
    } catch (e) {
      debugPrint('🔴 Error disabling biometric: $e');
      rethrow;
    }
  }

  /// Get stored credentials
  Future<Map<String, String?>?> getStoredCredentials() async {
    try {
      final email = await _secureStorage.read(key: _keyStoredEmail);
      final password = await _secureStorage.read(key: _keyStoredPassword);
      final uid = await _secureStorage.read(key: _keyStoredUid);
      final loginTypeStr = await _secureStorage.read(key: _keyLoginType);

      if (uid == null || loginTypeStr == null) return null;

      return {
        'email': email,
        'password': password,
        'uid': uid,
        'loginType': loginTypeStr,
      };
    } catch (e) {
      debugPrint('🔴 Error reading stored credentials: $e');
      return null;
    }
  }

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

  Future<void> clearAll() async {
    await disableBiometric();
  }

  Future<void> resetAll() async {
    try {
      await _secureStorage.delete(key: _keyBiometricEnabled);
      await _secureStorage.delete(key: _keyStoredEmail);
      await _secureStorage.delete(key: _keyStoredPassword);
      await _secureStorage.delete(key: _keyStoredUid);
      await _secureStorage.delete(key: _keyLoginType);
      await _secureStorage.delete(key: _keyBiometricPromptShown);
      debugPrint('✅ All biometric data reset');
    } catch (e) {
      debugPrint('🔴 Error resetting biometric data: $e');
    }
  }
}
