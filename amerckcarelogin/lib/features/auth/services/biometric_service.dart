// lib/features/auth/services/biometric_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for biometric authentication (fingerprint/face recognition)
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyStoredEmail = 'stored_email';
  static const String _keyStoredPassword = 'stored_password';
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
  /// (device supports it AND user has enrolled biometrics)
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
    try {
      final biometricName = await getBiometricTypeName();
      final localizedReason =
          reason ?? 'Authenticate with $biometricName to login';

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN fallback for better UX
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('🔴 Biometric authentication error: ${e.code} - ${e.message}');

      // Handle specific error codes
      if (e.code == 'NotAvailable') {
        debugPrint('Biometric authentication not available on this device');
      } else if (e.code == 'NotEnrolled') {
        debugPrint('User has not enrolled biometric authentication');
      }

      return false;
    } catch (e) {
      debugPrint('🔴 Unexpected biometric error: $e');
      return false;
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

  /// Check if we've already shown the biometric prompt to avoid annoying users
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
  Future<void> enableBiometric(String email, String password) async {
    try {
      await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
      await _secureStorage.write(key: _keyStoredEmail, value: email);
      await _secureStorage.write(key: _keyStoredPassword, value: password);
      await markBiometricPromptShown(); // Don't ask again
      debugPrint('✅ Biometric login enabled');
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
      debugPrint('✅ Biometric login disabled');
    } catch (e) {
      debugPrint('🔴 Error disabling biometric: $e');
      rethrow;
    }
  }

  /// Get stored credentials (after successful biometric authentication)
  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      final email = await _secureStorage.read(key: _keyStoredEmail);
      final password = await _secureStorage.read(key: _keyStoredPassword);

      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Error reading stored credentials: $e');
      return null;
    }
  }

  /// Get biometric type name for display (Fingerprint/Face ID/etc.)
  Future<String> getBiometricTypeName() async {
    try {
      final biometrics = await getAvailableBiometrics();

      if (biometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (biometrics.contains(BiometricType.iris)) {
        return 'Iris';
      } else if (biometrics.contains(BiometricType.strong) ||
          biometrics.contains(BiometricType.weak)) {
        return 'Biometric';
      }
      return 'Biometric';
    } catch (e) {
      return 'Biometric';
    }
  }

  /// Clear all stored data (on logout)
  Future<void> clearAll() async {
    await disableBiometric();
    // Keep the prompt shown flag so we don't ask again after logout
  }

  /// Reset everything including prompt flag (for testing or settings)
  Future<void> resetAll() async {
    try {
      await _secureStorage.delete(key: _keyBiometricEnabled);
      await _secureStorage.delete(key: _keyStoredEmail);
      await _secureStorage.delete(key: _keyStoredPassword);
      await _secureStorage.delete(key: _keyBiometricPromptShown);
      debugPrint('✅ All biometric data reset');
    } catch (e) {
      debugPrint('🔴 Error resetting biometric data: $e');
    }
  }
}
