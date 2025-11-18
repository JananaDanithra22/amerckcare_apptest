// lib/core/utils/secure_storage_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _storedEmailKey = 'stored_email';
  static const _storedPasswordKey = 'stored_password';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled ? '1' : '0');
  }

  Future<bool> isBiometricEnabled() async {
    final v = await _storage.read(key: _biometricEnabledKey);
    return v == '1';
  }

  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _storedEmailKey, value: email);
    await _storage.write(key: _storedPasswordKey, value: password);
  }

  Future<Map<String, String?>> readCredentials() async {
    final email = await _storage.read(key: _storedEmailKey);
    final password = await _storage.read(key: _storedPasswordKey);
    return {'email': email, 'password': password};
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _storedEmailKey);
    await _storage.delete(key: _storedPasswordKey);
    await _storage.delete(key: _biometricEnabledKey);
  }
}
