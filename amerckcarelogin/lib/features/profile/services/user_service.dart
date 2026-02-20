// lib/features/profile/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';

class UserService {
  // Singleton pattern (same as your SessionManager)
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Reference to Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection name in Firestore
  static const String _collection = 'users';

  /// SAVE profile to Firestore
  /// Uses 'set with merge:true' → creates if not exists, updates if exists
  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _db
          .collection(_collection)
          .doc(profile.uid)           // Document ID = user's UID
          .set(profile.toMap(), SetOptions(merge: true));

      debugPrint('✅ Profile saved for uid: ${profile.uid}');
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');
      rethrow; // Let the UI handle the error
    }
  }

  /// GET profile from Firestore
  /// Returns null if profile doesn't exist yet
  Future<UserProfile?> getProfile(String uid) async {
    try {
      final doc = await _db.collection(_collection).doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('ℹ️ No profile found for uid: $uid');
        return null;
      }

      debugPrint('✅ Profile fetched for uid: $uid');
      return UserProfile.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('❌ Error fetching profile: $e');
      rethrow;
    }
  }

  /// STREAM profile (real-time updates)
  /// Use this if you want the UI to auto-update when data changes
  Stream<UserProfile?> streamProfile(String uid) {
    return _db
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return UserProfile.fromMap(doc.data()!);
        });
  }

  /// CREATE initial profile when user first signs up
  Future<void> createInitialProfile({
    required String uid,
    required String email,
  }) async {
    // Check if profile already exists
    final existing = await getProfile(uid);
    if (existing != null) return; // Don't overwrite existing profile

    final name = email.split('@')[0]; // Use email prefix as default name

    final initialProfile = UserProfile(
      uid: uid,
      name: name,
      email: email,
      phone: '',
      specialization: 'General Physician',
      licenseNumber: '',
      experience: '',
      updatedAt: DateTime.now(),
    );

    await saveProfile(initialProfile);
    debugPrint('✅ Initial profile created for: $email');
  }
}