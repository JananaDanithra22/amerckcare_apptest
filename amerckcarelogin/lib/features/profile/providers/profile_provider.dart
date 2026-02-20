// lib/features/profile/providers/profile_provider.dart

import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/user_service.dart';

class ProfileProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for the UI to read
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load profile from Firestore
  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _userService.getProfile(uid);
    } catch (e) {
      _errorMessage = 'Failed to load profile. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update and save profile to Firestore
  Future<bool> updateProfile(UserProfile updatedProfile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Add current timestamp
      final profileWithTimestamp = updatedProfile.copyWith(
        updatedAt: DateTime.now(),
      );

      await _userService.saveProfile(profileWithTimestamp);
      _profile = profileWithTimestamp;

      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false; // Failed
    }
  }

  /// Clear profile (on logout)
  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }
}
