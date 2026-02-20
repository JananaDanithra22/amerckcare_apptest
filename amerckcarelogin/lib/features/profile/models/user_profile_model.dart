// lib/features/profile/models/user_profile_model.dart

class UserProfile {
  final String uid;           // Firebase Auth user ID (never changes)
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String licenseNumber;
  final String experience;
  final String? photoUrl;     // Optional profile photo
  final DateTime? updatedAt;  // When profile was last updated

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.licenseNumber,
    required this.experience,
    this.photoUrl,
    this.updatedAt,
  });

  /// Convert Dart object → Firestore Map (for saving)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'experience': experience,
      'photoUrl': photoUrl,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert Firestore Map → Dart object (for reading)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      specialization: map['specialization'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      experience: map['experience'] ?? '',
      photoUrl: map['photoUrl'],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
    );
  }

  /// Create a copy with updated fields (useful for partial updates)
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? specialization,
    String? licenseNumber,
    String? experience,
    String? photoUrl,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experience: experience ?? this.experience,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}